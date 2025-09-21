//
// UltimateAnatomyPhysiologyUniverse.swift
// By Cazzy
//
// Fully immersive interactive anatomy & physiology universe
// Animated interactions, multi-step processes, procedural discovery, gamification
//

import SwiftUI
import AVFoundation

// MARK: - Systems / Organs
enum OrganSystem: String, CaseIterable {
    case heart = "Heart"
    case lung = "Lung"
    case brain = "Brain"
    case kidney = "Kidney"
    case stomach = "Stomach"
    case liver = "Liver"
    case artery = "Artery"
    case vein = "Vein"
    case discovered = "Mystery System"
}

// MARK: - Organ / Cell Model
struct Organ: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let system: OrganSystem
    var color: Color
    var size: CGFloat = 70
    var discoveryLevel: Int = 0
}

// MARK: - Physiology Engine
struct PhysiologyEngine {
    // Multi-step physiological processes
    static func interact(_ a: Organ, _ b: Organ) -> (String, [Organ]) {
        switch (a.system, b.system) {
        case (.heart, .artery):
            return ("❤️ Circulation activated! Blood flows from \(a.name) through \(b.name).", [])
        case (.lung, .heart):
            return ("💨 Gas exchange initiated! Oxygen from \(a.name) delivered by \(b.name).", [])
        case (.stomach, .liver):
            return ("🍽 Digestion & metabolism linked! Nutrients processed.", [])
        default:
            if let newOrgan = DiscoveryEngine.discover(a, b) {
                return ("🌟 Discovered new process: \(newOrgan.name)!", [newOrgan])
            }
            return ("⚠️ No significant interaction.", [])
        }
    }
}

// MARK: - Procedural Discovery Engine
struct DiscoveryEngine {
    static func discover(_ a: Organ, _ b: Organ) -> Organ? {
        // Example procedural discoveries
        if (a.system == .kidney && b.system == .liver) {
            return Organ(name: "Detoxification Loop", system: .discovered, color: .purple, size: 80, discoveryLevel: 1)
        }
        if (a.system == .brain && b.system == .heart) {
            return Organ(name: "Neurocardiac Pathway", system: .discovered, color: .magenta, size: 80, discoveryLevel: 1)
        }
        return nil
    }
}

// MARK: - Lab ViewModel
class AnatomyLab: ObservableObject {
    @Published var organs: [Organ] = [
        Organ(name: "Heart", system: .heart, color: .red),
        Organ(name: "Lung", system: .lung, color: .blue),
        Organ(name: "Brain", system: .brain, color: .purple),
        Organ(name: "Kidney", system: .kidney, color: .green),
        Organ(name: "Stomach", system: .stomach, color: .orange)
    ]
    
    @Published var interactionMessage: String = "Drag organs together to activate processes or discover new ones!"
    @Published var score: Int = 0
    @Published var badges: [String] = []
    var player: AVAudioPlayer?
    
    func handleInteraction(message: String, products: [Organ]) {
        if message.contains("🌟") || message.contains("❤️") || message.contains("💨") {
            score += 10
            if score % 30 == 0 { badges.append("🏆 System Master!") }
            organs.append(contentsOf: products)
            playSound("success")
        } else { playSound("fail") }
        interactionMessage = message
    }
    
    func playSound(_ type: String) {
        guard let url = Bundle.main.url(forResource: type, withExtension: "mp3") else { return }
        do { player = try AVAudioPlayer(contentsOf: url); player?.play() } catch { print("Audio error") }
    }
}

// MARK: - Main Lab View
struct AnatomyLabView: View {
    @StateObject private var lab = AnatomyLab()
    @State private var time: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.black, .purple, .indigo]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 10) {
                    Text("🧬 Ultimate Anatomy & Physiology Universe")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    
                    Text(lab.interactionMessage)
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Score: \(lab.score)")
                        .foregroundColor(.green)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(lab.badges, id: \.self) { badge in
                                Text(badge)
                                    .font(.caption)
                                    .foregroundColor(.pink)
                                    .padding(4)
                                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.1)))
                            }
                        }
                    }.frame(height: 30)
                }.padding()
                
                Spacer()
                
                ZStack {
                    ForEach(lab.organs) { organ in
                        AnimatedOrganView(organ: organ, lab: lab, time: $time)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 100).repeatForever(autoreverses: false)) { time = 100 }
        }
    }
}

// MARK: - Animated Organ View
struct AnimatedOrganView: View {
    let organ: Organ
    @ObservedObject var lab: AnatomyLab
    @Binding var time: Double
    @State private var position = CGSize.zero
    @State private var lastPosition = CGSize.zero
    @State private var showParticles = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(organ.color)
                .frame(width: organ.size, height: organ.size)
                .overlay(Text(organ.system.rawValue.prefix(1)).foregroundColor(.white).bold())
                .shadow(color: organ.color.opacity(0.8), radius: 15)
            
            if showParticles {
                ForEach(0..<12, id: \.self) { i in
                    Circle()
                        .fill(organ.color.opacity(0.3))
                        .frame(width: CGFloat.random(in: 5...20), height: CGFloat.random(in: 5...20))
                        .offset(x: CGFloat.random(in: -60...60), y: CGFloat.random(in: -60...60))
                        .blur(radius: CGFloat.random(in: 1...5))
                        .opacity(0.5)
                }
            }
        }
        .offset(x: position.width, y: position.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    position = CGSize(width: value.translation.width + lastPosition.width,
                                      height: value.translation.height + lastPosition.height)
                }
                .onEnded { _ in
                    lastPosition = position
                    triggerInteraction()
                }
        )
        .animation(.spring(), value: position)
    }
    
    private func triggerInteraction() {
        for other in lab.organs where other.id != organ.id {
            let dx = position.width
            let dy = position.height
            if hypot(dx, dy) < 50 {
                let (message, products) = PhysiologyEngine.interact(organ, other)
                showParticles = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showParticles = false }
                lab.handleInteraction(message: message, products: products)
            }
        }
    }
}

// MARK: - Run App
@main
struct RunUltimateAnatomyLab: App {
    var body: some Scene {
        WindowGroup {
            AnatomyLabView()
        }
    }
}