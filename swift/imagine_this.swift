//
// ImaginationUltimate.swift
// By Cazzy
//
// The Ultimate Science Universe: fully immersive, interactive, procedural, cross-disciplinary
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
    // Environmental/Hybrid
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

// MARK: - Question Model
struct ScienceQuestion: Identifiable {
    let id = UUID()
    let prompt: String
    let options: [String]
    let correctAnswer: String
    let relatedEntities: [ScienceEntity]
}

// MARK: - Interaction Engine
struct ScienceInteractionEngine {
    static func interact(_ a: ScienceEntity, _ b: ScienceEntity) -> (String, [ScienceEntity]) {
        // Chemistry
        if isMolecule(a) && isMolecule(b) {
            switch (a.type,b.type) {
            case (.alcohol,.carboxylicAcid):
                return ("✅ Esterification! \(a.name)+\(b.name) → Ester",
                        [ScienceEntity(name:"Ester",type:.ester,color:.pink,size:80)])
            default:
                if let discovery = ProceduralDiscovery.discoverChemistry(a,b){
                    return ("🌟 Discovered new molecule: \(discovery.name)!",[discovery])
                }
            }
        }
        // Anatomy/Physiology
        if isSystem(a) && isSystem(b){
            switch (a.type,b.type){
            case (.heart,.artery):
                return ("❤️ Circulation activated! Blood flows from \(a.name) through \(b.name).",[])
            case (.lung,.heart):
                return ("💨 Gas exchange initiated! Oxygen from \(a.name) delivered by \(b.name).",[])
            default:
                if let discovery = ProceduralDiscovery.discoverPhysiology(a,b){
                    return ("🌟 Discovered new physiological pathway: \(discovery.name)!",[discovery])
                }
            }
        }
        // Microbiology/Immunology
        if isMicrobe(a) && isMicrobe(b){
            if let discovery = ProceduralDiscovery.discoverMicrobiology(a,b){
                return ("🦠 New microbial interaction discovered: \(discovery.name)!",[discovery])
            }
            return ("⚠️ Microbes interacted but no major effect.",[])
        }
        // Botany/Ecology
        if isEcosystem(a) && isEcosystem(b){
            if let discovery = ProceduralDiscovery.discoverEcosystem(a,b){
                return ("🌿 Emergent ecological interaction: \(discovery.name)!",[discovery])
            }
            return ("⚠️ Ecosystem entities coexisted without major interaction.",[])
        }
        // Cross-disciplinary emergent
        if let discovery = ProceduralDiscovery.discoverEmergent(a,b){
            return ("✨ Emergent discovery: \(discovery.name)!",[discovery])
        }
        return ("⚠️ No observable interaction.",[])
    }
    
    static func isMolecule(_ e: ScienceEntity)->Bool{
        return [.alcohol,.ketone,.aldehyde,.carboxylicAcid,.amine,.ester,.imine,.unknownMolecule].contains(e.type)
    }
    static func isSystem(_ e: ScienceEntity)->Bool{
        return [.heart,.lung,.brain,.kidney,.stomach,.liver,.artery,.vein,.unknownSystem].contains(e.type)
    }
    static func isMicrobe(_ e: ScienceEntity)->Bool{
        return [.bacterium,.virus,.tCell,.antibody,.unknownMicrobe].contains(e.type)
    }
    static func isEcosystem(_ e: ScienceEntity)->Bool{
        return [.plant,.fungus,.algae,.predator,.prey,.unknownEcosystem].contains(e.type)
    }
}

// MARK: - Procedural Discovery
struct ProceduralDiscovery {
    static func discoverChemistry(_ a: ScienceEntity,_ b: ScienceEntity)->ScienceEntity?{
        if (a.type==.alcohol && b.type==.ketone){
            return ScienceEntity(name:"MysticCompound",type:.unknownMolecule,color:.magenta,size:85)
        }
        return nil
    }
    static func discoverPhysiology(_ a:ScienceEntity,_ b:ScienceEntity)->ScienceEntity?{
        if (a.type==.kidney && b.type==.liver){
            return ScienceEntity(name:"Detox Loop",type:.unknownSystem,color:.purple,size:85)
        }
        return nil
    }
    static func discoverMicrobiology(_ a:ScienceEntity,_ b:ScienceEntity)->ScienceEntity?{
        return ScienceEntity(name:"QuantumVirus",type:.unknownMicrobe,color:.green,size:80)
    }
    static func discoverEcosystem(_ a:ScienceEntity,_ b:ScienceEntity)->ScienceEntity?{
        return ScienceEntity(name:"Photosynthetic Neural Forest",type:.unknownEcosystem,color:.teal,size:90)
    }
    static func discoverEmergent(_ a:ScienceEntity,_ b:ScienceEntity)->ScienceEntity?{
        return ScienceEntity(name:"Synaptic Flux Entity",type:.hybridEntity,color:.orange,size:100)
    }
}

// MARK: - Question Engine
struct ProceduralQuestionEngine {
    static func generateQuestions(for entities:[ScienceEntity], previousAnswers:[UUID:Bool])->[ScienceQuestion]{
        var questions:[ScienceQuestion]=[]
        for entity in entities{
            // Identification
            let idQ = ScienceQuestion(
                prompt: "Identify the type of \(entity.name).",
                options: ["Chemistry","Anatomy","Microbiology","Botany","Environmental/Hybrid"],
                correctAnswer: entityCategory(entity),
                relatedEntities:[entity]
            )
            questions.append(idQ)
            // Interaction-based
            for other in entities where other.id != entity.id{
                let interQ = ScienceQuestion(
                    prompt: "Predict the result if \(entity.name) interacts with \(other.name).",
                    options:["No change","New entity forms","Chain reaction","Unknown effect"],
                    correctAnswer:"New entity forms",
                    relatedEntities:[entity,other]
                )
                questions.append(interQ)
            }
        }
        // Random hypothetical
        for _ in 0..<10{
            let q = ScienceQuestion(
                prompt: "If a \(randomEntityName()) meets a \(randomEntityName()), what unexpected phenomenon could occur?",
                options:["Emergent reaction","Nothing","Hybrid organism","Energy flux"],
                correctAnswer:"Emergent reaction",
                relatedEntities:[]
            )
            questions.append(q)
        }
        return questions
    }
    static func entityCategory(_ e:ScienceEntity)->String{
        switch e.type{
        case .alcohol,.ketone,.aldehyde,.carboxylicAcid,.amine,.ester,.imine,.unknownMolecule: return "Chemistry"
        case .heart,.lung,.brain,.kidney,.stomach,.liver,.artery,.vein,.unknownSystem: return "Anatomy"
        case .bacterium,.virus,.tCell,.antibody,.unknownMicrobe: return "Microbiology"
        case .plant,.fungus,.algae,.predator,.prey,.unknownEcosystem: return "Botany"
        default: return "Environmental/Hybrid"
        }
    }
    static func randomEntityName()->String{
        let names=["Neuron","Sunflower","VirusX","PlasmaMolecule","HybridLeaf","QuantumCell"]
        return names.randomElement() ?? "EntityX"
    }
}

// MARK: - Lab ViewModel
class UltimateLab: ObservableObject {
    @Published var entities:[ScienceEntity]=[
        ScienceEntity(name:"Ethanol",type:.alcohol,color:.blue),
        ScienceEntity(name:"Heart",type:.heart,color:.red),
        ScienceEntity(name:"T-Cell",type:.tCell,color:.green),
        ScienceEntity(name:"Sunflower",type:.plant,color:.yellow)
    ]
    @Published var questions:[ScienceQuestion]=[]
    @Published var score:Int=0
    @Published var answeredQuestions:[UUID:Bool]=[:]
    @Published var message:String="Drag entities to interact and discover new phenomena!"
    @Published var badges:[String]=[]
    
    func updateQuestions(){
        questions=ProceduralQuestionEngine.generateQuestions(for: entities, previousAnswers:answeredQuestions)
    }
    
    func handleInteraction(message:String, products:[ScienceEntity]){
        if message.contains("✅") || message.contains("🌟") || message.contains("🦠") || message.contains("✨"){
            score+=10
            if score%30==0{ badges.append("🏆 Discovery Master!") }
            entities.append(contentsOf: products)
        }
        self.message=message
    }
}

// MARK: - Animated Entity View
struct AnimatedEntityView: View{
    let entity:ScienceEntity
    @ObservedObject var lab:UltimateLab
    @State private var position = CGSize.zero
    @State private var lastPosition = CGSize.zero
    @State private var showParticles=false
    var body: some View{
        ZStack{
            Circle()
                .fill(entity.color)
                .frame(width:entity.size,height:entity.size)
                .overlay(Text(entity.name.prefix(1)).foregroundColor(.white).bold())
                .shadow(color:entity.color.opacity(0.8),radius:15)
                .offset(x:position.width,y:position.height)
                .gesture(
                    DragGesture()
                        .onChanged{ gesture in position=CGSize(width:lastPosition.width+gesture.translation.width, height:lastPosition.height+gesture.translation.height)}
                        .onEnded{ _ in lastPosition=position
                            for other in lab.entities where other.id != entity.id{
                                let (msg,newEntities)=ScienceInteractionEngine.interact(entity,other)
                                lab.handleInteraction(message:msg,products:newEntities)
                            }
                        }
                )
        }
    }
}

// MARK: - Question View
struct ScienceQuestionView: View{
    @State var question:ScienceQuestion
    @ObservedObject var lab:UltimateLab
    var body: some View{
        VStack(spacing:10){
            Text(question.prompt).bold().foregroundColor(.white)
            ForEach(question.options,id:\.self){ option in
                Button(action:{
                    let correct = option == question.correctAnswer
                    if correct{ lab.score+=10 }
                    lab.answeredQuestions[question.id]=correct
                }){
                    Text(option)
                        .padding()
                        .background(Color.blue.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }.padding().background(RoundedRectangle(cornerRadius:10).fill(Color.black.opacity(0.7)))
    }
}

// MARK: - Main Ultimate Lab View
struct UltimateLabView: View{
    @StateObject var lab = UltimateLab()
    var body: some View{
        ZStack{
            LinearGradient(gradient:Gradient(colors:[.black,.indigo,.purple]),startPoint:.top,endPoint:.bottom).ign