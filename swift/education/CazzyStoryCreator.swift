//
// ReadWithCazzyStoryCreator.swift
// By Cazzy
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Story Entity
struct StoryWordEntity: Identifiable {
    let id = UUID()
    var word: String
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var velocity: CGSize
}

// MARK: - Story Lab
class StoryLab: ObservableObject {
    @Published var words: [StoryWordEntity] = []
    @Published var storyText: String = ""
    @Published var message: String = "🌈 Start building your story!"
    
    let pastelColors: [Color] = [.pink,.mint,.lavender,.peach,.skyBlue,.lemon,.apricot,.periwinkle,.rose,.aqua]
    let synthesizer = AVSpeechSynthesizer()
    
    // Predictive word bank (emergent suggestions)
    let wordBank: [String] = ["cat","dog","sun","tree","garden","play","jump","run","adventure","magic","friend","happy","bright","flower"]
    
    func addWord(_ word: String, position: CGPoint){
        let entity = StoryWordEntity(
            word: word,
            position: position,
            color: pastelColors.randomElement() ?? .mint,
            size: CGFloat.random(in:30...50),
            velocity: CGSize(width: CGFloat.random(in:-1...1), height: CGFloat.random(in:-1...1))
        )
        words.append(entity)
        storyText += " \(word)"
        speak(word)
        message = "✅ Added '\(word)' to your story!"
    }
    
    func speak(_ text: String){
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.45
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    func predictNextWords() -> [String] {
        // Simple emergent prediction: 5 random words from the bank
        return wordBank.shuffled().prefix(5).map{ $0 }
    }
    
    func updateWords(){
        for i in words.indices {
            var w = words[i]
            w.position.x += w.velocity.width
            w.position.y += w.velocity.height
            let screen = UIScreen.main.bounds
            if w.position.x < 0 || w.position.x > screen.width { w.velocity.width *= -1 }
            if w.position.y < 0 || w.position.y > screen.height { w.velocity.height *= -1 }
            words[i] = w
        }
    }
}

// MARK: - Word View
struct StoryWordView: View {
    var wordEntity: StoryWordEntity
    var body: some View {
        Text(wordEntity.word)
            .font(.system(size: wordEntity.size/2, weight: .bold))
            .foregroundColor(.white)
            .padding(8)
            .background(wordEntity.color.opacity(0.8))
            .cornerRadius(12)
            .shadow(radius: 5)
    }
}

// MARK: - Main Story Creator View
struct ReadWithCazzyStoryView: View {
    @StateObject var lab = StoryLab()
    @State private var timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    @State private var inputWord: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.mint.opacity(0.3), .pink.opacity(0.3), .lavender.opacity(0.3), .peach.opacity(0.3)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            ForEach(lab.words){ word in
                StoryWordView(wordEntity: word)
                    .position(word.position)
            }
            
            VStack {
                Spacer()
                VStack(spacing: 6){
                    Text("Story: \(lab.storyText)")
                        .foregroundColor(.white)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(10)
                    
                    HStack {
                        TextField("Type a word...", text: $inputWord)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Add") {
                            guard !inputWord.isEmpty else { return }
                            lab.addWord(inputWord, position: CGPoint(x: CGFloat.random(in:50...350), y: CGFloat.random(in:200...600)))
                            inputWord = ""
                        }
                    }.padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(lab.predictNextWords(), id: \.self) { word in
                                Button(word) { 
                                    lab.addWord(word, position: CGPoint(x: CGFloat.random(in:50...350), y: CGFloat.random(in:200...600)))
                                }
                                .padding(6)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(8)
                            }
                        }.padding(.horizontal)
                    }
                    
                    Text(lab.message)
                        .foregroundColor(.yellow)
                        .bold()
                        .padding(.top, 5)
                }
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(15)
                .padding()
            }
        }
        .onReceive(timer){ _ in lab.updateWords() }
    }
}

// MARK: - Preview
struct ReadWithCazzyStoryView_Previews: PreviewProvider {
    static var previews: some View {
        ReadWithCazzyStoryView()
    }
}