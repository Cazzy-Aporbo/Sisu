//
// Luminara.swift
// By Cazzy
//
// Ultimate Pastel Imagination Universe
// Floating entities, emergent interactions, procedural poetry, infinite exploration
//

import SwiftUI
import Combine
import AVFoundation

// MARK: - Luminara Entity
struct LuminaraEntity: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var velocity: CGSize
    var glow: Bool = true
    var personality: String
}

// MARK: - Luminara Lab ViewModel
class LuminaraLab: ObservableObject {
    @Published var entities: [LuminaraEntity] = []
    @Published var message: String = "✨ Welcome to Luminara — a living universe of pastel imagination ✨"
    @Published var score: Int = 0
    
    let pastelColors: [Color] = [
        .pink, .mint, .lavender, .peach, .skyBlue, .lemon, .apricot, .periwinkle, .rose, .aqua
    ]
    
    let personalities = ["playful","calm","curious","dreamy","mysterious","joyful"]
    
    var timer: AnyCancellable?
    
    init(){
        spawnEntities(count: 50)
        startSimulation()
    }
    
    func spawnEntities(count:Int){
        for i in 0..<count {
            let entity = LuminaraEntity(
                name: "Spirit \(i+1)",
                position: CGPoint(x: CGFloat.random(in:50...350), y: CGFloat.random(in:100...700)),
                color: pastelColors.randomElement() ?? .pink,
                size: CGFloat.random(in:20...60),
                velocity: CGSize(width: CGFloat.random(in:-1.5...1.5), height: CGFloat.random(in:-1.5...1.5)),
                personality: personalities.randomElement() ?? "playful"
            )
            entities.append(entity)
        }
    }
    
    func startSimulation(){
        timer = Timer.publish(every:0.016, on:.main, in:.common).autoconnect().sink{ [weak self] _ in
            self?.updateEntities()
        }
    }
    
    func updateEntities(){
        for i in entities.indices {
            var e = entities[i]
            e.position.x += e.velocity.width
            e.position.y += e.velocity.height
            
            // Bounce off edges
            let screen = UIScreen.main.bounds
            if e.position.x < 0 || e.position.x > screen.width { e.velocity.width *= -1 }
            if e.position.y < 0 || e.position.y > screen.height { e.velocity.height *= -1 }
            
            // Slight random drift
            e.velocity.width += CGFloat.random(in:-0.05...0.05)
            e.velocity.height += CGFloat.random(in:-0.05...0.05)
            
            entities[i] = e
        }
        
        // Rare emergent event
        if Double.random(in:0...1) > 0.995 {
            message = "🌟 A rare luminous bloom emerges, a secret of Luminara!"
            score += 5
        }
    }
    
    func interactWith(entity: LuminaraEntity){
        message = "✨ You touched \(entity.name), a \(entity.personality) spirit. It shimmers in \(entity.color.description)."
        // Spawn a small companion entity
        let companion = LuminaraEntity(
            name: "Companion of \(entity.name)",
            position: CGPoint(x: entity.position.x + CGFloat.random(in:-30...30),
                              y: entity.position.y + CGFloat.random(in:-30...30)),
            color: pastelColors.randomElement() ?? .mint,
            size: CGFloat.random(in:15...40),
            velocity: CGSize(width: CGFloat.random(in:-1...1), height: CGFloat.random(in:-1...1)),
            personality: personalities.randomElement() ?? "dreamy"
        )
        entities.append(companion)
        score += 1
    }
}

// MARK: - Luminara Entity View
struct LuminaraEntityView: View {
    var entity: LuminaraEntity
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

// MARK: - Main Luminara View
struct LuminaraView: View {
    @StateObject var lab = LuminaraLab()
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors:[
                Color.pink.opacity(0.3),
                Color.mint.opacity(0.3),
                Color.lavender.opacity(0.3),
                Color.peach.opacity(0.3)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            // Floating entities
            ForEach(lab.entities){ entity in
                LuminaraEntityView(entity: entity)
                    .position(entity.position)
                    .onTapGesture{
                        lab.interactWith(entity: entity)
                    }
            }
            
            VStack{
                Spacer()
                VStack(spacing:8){
                    Text(lab.message)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Score: \(lab.score)")
                        .foregroundColor(.yellow)
                        .bold()
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .padding()
            }
        }
        .gesture(
            DragGesture(minimumDistance:0)
                .onChanged{ value in
                    // spawn new drifting entity at drag location
                    let newEntity = LuminaraEntity(
                        name: "New Spirit",
                        position: value.location,
                        color: lab.pastelColors.randomElement() ?? .mint,
                        size: CGFloat.random(in:20...50),
                        velocity: CGSize(width: CGFloat.random(in:-1...1), height: CGFloat.random(in:-1...1)),
                        personality: lab.personalities.randomElement() ?? "joyful"
                    )
                    lab.entities.append(newEntity)
                    lab.message = "🌈 A new pastel spirit appears!"
                }
        )
    }
}

// MARK: - Preview
struct LuminaraView_Previews: PreviewProvider {
    static var previews: some View {
        LuminaraView()
    }
}