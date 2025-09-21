//
// Imagination.swift
// By Cazzy
//
// Ultimate Science Universe: chemistry, anatomy, microbiology, ecology, botany, environmental physiology
// Fully interactive, procedural discovery, gamification, audio-visual immersion, poetic feedback
//

import SwiftUI
import AVFoundation

// MARK: - Entity Types
enum ScienceEntityType: String, CaseIterable {
    // Chemistry
    case alcohol, ketone, aldehyde, carboxylicAcid, amine, ester, imine, unknownMolecule
    // Anatomy/Physiology
    case heart, lung, brain, kidney, stomach, liver, artery, vein, unknownSystem
    // Microbiology & Immunology
    case bacterium, virus, tCell, antibody, unknownMicrobe
    // Botany & Ecology
    case plant, fungus, algae, predator, prey, unknownEcosystem
    // Environmental Physiology / Emergent
    case extremeOrganism, hybridEntity, unknownEmergent
}

// MARK: - Science Entity Model
struct ScienceEntity: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let type: ScienceEntityType
    var color: Color
    var size: CGFloat = 70
    var discoveryLevel: Int = 0
}

// MARK: - Interaction Engine
struct ScienceInteractionEngine {
    static func interact(_ a: ScienceEntity, _ b: ScienceEntity) -> (String, [ScienceEntity]) {
        // Chemistry
        if isMolecule(a) && isMolecule(b) {
            switch (a.type, b.type) {
            case (.alcohol, .carboxylicAcid):
                return ("✅ Esterification! \(a.name) + \(b.name) → Ester",
                        [ScienceEntity(name: "Ester", type: .ester, color: .pink, size: 80)])
            default:
                if let discovery = ProceduralDiscovery.discoverChemistry(a,b) {
                    return ("🌟 Discovered new molecule: \(discovery.name)!", [discovery])
                }
            }
        }
        
        // Anatomy / Physiology
        if isSystem(a) && isSystem(b) {
            switch (a.type, b.type) {
            case (.heart, .artery):
                return ("❤️ Circulation activated! Blood flows from \(a.name) through \(b.name).", [])
            case (.lung, .heart):
                return ("💨 Gas exchange initiated! Oxygen from \(a.name) delivered by \(b.name).", [])
            default:
                if let discovery = ProceduralDiscovery.discoverPhysiology(a,b) {
                    return ("🌟 Discovered new physiological pathway: \(discovery.name)!", [discovery])
                }
            }
        }
        
        // Microbiology / Immunology
        if isMicrobe(a) && isMicrobe(b) {
            if let discovery = ProceduralDiscovery.discoverMicrobiology(a,b) {
                return ("🦠 New microbial interaction discovered: \(discovery.name)!", [discovery])
            }
            return ("⚠️ Microbes interacted but no major effect.", [])
        }
        
        // Botany / Ecology
        if isEcosystem(a) && isEcosystem(b) {
            if let discovery = ProceduralDiscovery.discoverEcosystem(a,b) {
                return ("🌿 Emergent ecological interaction: \(discovery.name)!", [discovery])
            }
            return ("⚠️ Ecosystem entities coexisted without major interaction.", [])
        }
        
        // Cross-discipline & emergent
        if true {
            if let discovery = ProceduralDiscovery.discoverEmergent(a,b) {
                return ("✨ Emergent discovery: \(discovery.name)!", [discovery])
            }
        }
        
        return ("⚠️ No observable interaction.", [])
    }
    
    static func isMolecule(_ e: ScienceEntity) -> Bool {
        return [.alcohol,.ketone,.aldehyde,.carboxylicAcid,.amine,.ester,.imine,.unknownMolecule].contains(e.type)
    }
    static func isSystem(_ e: ScienceEntity) -> Bool {
        return [.heart,.lung,.brain,.kidney,.stomach,.liver,.artery,.vein,.unknownSystem].contains(e.type)
    }
    static func isMicrobe(_ e: ScienceEntity) -> Bool {
        return [.bacterium,.virus,.tCell,.antibody,.unknownMicrobe].contains(e.type)
    }
    static func isEcosystem(_ e: ScienceEntity) -> Bool {
        return [.plant,.fungus,.algae,.predator,.prey,.unknownEcosystem].contains(e.type)
    }
}

// MARK: - Procedural Discovery
struct ProceduralDiscovery {
    static func discoverChemistry(_ a: ScienceEntity,_ b: ScienceEntity) -> ScienceEntity? {
        if (a.type == .alcohol && b.type == .ketone) {
            return ScienceEntity(name: "MysticCompound", type: .unknownMolecule, color: .magenta, size: 85)
        }
        return nil
    }
    static func discoverPhysiology(_ a: ScienceEntity,_ b: ScienceEntity) -> ScienceEntity? {
        if (a.type == .kidney && b.type == .liver) {
            return ScienceEntity(name: "Detox Loop", type: .unknownSystem, color: .purple, size: 85)
        }
        return nil
    }
    static func discoverMicrobiology(_ a: ScienceEntity,_ b: ScienceEntity) -> ScienceEntity? {
        return ScienceEntity(name: "QuantumVirus", type: .unknownMicrobe, color: .green, size: 80)
    }
    static func discoverEcosystem(_ a: ScienceEntity,_ b: ScienceEntity) -> ScienceEntity? {
        return ScienceEntity(name: "Photosynthetic Neural Forest", type: .unknownEcosystem, color: .teal, size: 90)
    }
    static func discoverEmergent(_ a: ScienceEntity,_ b: ScienceEntity) -> ScienceEntity? {
        return ScienceEntity(name: "Synaptic Flux Entity", type: .hybridEntity, color: .orange, size: 100)
    }
}

// MARK: - Lab ViewModel
class ImaginationLab: ObservableObject {
    @Published var entities: [ScienceEntity] = [
        // Chemistry
        ScienceEntity(name: "Ethanol", type: .alcohol, color: .blue),
        ScienceEntity(name: "Acetone", type: .ketone, color: .purple),
        // Anatomy
        ScienceEntity(name: "Heart", type: .heart, color: .red),
        ScienceEntity(name: "Lung", type: .lung, color: .blue),
        // Microbiology
        ScienceEntity(name: "T-Cell", type: .tCell, color: .green),
        // Botany/Ecology
        ScienceEntity(name: "Sunflower", type: .plant, color: .yellow),
        ScienceEntity(name: "Fox", type: .predator, color: .orange)
    ]
    
    @Published var message: String = "Drag entities to interact and discover new phenomena!"
    @Published var score: Int = 0
    @Published var badges: [String] = []
    
    func handleInteraction(message: String, products: [ScienceEntity]) {
        if message.contains("✅") || message.contains("🌟") || message.contains("🦠") || message.contains("✨") {
            score += 10
            if score % 30 == 0 { badges.append("🏆 Discovery Master!") }
            entities.append(contentsOf: products)
        }
        self.message = message
    }
}

// MARK: - Main Lab View
struct ImaginationLabView: View {
    @StateObject private var lab = ImaginationLab()
    @State private var time: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.black,.indigo,.purple]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                VStack(spacing:10){
                    Text("🌌 Imagination: Ultimate Science Universe")
                        .font(.title2).bold().foregroundColor(.white)
                    Text(lab.message)
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Text("Score: \(lab.score)")
                        .foregroundColor(.green)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(lab.badges,id:\.self){badge in
                                Text(badge)
                                    .font(.caption)
                                    .foregroundColor(.pink)
                                    .padding(4)
                                    .background(RoundedRectangle(cornerRadius:5).fill(Color.white.opacity(0.1)))
                            }
                        }
                    }.frame(height:30)
                }.padding()
                
                Spacer()
                
                ZStack{
                    ForEach(lab.entities){ entity in
                        AnimatedEntityView(entity: entity, lab: lab, time: $time)
                    }
                }.frame(maxWidth:.infinity,maxHeight:.infinity)
            }
        }
        .onAppear{
            withAnimation(.linear(duration:100).repeatForever(autoreverses:false)){ time=100 }
        }
    }
}

// MARK: - Animated Entity View
struct AnimatedEntityView: View {
    let entity: ScienceEntity
    @ObservedObject var lab: ImaginationLab
    @Binding var time: Double
    @State private var position = CGSize.zero
    @State private var lastPosition = CGSize.zero
    @State private var showParticles = false
    
    var body: some View{
        ZStack{
            Circle()
                .fill(entity.color)
                .frame(width: entity.size,height: entity.size)
                .overlay(Text(entity.name.prefix(1)).foregroundColor(.white).bold())
                .shadow(color: entity.color.opacity(0.8), radius: 15)
            
            if showParticles{
                ForEach(0..<12,id:\.self){ i in
                    Circle()
                        .fill(entity.color.opacity(0.3))
                        .frame(width: CGFloat.random(in:5...20),height:CGFloat.random(in:5...20))
                        .offset(x: CGFloat.random(in:-60...60),y:CGFloat.random(in:-60...60))
                        .blur(radius: CGFloat.random(in:1...5))