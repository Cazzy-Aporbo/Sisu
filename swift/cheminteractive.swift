//
// UltimateChemistryUniverse.swift
// By Cazzy
//
// Fully immersive interactive chemistry lab
// Animated reactions, multi-step mechanics, procedural discovery, gamification, narrative
//

import SwiftUI
import AVFoundation

// MARK: - Functional Groups
enum FunctionalGroup: String, CaseIterable {
    case alcohol = "Alcohol"
    case ketone = "Ketone"
    case aldehyde = "Aldehyde"
    case carboxylicAcid = "Acid"
    case amine = "Amine"
    case ester = "Ester"
    case imine = "Imine"
    case discovered = "Mystery"
}

// MARK: - Molecule Model
struct Molecule: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let group: FunctionalGroup
    var color: Color
    var size: CGFloat = 70
    var discoveryLevel: Int = 0
}

// MARK: - Reaction Engine
struct ReactionEngine {
    // Multi-step reactions
    static func react(_ a: Molecule, _ b: Molecule) -> (String, [Molecule]) {
        switch (a.group, b.group) {
        case (.alcohol, .carboxylicAcid):
            let product = Molecule(name: "Ester", group: .ester, color: .pink)
            return ("✅ Esterification! \(a.name) + \(b.name) → Ester", [product])
        case (.ketone, .amine):
            let product = Molecule(name: "Imine", group: .imine, color: .purple)
            return ("✅ Imine Formation! \(a.name) + \(b.name)", [product])
        case (.aldehyde, .alcohol):
            let product = Molecule(name: "Hemiacetal", group: .ester, color: .teal)
            return ("✅ Hemiacetal Formation!", [product])
        default:
            // Attempt procedural discovery
            if let newMolecule = DiscoveryEngine.discover(a, b) {
                return ("🌟 You discovered a new molecule: \(newMolecule.name)!", [newMolecule])
            }
            return ("⚠️ No reaction occurs.", [])
        }
    }
}

// MARK: - Procedural Discovery Engine
struct DiscoveryEngine {
    static func discover(_ a: Molecule, _ b: Molecule) -> Molecule? {
        // Example procedural discovery rules
        if (a.group == .alcohol && b.group == .ketone) {
            return Molecule(name: "MysticCompound", group: .discovered, color: .magenta, size: 80, discoveryLevel: 1)
        }
        if (a.group == .amine && b.group == .aldehyde) {
            return Molecule(name: "NovaMolecule", group: .discovered, color: .orange, size: 80, discoveryLevel: 1)
        }
        return nil
    }
}

// MARK: - Lab ViewModel
class ChemistryLab: ObservableObject {
    @Published var molecules: [Molecule] = [
        Molecule(name: "Ethanol", group: .alcohol, color: .blue),
        Molecule(name: "Acetic Acid", group: .carboxylicAcid, color: .red),
        Molecule(name: "Acetone", group: .ketone, color: .purple),
        Molecule(name: "Formaldehyde", group: .aldehyde, color: .green),
        Molecule(name: "Methylamine", group: .amine, color: .orange)
    ]
    
    @Published var reactionMessage: String = "Drag molecules together to react or discover new compounds!"
    @Published var score: Int = 0
    @Published var badges: [String] = []
    var player: AVAudioPlayer?
    
    func handleReaction(message: String, products: [Molecule]) {
        if message.contains("✅") || message.contains("🌟") {
            score += 10
            if score % 30 == 0 { badges.append("🔬 Reaction Master!") }
            molecules.append(contentsOf: products)
            playSound("success")
        } else { playSound("fail") }
        reactionMessage = message
    }
    
    func playSound(_ type: String) {
        // Placeholder for audio
        // Use your own mp3 files named "success.mp3" and "fail.mp3"
        guard let url = Bundle.main.url(forResource: type, withExtension: "mp3") else { return }
        do { player = try AVAudioPlayer(contentsOf: url); player?.play() } catch { print("Audio error") }
    }
}

// MARK: - Main Lab View
struct ChemistryLabView: View {
    @StateObject private var lab = ChemistryLab()
    @State private var time: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.black, .indigo, .purple]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 10) {
                    Text("🌌 Ultimate Chemistry Universe")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    
                    Text(lab.reactionMessage)
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
                    ForEach(lab.molecules) { molecule in
                        AnimatedMoleculeView(molecule: molecule, lab: lab, time: $time)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 100).repeatForever(autoreverses: false)) { time = 100 }
        }
    }
}

// MARK: - Animated Molecule View
struct AnimatedMoleculeView: View {
    let molecule: Molecule
    @ObservedObject var lab: ChemistryLab
    @Binding var time: Double
    @State private var position = CGSize.zero
    @State private var lastPosition = CGSize.zero
    @State private var showReactionParticles = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(molecule.color)
                .frame(width: molecule.size, height: molecule.size)
                .overlay(Text(molecule.group.rawValue.prefix(1)).foregroundColor(.white).bold())
                .shadow(color: molecule.color.opacity(0.8), radius: 15)
            
            if showReactionParticles {
                ForEach(0..<12, id: \.self) { i in
                    Circle()
                        .fill(molecule.color.opacity(0.3))
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
                    triggerReaction()
                }
        )
        .animation(.spring(), value: position)
    }
    
    private func triggerReaction() {
        for other in lab.molecules where other.id != molecule.id {
            let dx = position.width
            let dy = position.height
            if hypot(dx, dy) < 50 {
                let (message, products) = ReactionEngine.react(molecule, other)
                showReactionParticles = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showReactionParticles = false }
                lab.handleReaction(message: message, products: products)
            }
        }
    }
}

// MARK: - Run App
@main
struct RunUltimateChemistryUniverse: App {
    var body: some Scene {
        WindowGroup {
            ChemistryLabView()
        }
    }
}