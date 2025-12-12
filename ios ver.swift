import UIKit
import CoreMotion

class BezierView: UIView {
    
    //  Internal Model for a Control Point
    
    struct Node {
        var position: CGPoint
        var velocity: CGPoint
        var destination: CGPoint
        let isLocked: Bool
    }
    
    // Motion manager for CoreMotion updates
    private let motion = CMMotionManager()
    
    // Four Bézier control points
    private var start: Node!
    private var mid1: Node!
    private var mid2: Node!
    private var end: Node!
    
    // Physics parameters
    private let springK: CGFloat = 120     // Spring stiffness
    private let damping: CGFloat = 16      // Opposes velocity
    
    private var display: CADisplayLink?
    
   
    // Initializers
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScene()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScene()
    }
   
    //  Setup
  
    private func setupScene() {
        backgroundColor = UIColor(red: 15/255, green: 16/255, blue: 30/255, alpha: 1)
        
        // Define initial points (two fixed, two movable)
        start = Node(
            position: CGPoint(x: 40, y: bounds.height - 80),
            velocity: .zero,
            destination: .zero,
            isLocked: true
        )
        
        end = Node(
            position: CGPoint(x: bounds.width - 40, y: 80),
            velocity: .zero,
            destination: .zero,
            isLocked: true
        )
        
        mid1 = Node(
            position: CGPoint(x: bounds.midX - 110, y: bounds.midY),
            velocity: .zero,
            destination: .zero,
            isLocked: false
        )
        
        mid2 = Node(
            position: CGPoint(x: bounds.midX + 110, y: bounds.midY),
            velocity: .zero,
            destination: .zero,
            isLocked: false
        )
        
        mid1.destination = mid1.position
        mid2.destination = mid2.position
        
        beginGyroTracking()
        beginAnimation()
    }
    
   
    // Motion Handling
   
    private func beginGyroTracking() {
        guard motion.isDeviceMotionAvailable else { return }
        
        motion.deviceMotionUpdateInterval = 1.0 / 60
        
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let attitude = data?.attitude else { return }
            self?.mapGyroToTargets(attitude)
        }
    }
    
    private func mapGyroToTargets(_ attitude: CMAttitude) {
        let roll  = CGFloat(attitude.roll)
        let pitch = CGFloat(attitude.pitch)
        
        // Map tilt to center offset
        let cx = bounds.midX + roll * 130
        let cy = bounds.midY + pitch * 130
        
        mid1.destination = CGPoint(x: cx - 70, y: cy + 20)
        mid2.destination = CGPoint(x: cx + 70, y: cy - 20)
    }
    
   
    // Animation Loop
    
    private func beginAnimation() {
        display = CADisplayLink(target: self, selector: #selector(frameUpdate))
        display?.add(to: .main, forMode: .common)
    }
    
    @objc private func frameUpdate() {
        let dt = CGFloat(display?.duration ?? (1 / 60.0))
        
        simulate(&mid1, dt: dt)
        simulate(&mid2, dt: dt)
        
        setNeedsDisplay()
    }
    
    private func simulate(_ node: inout Node, dt: CGFloat) {
        guard !node.isLocked else { return }
        
        let dx = node.destination.x - node.position.x
        let dy = node.destination.y - node.position.y
        
        let ax = dx * springK - node.velocity.x * damping
        let ay = dy * springK - node.velocity.y * damping
        
        node.velocity.x += ax * dt
        node.velocity.y += ay * dt
        
        node.position.x += node.velocity.x * dt
        node.position.y += node.velocity.y * dt
    }
    
   
    // MARK: - Bézier Mathematics
    
    private func pointOnBezier(_ t: CGFloat,
                               _ a: CGPoint, _ b: CGPoint,
                               _ c: CGPoint, _ d: CGPoint) -> CGPoint {
        
        let u  = 1 - t
        let u2 = u * u
        let u3 = u2 * u
        let t2 = t * t
        let t3 = t2 * t
        
        return CGPoint(
            x: u3 * a.x + 3 * u2 * t * b.x + 3 * u * t2 * c.x + t3 * d.x,
            y: u3 * a.y + 3 * u2 * t * b.y + 3 * u * t2 * c.y + t3 * d.y
        )
    }
    
    private func derivativeAt(_ t: CGFloat,
                              _ a: CGPoint, _ b: CGPoint,
                              _ c: CGPoint, _ d: CGPoint) -> CGPoint {
        
        let u = 1 - t
        return CGPoint(
            x: 3 * u * u * (b.x - a.x) +
               6 * u * t * (c.x - b.x) +
               3 * t * t * (d.x - c.x),
            
            y: 3 * u * u * (b.y - a.y) +
               6 * u * t * (c.y - b.y) +
               3 * t * t * (d.y - c.y)
        )
    }
    
    
    //Rendering
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.fill(rect)
        
        let A = start.position
        let B = mid1.position
        let C = mid2.position
        let D = end.position
        
        // ---- Draw Curve ----
        ctx.setStrokeColor(UIColor.cyan.cgColor)
        ctx.setLineWidth(3)
        ctx.beginPath()
        
        var t: CGFloat = 0
        let inc: CGFloat = 0.01
        ctx.move(to: pointOnBezier(0, A, B, C, D))
        
        while t <= 1 {
            let p = pointOnBezier(t, A, B, C, D)
            ctx.addLine(to: p)
            t += inc
        }
        
        ctx.strokePath()
        
        // ---- Draw Tangent Samples ----
        ctx.setStrokeColor(UIColor.magenta.cgColor)
        for i in 1...8 {
            let tt = CGFloat(i) / 9
            let p = pointOnBezier(tt, A, B, C, D)
            let d = derivativeAt(tt, A, B, C, D)
            
            let mag = max(1, sqrt(d.x * d.x + d.y * d.y))
            let vx = d.x / mag
            let vy = d.y / mag
            
            ctx.beginPath()
            ctx.move(to: p)
            ctx.addLine(to: CGPoint(x: p.x + vx * 32, y: p.y + vy * 32))
            ctx.strokePath()
        }
        
        // ---- Draw Control Points ----
        func paintPoint(_ p: CGPoint, _ col: UIColor) {
            ctx.setFillColor(col.cgColor)
            ctx.fillEllipse(in: CGRect(x: p.x - 6, y: p.y - 6, width: 12, height: 12))
        }
        
        paintPoint(A, .systemGreen)
        paintPoint(B, .systemBlue)
        paintPoint(C, .systemBlue)
        paintPoint(D, .systemGreen)
    }
    
    deinit {
        motion.stopDeviceMotionUpdates()
        display?.invalidate()
    }
}
