//
// Dreamscape.swift
// By Cazzy
//
// Pastel interactive dream world: floating islands, glowing entities, procedural magic
//

import SwiftUI

// MARK: - Floating Entity
struct DreamEntity: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var velocity: CGSize
    var glow: Bool = true
}

// MARK: - Dreamscape ViewModel
class DreamscapeLab: ObservableObject {
    @Published var entities: [DreamEntity] = []
    
    let pastelColors: [Color] = [
        .pink, .mint, .lavender, .peach, .skyBlue, .lemon, .apricot, .periwinkle, .rose, .aqua
    ]
    
    init() {
        spawnEntities(count: 40)
    }
    
    func spawnEntities(count: Int){
        for _ in 0..<count {
            let entity = DreamEntity(
                position: CGPoint(x: CGFloat.random(in: 50...350), y: CGFloat.random(in: 100...700)),
                color: pastelColors.randomElement() ?? .pink,
                size: CGFloat.random(in: 20...60),
                velocity: CGSize(width: CGFloat.random(in: -1.5...1.5), height: CGFloat.random(in: -1.5...1.5))
            )
            entities.append(entity)
        }
    }
    
    func updateEntities(in size: CGSize){
        for i in entities.indices {
            var e = entities[i]
            e.position.x += e.velocity.width
            e.position.y += e.velocity.height
            
            // Bounce off edges
            if e.position.x < 0 || e.position.x > size.width { e.velocity.width *= -1 }
            if e.position.y < 0 || e.position.y > size.height { e.velocity.height *= -1 }
            
            // Slight random drift
            e.velocity.width += CGFloat.random(in: -0.05...0.05)
            e.velocity.height += CGFloat.random(in: -0.05...0.05)
            
            entities[i] = e
        }
    }
}

// MARK: - Entity View
struct EntityView: View {
    var entity: DreamEntity
    var body: some View {
        Circle()
            .fill(entity.color.opacity(0.7))
            .frame(width: entity.size, height: entity.size)
            .shadow(color: entity.color.opacity(0.5), radius: entity.glow ? 10 : 0)
            .overlay(
                Circle()
                    .stroke(entity.color.opacity(0.5), lineWidth: 1)
            )
    }
}

// MARK: - Main Dreamscape View
struct DreamscapeView: View {
    @StateObject var lab = DreamscapeLab()
    @State private var timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    @State private var message: String = "✨ Welcome to your pastel dreamscape. Touch, drag, and explore your imagination ✨"
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors:[
                Color.pink.opacity(0.3),
                Color.mint.opacity(0.3),
                Color.lavender.opacity(0.3),
                Color.peach.opacity(0.3)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            ForEach(lab.entities){ entity in
                EntityView(entity: entity)
                    .position(entity.position)
                    .onTapGesture {
                        message = "🌸 You touched a glowing entity of \(entity.color.description)! Feel the imagination bloom."
                    }
            }
            
            VStack{
                Spacer()
                Text(message)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                    .padding()
            }
        }
        .onReceive(timer){ _ in
            lab.updateEntities(in: UIScreen.main.bounds.size)
        }
        .gesture(
            DragGesture(minimumDistance:0)
                .onChanged{ value in
                    // spawn new entities at drag location
                    let newEntity = DreamEntity(
                        position: value.location,
                        color: lab.pastelColors.randomElement() ?? .pink,
                        size: CGFloat.random(in:20...50),
                        velocity: CGSize(width: CGFloat.random(in:-1...1), height: CGFloat.random(in:-1...1))
                    )
                    lab.entities.append(newEntity)
                    message = "🌈 You created a new pastel bloom!"
                }
        )
    }
}

// MARK: - Preview
struct DreamscapeView_Previews: PreviewProvider {
    static var previews: some View {
        DreamscapeView()
    }
}