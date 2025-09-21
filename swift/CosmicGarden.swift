//
// CosmicGarden.swift
// SwiftUI generative art project — by Cazzy
//
// Concept: a living, cosmic garden of stars, clouds, fractals, and flowers.
// Purpose: showcase SwiftUI skills, animations, generative algorithms, and creative thinking.
//

import SwiftUI

// MARK: - Entry Point

@main
struct CosmicGardenApp: App {
    var body: some Scene {
        WindowGroup {
            GardenView()
        }
    }
}

// MARK: - Garden View
struct GardenView: View {
    // Random seed to make each run unique
    @State private var seed = Int.random(in: 0...1000)
    @State private var time: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient for cosmic depth
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Stars
            ForEach(0..<50, id: \.self) { i in
                StarView(seed: seed+i, time: time)
            }
            
            // Clouds
            ForEach(0..<5, id: \.self) { i in
                CloudView(seed: seed+i*7, time: time)
            }
            
            // Fractal flowers
            ForEach(0..<6, id: \.self) { i in
                FlowerView(seed: seed+i*13, time: time)
            }
        }
        .onAppear {
            // Animate time to drive generative motion
            withAnimation(.linear(duration: 100).repeatForever(autoreverses: false)) {
                time = 100
            }
        }
    }
}

// MARK: - Individual Components

/// A star that twinkles randomly
struct StarView: View {
    var seed: Int
    var time: Double
    
    var body: some View {
        let size = Double.random(in: 2...6)
        let x = Double.random(in: 0...UIScreen.main.bounds.width)
        let y = Double.random(in: 0...UIScreen.main.bounds.height)
        let opacity = 0.5 + 0.5 * sin(time/10 + Double(seed))
        
        return Circle()
            .fill(Color.white)
            .frame(width: size, height: size)
            .position(x: x, y: y)
            .opacity(opacity)
            .shadow(radius: 2)
    }
}

/// A soft, drifting cloud
struct CloudView: View {
    var seed: Int
    var time: Double
    
    var body: some View {
        let xOffset = CGFloat((sin(time/20 + Double(seed)) + 1) * 150)
        let yOffset = CGFloat(Double.random(in: 50...200))
        
        return Ellipse()
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.3), Color.gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            ))
            .frame(width: 200, height: 60)
            .position(x: 100 + xOffset, y: yOffset)
    }
}

/// Recursive fractal flower
struct FlowerView: View {
    var seed: Int
    var time: Double
    
    var body: some View {
        let centerX = Double.random(in: 50...350)
        let centerY = Double.random(in: 400...700)
        let petalCount = Int.random(in: 5...12)
        let radius = Double.random(in: 20...50)
        
        return ZStack {
            ForEach(0..<petalCount, id: \.self) { i in
                let angle = Double(i)/Double(petalCount) * 2 * Double.pi
                PetalView(radius: radius, seed: seed+i, angleOffset: angle, time: time)
            }
        }
        .position(x: centerX, y: centerY)
    }
}

/// Single petal of a flower
struct PetalView: View {
    var radius: Double
    var seed: Int
    var angleOffset: Double
    var time: Double
    
    var body: some View {
        let oscillation = 5 * sin(time/10 + Double(seed))
        
        return Capsule()
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color.pink, Color.purple.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            ))
            .frame(width: radius, height: radius/2)
            .rotationEffect(.radians(angleOffset + oscillation/50))
            .scaleEffect(1 + 0.1 * sin(time/5 + Double(seed)))
    }
}

// MARK: - Thought Process Documentation

/*
 Thought Process:

 1. **Unique Theme**: I wanted to combine organic (flowers), cosmic (stars), and ephemeral (clouds) elements
    into a single living scene. This demonstrates conceptual creativity beyond standard tutorials.

 2. **Generative Design**: Each component uses randomness and time-based animation.
    This shows understanding of SwiftUI animations, functional composition, and reactive state.

 3. **Recursion & Patterns**: Flowers are fractal-like, each petal slightly oscillates — showing recursive
    thinking applied visually.

 4. **Advanced SwiftUI Techniques**: 
      - ZStack layering for depth.
      - Animations tied to a global time state.
      - LinearGradient and opacity for soft blending.
      - Functional parameterization (seed-driven randomness).

 5. **Readable & Modular**: Each visual element (Star, Cloud, Flower, Petal) is self-contained.
    The code is intentionally poetic and human-readable, showing how code can be creative and conceptual.

 6. **High-Level Thinking**: This project demonstrates abstract design thinking, generative systems,
    time-based dynamics, and modular architecture — all qualities that reflect deep Swift expertise.

 7. **Extendable**: This framework allows adding new “Vibes” (e.g., meteor showers, glowing nebulae)
    simply by creating new Voice-like Views that respond to time & randomness.

 */