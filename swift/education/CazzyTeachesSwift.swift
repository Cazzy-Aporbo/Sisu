//
// CazzyTeachesSwiftUltimate.swift
// By Cazzy
//
// Ultimate Interactive Swift Learning Universe
// Living lessons, emergent interactions, gamified quizzes, pastel magic
//

import SwiftUI
import Combine
import AVFoundation

// MARK: - Lesson Entity
struct LessonEntity: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var velocity: CGSize
    var type: LessonType
}

enum LessonType {
    case concept
    case quiz
    case interactiveDemo
}

// MARK: - Swift Universe Lab
class SwiftUniverseLab: ObservableObject {
    @Published var entities: [LessonEntity] = []
    @Published var message: String = "✨ Welcome to CazzyTeachesSwift — dive into Swift magic! ✨"
    @Published var score: Int = 0
    
    let pastelColors: [Color] = [.pink, .mint, .lavender, .peach, .skyBlue, .lemon, .apricot, .periwinkle, .rose, .aqua]
    
    init(){
        spawnEntities(count: 50)
    }
    
    func spawnEntities(count:Int){
        for i in 0..<count {
            let type: LessonType = [.concept, .quiz, .interactiveDemo].randomElement()!
            let entity = LessonEntity(
                title: type == .concept ? "Concept \(i+1)" : (type == .quiz ? "Quiz \(i+1)" : "Demo \(i+1)"),
                description: "Explore Swift interactively!",
                position: CGPoint(x: CGFloat.random(in:50...350), y: CGFloat.random(in:100...700)),
                color: pastelColors.randomElement() ?? .mint,
                size: CGFloat.random(in:30...60),
                velocity: CGSize(width: CGFloat.random(in:-1.5...1.5), height: CGFloat.random(in:-1.5...1.5)),
                type: type
            )
            entities.append(entity)
        }
    }
    
    func updateEntities(){
        for i in entities.indices {
            var e = entities[i]
            e.position.x += e.velocity.width
            e.position.y += e.velocity.height
            let screen = UIScreen.main.bounds
            if e.position.x < 0 || e.position.x > screen.width { e.velocity.width *= -1 }
            if e.position.y < 0 || e.position.y > screen.height { e.velocity.height *= -1 }
            e.velocity.width += CGFloat.random(in:-0.05...0.05)
            e.velocity.height += CGFloat.random(in:-0.05...0.05)
            entities[i] = e
        }
        // Rare emergent learning surprise
        if Double.random(in:0...1) > 0.995 {
            message = "🌟 Hidden Swift Tip: You can chain optionals elegantly with `?` and `??`!"
        }
    }
    
    func interactWith(entity: LessonEntity){
        switch entity.type {
        case .concept:
            message = "📖 You explored \(entity.title)! Mini lesson: \(entity.description)"
            score += 1
        case .quiz:
            // Random quiz question
            let answer = Bool.random()
            message = answer ? "✅ Correct! Keep exploring Swift’s wonders!" : "❌ Oops! Try again — every mistake teaches!"
            score += answer ? 2 : 0
        case .interactiveDemo:
            message = "⚡ Interactive Demo: See Swift in action and experiment freely!"
            score += 1
        }
        
        // Spawn companion entity for emergent play
        let companion = LessonEntity(
            title: "Companion of \(entity.title)",
            description: "A playful guide to help you explore Swift.",
            position: CGPoint(x: entity.position.x + CGFloat.random(in:-30...30), y: entity.position.y + CGFloat.random(in:-30...30)),
            color: pastelColors.randomElement() ?? .mint,
            size: CGFloat.random(in:20...50),
            velocity: CGSize(width: CGFloat.random(in:-1...1), height: CGFloat.random(in:-1...1)),
            type: .concept
        )
        entities.append(companion)
    }
}

// MARK: - Entity View
struct LessonEntityView: View {
    var entity: LessonEntity
    var body: some View {
        Circle()
            .fill(entity.color.opacity(0.7))
            .frame(width: entity.size, height: entity.size)
            .shadow(color: entity.color.opacity(0.5), radius: 10)
            .overlay(
                Circle()
                    .stroke(entity.color.opacity(0.5), lineWidth: 1)
            )
            .overlay(
                Text(entity.type == .quiz ? "❓" : entity.type == .interactiveDemo ? "⚡" : "📖")
                    .font(.caption)
                    .foregroundColor(.white)
            )
    }
}

// MARK: - Main CazzyTeachesSwift View
struct CazzyTeachesSwiftView: View {
    @StateObject var lab = SwiftUniverseLab()
    @State private var timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors:[
                Color.mint.opacity(0.3),
                Color.pink.opacity(0.3),
                Color.lavender.opacity(0.3),
                Color.peach.opacity(0.3)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            ForEach(lab.entities){ entity in
                LessonEntityView(entity: entity)
                    .position(entity.position)
                    .onTapGesture { lab.interactWith(entity: entity) }
            }
            
            VStack{
                Spacer()
                VStack(spacing:6){
                    Text(lab.message)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Score: \(lab.score) 🌟")
                        .foregroundColor(.yellow)
                        .bold()
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .padding()
            }
        }
        .onReceive(timer){ _ in lab.updateEntities() }
        .gesture(
            DragGesture(minimumDistance:0)
                .onChanged{ value in
                    let newEntity = LessonEntity(
                        title: "New Lesson",
                        description: "Interactive Swift exploration!",
                        position: value.location,
                        color: lab.pastelColors.randomElement() ?? .mint,
                        size: CGFloat.random(in:20...50),
                        velocity: CGSize(width: CGFloat.random(in:-1...1), height: CGFloat.random(in:-1...1)),
                        type: [.concept,.quiz,.interactiveDemo].randomElement()!
                    )
                    lab.entities.append(newEntity)
                    lab.message = "🌈 You created a new emergent Swift lesson!"
                }
        )
    }
}

// MARK: - Preview
struct CazzyTeachesSwiftView_Previews: PreviewProvider {
    static var previews: some View {
        CazzyTeachesSwiftView()
    }
}