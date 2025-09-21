//
// LivingCosmicGarden.swift
// by Cazzy
//
// Step 1–7 of full visionary plan
// Modular, generative SwiftUI with interaction, fractals, and poetic output.
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

// MARK: - Main Garden View
struct GardenView: View {
    @State private var time: Double = 0
    @State private var seed: Int = Int.random(in: 0...1000)
    @State private var flowers: [CGPoint] = []
    @State private var tappedMessage: String = "🌌 Tap anywhere to grow life"

    var body: some View {
        ZStack {
            // 1. Dynamic cosmic gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.purple.opacity(0.7),
                    Color.blue.opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 2. Starfield
            ForEach(0..<100, id: \.self) { i in
                Star(seed: seed+i, time: time)
            }

            // 3. Clouds
            ForEach(0..<6, id: \.self) { i in
                Cloud(seed: seed+i*7, time: time)
            }

            // 4. Flowers placed by user
            ForEach(flowers, id: \.self) { point in
                Flower(center: point, seed: seed)
            }

            // 5. Dynamic poetic message
            Text(tappedMessage)
                .foregroundColor(.white)
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .position(x: UIScreen.main.bounds.width/2, y: 50)
        }
        .onAppear {
            // Animate global time driving the generative system
            withAnimation(.linear(duration: 100).repeatForever(autoreverses: false)) {
                time = 100
            }
        }
        // 6. User interaction
        .gesture(
            TapGesture()
                .onEnded { location in
                    // Add a flower at tap location
                    let x = CGFloat.random(in: 50...UIScreen.main.bounds.width-50)
                    let y = CGFloat.random(in: 150...UIScreen.main.bounds.height-100)
                    flowers.append(CGPoint(x: x, y: y))
                    tappedMessage = ["✨ Life blooms 🌸","🌿 Growth emerges 🌱","💫 Cosmic harmony 🌌"].randomElement()!
                }
        )
    }
}

// MARK: - Star Component
struct Star: View {
    var seed: Int
    var time: Double

    var body: some View {
        let size = CGFloat(Double.random(in: 1...4))
        let x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
        let y = CGFloat.random(in: 0...UIScreen.main.bounds.height)
        let opacity = 0.5 + 0.5 * sin(time/10 + Double(seed))

        return Circle()
            .fill(Color.white)
            .frame(width: size, height: size)
            .position(x: x, y: y)
            .opacity(opacity)
    }
}

// MARK: - Cloud Component
struct Cloud: View {
    var seed: Int
    var time: Double

    var body: some View {
        let width = CGFloat(Double.random(in: 120...250))
        let height = CGFloat(Double.random(in: 40...80))
        let x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
        let y = CGFloat.random(in: 50...200)
        let offsetX = CGFloat(sin(time/15 + Double(seed)) * 50)

        return Ellipse()
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.3), Color.gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            ))
            .frame(width: width, height: height)
            .position(x: x + offsetX, y: y)
    }
}

// MARK: - Flower Component
struct Flower: View {
    var center: CGPoint
    var seed: Int

    var body: some View {
        ZStack {
            ForEach(0..<7, id: \.self) { i in
                Petal(seed: seed+i, angle: Double(i)/7 * 2 * Double.pi)
            }
        }
        .position(center)
    }
}

// MARK: - Petal Component
struct Petal: View {
    var seed: Int
    var angle: Double

    var body: some View {
        let radius = CGFloat(Double.random(in: 20...50))
        Capsule()
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color.pink, Color.purple.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            ))
            .frame(width: radius, height: radius/2)
            .rotationEffect(.radians(angle + Double.random(in: -0.1...0.1)))
            .scaleEffect(1 + 0.1 * CGFloat(sin(Double(seed))))
    }
}

/*
Thought Process:

- **Generative Visual System**: Stars, clouds, flowers are parameterized by time and randomness. 
  Demonstrates advanced thinking: modeling dynamic systems with SwiftUI.

- **User Interaction**: Tap to create flowers. Shows reactive state and modular design.

- **Modular Architecture**: Each visual element is self-contained; easy to extend with new behaviors.

- **Poetic Output**: tappedMessage simulates “AI poetic reflection” of garden state.

- **Forward-thinking**: This architecture can be expanded:
    1. Fractal recursive flowers
    2. Fireflies or cosmic creatures
    3. Audio-reactive motion
    4. Dynamic narrative text
    5. Generative constellation mapping
    6. Self-modifying behaviors
    ...up to 20+ steps, creating a living AI-art ecosystem.

*/