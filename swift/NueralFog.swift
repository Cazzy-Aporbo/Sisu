//
// NeuralFog.swift
// By Cazzy
//
// Anesthesia Exploration Module for Imagination Universe
// Interactive neurons, network dynamics, procedural emergent patterns
//

import SwiftUI
import Combine

// MARK: - Neural Entity
struct NeuralEntity: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var color: Color
    var size: CGFloat
    var firingRate: Double // 0.0 - 1.0
    var connectedTo: [UUID] = []
}

// MARK: - Anesthetic Agent
struct AnestheticAgent: Identifiable {
    let id = UUID()
    let name: String
    var effectStrength: Double // 0.0 - 1.0
    var targetType: NeuralTarget
    enum NeuralTarget { case global, cluster, singleNeuron }
}

// MARK: - Neural Fog Lab ViewModel
class NeuralFogLab: ObservableObject {
    @Published var neurons: [NeuralEntity] = []
    @Published var agents: [AnestheticAgent] = [
        AnestheticAgent(name:"GABA Agonist", effectStrength:0.7,targetType:.global),
        AnestheticAgent(name:"NMDA Blocker", effectStrength:0.5,targetType:.cluster),
        AnestheticAgent(name:"Volatile Gas", effectStrength:0.8,targetType:.global)
    ]
    @Published var appliedAgents: [UUID: AnestheticAgent] = [:]
    @Published var score: Int = 0
    @Published var message: String = "Explore consciousness under anesthesia..."
    
    var timer: AnyCancellable?
    
    init() {
        setupNeurons()
        startSimulation()
    }
    
    func setupNeurons(){
        // Create 20 neurons with random colors, sizes, and initial firing rates
        for i in 0..<20 {
            neurons.append(
                NeuralEntity(
                    name:"Neuron \(i+1)",
                    color: Color(hue:Double.random(in:0...1),saturation:0.8,brightness:0.9),
                    size: CGFloat.random(in:30...60),
                    firingRate: Double.random(in:0.3...1.0)
                )
            )
        }
        // Randomly connect neurons
        for i in 0..<neurons.count {
            let connections = (0..<3).map{ _ in neurons.randomElement()?.id ?? neurons[i].id }
            neurons[i].connectedTo = connections.filter{ $0 != neurons[i].id }
        }
    }
    
    func startSimulation(){
        timer = Timer.publish(every:0.2, on:.main, in:.common).autoconnect().sink{ [weak self] _ in
            self?.updateNeurons()
        }
    }
    
    func applyAgent(_ agent: AnestheticAgent, to neuron: NeuralEntity? = nil){
        if let neuron = neuron {
            appliedAgents[neuron.id] = agent
            message = "\(agent.name) applied to \(neuron.name)"
        } else {
            // global effect
            for n in neurons { appliedAgents[n.id] = agent }
            message = "\(agent.name) applied globally"
        }
    }
    
    func updateNeurons(){
        for i in neurons.indices {
            let neuron = neurons[i]
            var newFiring = neuron.firingRate
            // Apply anesthetic effects
            if let agent = appliedAgents[neuron.id] {
                let reduction = agent.effectStrength * Double.random(in:0.7...1.0)
                newFiring = max(0.0, newFiring - reduction*0.05)
            } else {
                // natural fluctuation
                newFiring += Double.random(in:-0.02...0.02)
                newFiring = min(max(newFiring,0.0),1.0)
            }
            neurons[i].firingRate = newFiring
        }
        // Procedural emergent patterns
        let emergentChance = Double.random(in:0...1)
        if emergentChance > 0.98 {
            message = "✨ Emergent consciousness pattern detected!"
            score += 5
        }
    }
}

// MARK: - Neuron View
struct NeuronView: View {
    let neuron: NeuralEntity
    var body: some View {
        Circle()
            .fill(neuron.color)
            .frame(width: neuron.size,height: neuron.size)
            .overlay(
                Text(neuron.name.prefix(1))
                    .foregroundColor(.white)
                    .bold()
            )
            .opacity(0.4 + neuron.firingRate*0.6)
            .shadow(color: neuron.color.opacity(neuron.firingRate), radius: 10)
    }
}

// MARK: - Main Neural Fog Lab View
struct NeuralFogLabView: View {
    @StateObject var lab = NeuralFogLab()
    @State private var selectedAgent: AnestheticAgent?
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors:[.black,.indigo,.purple]),startPoint:.top,endPoint:.bottom)
                .ignoresSafeArea()
            
            VStack{
                Text("🧠 Neural Fog: Explore Consciousness under Anesthesia")
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                
                Text(lab.message)
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Score: \(lab.score)")
                    .foregroundColor(.green)
                
                ScrollView(.horizontal, showsIndicators:false){
                    HStack{
                        ForEach(lab.agents){ agent in
                            Button(action:{
                                selectedAgent = agent
                                lab.applyAgent(agent)
                            }){
                                Text(agent.name)
                                    .padding(8)
                                    .background(Color.orange.opacity(0.7))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                        }
                    }.padding()
                }
                
                GeometryReader{ geo in
                    ZStack{
                        ForEach(lab.neurons){ neuron in
                            NeuronView(neuron: neuron)
                                .position(
                                    x: CGFloat.random(in: 0...geo.size.width),
                                    y: CGFloat.random(in: 0...geo.size.height)
                                )
                                .onTapGesture{
                                    if let agent = selectedAgent {
                                        lab.applyAgent(agent,to: neuron)
                                    }
                                }
                        }
                    }
                }.padding()
            }
        }
    }
}

// MARK: - Preview
struct NeuralFogLabView_Previews: PreviewProvider {
    static var previews: some View {
        NeuralFogLabView()
    }
}