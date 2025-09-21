//
// ReadWithCazzyAdaptive.swift
// By Cazzy
//
// Interactive Reading Tutor with Adaptive Learning and Speech
//

import SwiftUI
import Combine
import AVFoundation

// MARK: - Lesson Entity
struct ReadingLessonEntity: Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var velocity: CGSize
    var type: LessonType
    var difficulty: Int
}

enum LessonType {
    case phonics
    case word
    case sentence
    case story
    case quiz
}

// MARK: - Adaptive Reading Lab
class AdaptiveReadingLab: ObservableObject {
    @Published var entities: [ReadingLessonEntity] = []
    @Published var message: String = "👋 Welcome to ReadWithCazzy! Tap letters, words, and stories to start learning."
    @Published var score: Int = 0
    
    let pastelColors: [Color] = [.pink, .mint, .lavender, .peach, .skyBlue, .lemon, .apricot, .periwinkle, .rose, .aqua]
    let synthesizer = AVSpeechSynthesizer()
    
    var userPerformance: [LessonType: Int] = [.phonics:0, .word:0, .sentence:0, .story:0, .quiz:0]
    
    init() { spawnEntities(count: 30) }
    
    func spawnEntities(count: Int){
        for i in 0..<count {
            let type: LessonType = [.phonics, .word, .sentence, .story, .quiz].randomElement()!
            let difficulty = Int.random(in: 1...3)
            let content = generateContent(type: type, difficulty: difficulty)
            
            let entity = ReadingLessonEntity(
                title: "\(type) \(i+1)",
                content: content,
                position: CGPoint(x: CGFloat.random(in:50...350), y: CGFloat.random(in:100...700)),
                color: pastelColors.randomElement() ?? .mint,
                size: CGFloat.random(in:40...70),
                velocity: CGSize(width: CGFloat.random(in:-1...1), height: CGFloat.random(in:-1...1)),
                type: type,
                difficulty: difficulty
            )
            entities.append(entity)
        }
    }
    
    func generateContent(type: LessonType, difficulty: Int) -> String {
        switch type {
        case .phonics:
            let letters = ["A","B","C","D","E","F","G","H","I","J","K","L"]
            return letters.randomElement()!
        case .word:
            let easy = ["cat","dog","sun","ball"]
            let medium = ["flower","guitar","window","circle"]
            let hard = ["adventure","elephant","imagination","butterfly"]
            if difficulty == 1 { return easy.randomElement()! }
            else if difficulty == 2 { return medium.randomElement()! }
            else { return hard.randomElement()! }
        case .sentence:
            let easy = ["I see a cat.","The sun is bright."]
            let medium = ["The cat chased the butterfly.","We played ball in the garden."]
            let hard = ["Imagination opens doors to countless adventures.","Elephants are amazing intelligent creatures."]
            if difficulty == 1 { return easy.randomElement()! }
            else if difficulty == 2 { return medium.randomElement()! }
            else { return hard.randomElement()! }
        case .story:
            let easy = "Once upon a time, a little cat explored the garden."
            let medium = "In a sunny village, children played while learning about the animals around them."
            let hard = "Deep in the magical forest, imagination and curiosity guided the young explorers through endless adventures."
            if difficulty == 1 { return easy }
            else if difficulty == 2 { return medium }
            else { return hard }
        case .quiz:
            let quizzes = ["Tap the word that starts with 'S'.","Which word rhymes with 'cat'?","Select the correct sentence."]
            return quizzes.randomElement()!
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
    }
    
    func speak(_ text: String){
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.45
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    func interactWith(entity: ReadingLessonEntity){
        let type = entity.type
        userPerformance[type, default:0] += 1
        
        // Adjust difficulty based on performance
        var newDifficulty = entity.difficulty
        if userPerformance[type, default:0] % 3 == 0 {
            newDifficulty = min(entity.difficulty + 1, 3) // increase difficulty
        } else if userPerformance[type, default:0] % 5 == 0 {
            newDifficulty = max(entity.difficulty - 1, 1) // sometimes lower to scaffold
        }
        
        message = "✅ \(entity.content)"
        score += newDifficulty
        
        speak(entity.content)
        
        // Spawn new entity based on adapted difficulty
        let newEntity = ReadingLessonEntity(
            title: "Adaptive \(type) lesson",
            content: generateContent(type: type, difficulty: newDifficulty),
            position: CGPoint(x: CGFloat.random(in:50...350), y: CGFloat.random(in:100...700)),
            color: pastelColors.randomElement() ?? .mint,
            size: CGFloat.random(in:40...70),
            velocity: CGSize(width: CGFloat.random(in:-1...1), height: CGFloat.random(in:-1...1)),
            type: type,
            difficulty: newDifficulty
        )
        entities.append(newEntity)
    }
}

// MARK: - Entity View
struct ReadingLessonEntityView: View {
    var entity: ReadingLessonEntity
    var body: some View {
        Text(entity.content)
            .font(.system(size: entity.size/2, weight: .bold))
            .foregroundColor(.white)
            .padding(8)
            .background(entity.color.opacity(0.8))
            .cornerRadius(12)
            .shadow(radius: 5)
    }
}

// MARK: - Main View
struct ReadWithCazzyView: View {
    @StateObject var lab = AdaptiveReadingLab()
    @State private var timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.mint.opacity(0.3), .pink.opacity(0.3), .lavender.opacity(0.3), .peach.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            ForEach(lab.entities){ entity in
                ReadingLessonEntityView(entity: entity)
                    .position(entity.position)
                    .onTapGesture { lab.interactWith(entity: entity) }
            }
            
            VStack {
                Spacer()
                VStack(spacing: 6){
                    Text(lab.message)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                    Text("Score: \(lab.score) ⭐️")
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
            DragGesture(minimumDistance: 0)
                .onChanged{ value in
                    let newEntity = ReadingLessonEntity(
                        title: "Adaptive New Lesson",
                        content: ["A","B","C","cat","dog","The sun is bright"].randomElement()!,
                        position: value.location,
                        color: lab.pastelColors.randomElement() ?? .mint,
                        size: CGFloat.random(in:30...60),
                        velocity: CGSize(width: CGFloat.random(in:-1...1), height: CGFloat.random(in:-1...1)),
                        type: [.phonics,.word,.sentence,.story,.quiz].randomElement()!,
                        difficulty: 1
                    )
                    lab.entities.append(newEntity)
                    lab.message = "🌈 You created a new interactive reading lesson!"
                    lab.speak(newEntity.content)
                }
        )
    }
}

// MARK: - Preview
struct ReadWithCazzyView_Previews: PreviewProvider {
    static var previews: some View {
        ReadWithCazzyView()
    }
}