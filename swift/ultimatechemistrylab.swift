//
// UltimateChemistryLab.swift
// By Cazzy
//
// Immersive PhD-level Chemistry Game/Teaching Tool
// Functional Groups, Molecules, Reactions, Gamified, Visual, Poetic
//

import SwiftUI

// MARK: - Functional Groups
enum FunctionalGroup: String, CaseIterable {
    case alcohol = "Alcohol"
    case ketone = "Ketone"
    case aldehyde = "Aldehyde"
    case carboxylicAcid = "Acid"
    case amine = "Amine"
    case ester = "Ester"
}

// MARK: - Molecule Model
struct Molecule: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let group: FunctionalGroup
    var color: Color
}

// MARK: - Reaction Engine
struct ReactionEngine {
    static func react(_ a: Molecule, _ b: Molecule) -> String {
        switch (a.group, b.group) {
        case (.alcohol, .carboxylicAcid):
            return "✅ Esterification! \(a.name) + \(b.name) → Ester"
        case (.ketone, .amine):
            return "✅ Imine formation! \(a.name) + \(b.name)"
        case (.aldehyde, .alcohol):
            return "✅ Hemiacetal formation!"
        default:
            return "⚠️ No reaction."
        }
    }
}

// MARK: - ViewModel
class ChemistryLab: ObservableObject {
    @Published var molecules: [Molecule] = [
        Molecule(name: "Ethanol", group: .alcohol, color: .blue),
        Molecule(name: "Acetic Acid", group: .carboxylicAcid, color: .red),
        Molecule(name: "Acetone", group: .ketone, color: .purple),
        Molecule(name: "Formaldehyde", group: .aldehyde, color: .green),
        Molecule(name: "Methylamine", group: .amine, color: .orange)
    ]
    
    @Published var reactionMessage: String = "Drag molecules together to react!"
    @Published var score: Int = 0
    @Published var badges: [String] = []
    
    func handleReaction(message: String) {
        if message.contains("✅") {
            score += 10
            if score % 30 == 0 {
                badges.append("🔬 Reaction Master!")
            }
        }
        reactionMessage = message
    }
}

// MARK: - Main Lab View
struct ChemistryLabView: View {
    @StateObject private var lab = ChemistryLab()
    @State private var time: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.black, .indigo]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                VStack {
                    Text("🎓 Ultimate Chemistry Lab")
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
                                Text(badge).font(.caption).foregroundColor(.pink)
                            }
                        }
                    }.frame(height: 30)
                }
                .padding()
                
                Spacer()
                
                HStack(spacing: 30) {
                    ForEach(lab.molecules) { molecule in
                        MoleculeView(molecule: molecule, lab: lab, time: $time)
                    }
                }.padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 100).repeatForever(autoreverses: false)) {
                time = 100
            }
        }
    }
}

// MARK: - Draggable Molecule View
struct MoleculeView: View {
    let molecule: Molecule
    @ObservedObject var lab: ChemistryLab
    @Binding var time: Double
    @State private var position = CGSize.zero
    @State private var lastPosition = CGSize.zero
    
    var body: some View {
        ZStack {
            Circle()
                .fill(molecule.color)
                .frame(width: 70, height: 70)
                .overlay(Text(molecule.group.rawValue.prefix(1))
                            .foregroundColor(.white)
                            .bold())
                .shadow(color: molecule.color.opacity(0.8), radius: 10)
            
            // Glowing particle effect
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(molecule.color.opacity(0.2))
                    .frame(width: CGFloat.random(in: 5...12), height: CGFloat.random(in: 5...12))
                    .offset(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: -30...30))
                    .blur(radius: CGFloat.random(in: 1...3))
                    .opacity(0.3 + 0.7 * sin(time/5 + Double(i)))
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
                    checkReactions()
                }
        )
        .animation(.spring(), value: position)
    }
    
    private func checkReactions() {
        for other in lab.molecules {
            guard other.id != molecule.id else { continue }
            let dx = position.width - 0 // simplified collision
            let dy = position.height - 0
            if hypot(dx, dy) < 50 {
                let message = ReactionEngine.react(molecule, other)
                lab.handleReaction(message: message)
            }
        }
    }
}

// MARK: - Run
@main
struct RunUltimateChemistryLab: App {
    var body: some Scene {
        WindowGroup {
            ChemistryLabView()
        }
    }
}