
🔥 Flame-Project
Interactive Bézier Curve with Physics & Sensor Control

Author: Shruti
Date: December 13, 2025

This project contains two separate implementations of an interactive cubic Bézier curve:

🌐 Web Version: flame.html

📱 iOS Version: ios-ver.swift + ViewController.swift

Both versions implement the Bézier curve, tangent vectors, and spring-damper physics manually, without using external libraries.

📌 Overview

The Bézier curve reacts to user-controlled motion:

Web: Mouse input

iOS: Gyroscope (CoreMotion)

Dynamic control points P₁ and P₂ move like masses attached to springs, giving the curve a rope-like, natural motion.

🧠 Mathematical Model

1️⃣ Cubic Bézier Formula

Using four control points P₀, P₁, P₂, P₃:

B(t) = (1−t)³ P0
     + 3(1−t)² t P1
     + 3(1−t) t² P2
     + t³ P3


Curve is sampled at Δt = 0.01

Rendering done point-by-point

2️⃣ Tangent Vector Formula

Derivative of Bézier curve:

B'(t) = 3(1−t)² (P1−P0)
      + 6(1−t)t (P2−P1)
      + 3t² (P3−P2)


Tangents are normalized:

unitVector = vector / √(dx² + dy²)


Displayed at evenly spaced t-values.

⚙️ Physics Model

The behavior of dynamic control points uses a spring-damper system:

acceleration = -k (pos - target)
               − damping × velocity
velocity += acceleration
position += velocity

Benefits:

Smooth, realistic elasticity

No abrupt jumps

Adjustable via control sliders (Web)

🌐 Web Version (flame.html)
Features:

Mouse-driven interaction

Sliders for:

Spring stiffness

Damping

Tangent count

60 FPS rendering using requestAnimationFrame

Fully manual Bézier computation

How to Run:

Save the file as flame.html

Double-click to open in a browser

Move your mouse to deform the curve

Adjust sliders to modify physics

Works on:

Chrome

Firefox

Edge

Safari

📱 iOS Version
Files:

ios-ver.swift – main custom Bézier view

ViewController.swift – loads the custom view into screen

Additional Requirement:

Add this to Info.plist:

Privacy - Motion Usage Description
"This app needs motion input to animate the Bézier curve."

Features:

Uses CoreMotion for gyroscope input

Real-time animation using CADisplayLink (60 FPS)

Curve updates as the device tilts

Full manual rendering using CoreGraphics

How to Run:

Open Xcode → Create new iOS App

Add both Swift files to the project

Add motion permission key to Info.plist

Run on:

iOS Simulator

or a real device

Simulator does not fully emulate gyroscope movement,
but animation still works correctly.

🔬 Validation (Web + iOS)
Mathematical:

Curve endpoints correct

Tangent direction accuracy validated

C¹ curve continuity maintained

Physics:

Stable under default parameters

Visually natural oscillations

No divergence

Performance:

Both versions achieve ~60 FPS

Efficient drawing & updating

📁 Repository Structure
Flame-Project/
│
├── web/
│   └── flame.html
│
├── ios/
│   ├── ios-ver.swift
│   └── ViewController.swift
│
└── README.md

🎬 Demo Recording Guide (30s)

Show:

Web curve reacting to mouse

Changing stiffness → more rigid motion

Changing damping → smoother or bouncier motion

Tangent vectors moving with curve

iOS simulator running the Swift version

Tilting device (if available)

📝 Conclusion

This project demonstrates:

Manual Bézier curve mathematics

Derivative-based tangent visualization

Spring-damper physics modeling

Real-time animation on Web & iOS

Sensor-based interaction on iOS

Clean modular code architecture

Meets all requirements of the assignment.
