import UIKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let curveView = BezierView(frame: view.bounds)
        curveView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(curveView)
    }
}
