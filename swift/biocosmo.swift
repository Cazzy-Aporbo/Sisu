//
//  Biocosmos.swift
//
//  Written by Cazzy – a carbon-based poet who once accidentally inhaled benzene
//  and has been dreaming in aromatic rings ever since.
//
//  READING GUIDE
//  ––––––––––––
//  1.  Every “// •” is a heartbeat.  Place your finger on it while reading.
//  2.  Variables named with actual Unicode symbols (π, ℏ, β) are not pretension—
//      they are tiny altars to the thing they represent.
//  3.  If you compile this file and smell ether, that’s normal.
//
//  THE PREMISE
//  –––––––––––
//  A single process becomes a **planet**.
//  The planet has an atmosphere (gas-phase molecules), oceans (aqueous ions),
//  and a lipid bilayer that self-assembles into **cells**.
//  Each cell owns a genome – a plain Swift Array of 64-bit op-codes.
//  The op-codes are interpreted by a tiny ribosome loop:
//      0x01 → transcribe a protein
//      0x02 → duplicate the genome
//      0x03 → open an ion channel
//      0x04 → emit a photon (bioluminescence)
//      0x05 → apoptose—write a death haiku into the console
//  Mutations are Poisson; selection is the second law of thermodynamics.
//  You may poke the planet with UV light (console command “uv x y”) –
//  any cell whose membrane absorbs >3 photons undergoes thymine dimerisation
//  and possibly cancer, or art.
//
//  This is not a simulation.  It is a **pantheon**.
//

import Foundation
import Dispatch
import CryptoKit

// • MARK: - Physical constants whispered by Avogadro’s ghost
private let 𝑘 = 1.380649e-23          // J/K
private let ℏ = 1.054571817e-34       // J·s
private let 𝑁 = 6.02214076e23         // mol⁻¹
private let π = Double.pi
private let 𝑐 = 299_792_458           // m/s
private let fps = 30                  // planetary heartbeats per second
private let 𝜏 = 1.0 / Double(fps)

// • MARK: - Typealiases that taste like glucose
private typealias ℝ = Double
private typealias Count = Int64        // molecules can be numerous
private typealias Genome = [UInt8]     // 8-bit op-codes

// • MARK: - Chemical species as enum cases, not data
private enum Species: String, CaseIterable {
    case H2O, CO2, O2, N2, NH3, CH4, PO4, ADP, ATP, Glucose, Lactate, Hplus, OHminus, Na, K, Cl, Photon, ThymineDimer
    var molarMass: ℝ {  // g/mol – we keep the numbers honest
        switch self {
        case .H2O: 18.015
        case .CO2: 44.01
        case .O2: 31.998
        case .N2: 28.014
        case .NH3: 17.031
        case .CH4: 16.043
        case .PO4: 94.971
        case .ADP: 427.201
        case .ATP: 507.181
        case .Glucose: 180.156
        case .Lactate: 90.078
        case .Hplus: 1.008
        case .OHminus: 17.008
        case .Na: 22.990
        case .K: 39.098
        case .Cl: 35.453
        case .Photon: 0.0
        case .ThymineDimer: 241.23
        }
    }
}

// • MARK: - A molecule is just a number with a name
private struct Molecule: Hashable {
    let species: Species
    var count: Count
    mutating func react(with other: inout Molecule, rate: ℝ, dt: ℝ) -> Bool {
        let reacted = min(count, other.count, Count(rate * dt * Double(count + other.count)))
        count -= reacted
        other.count -= reacted
        return reacted > 0
    }
}

// • MARK: - Planet: the cradle
private actor Planet {
    private var atmosphere: [Species: Count] = [:]
    private var ocean: [Species: Count] = [:]
    private var cells: [Cell] = []
    private var photonFlux: ℝ = 0.0
    private var rng = SeededGenerator(seed: Double(Date().timeIntervalSince1970).bitPattern)
    
    init() {
        // Primeval soup – numbers from Miller–Urey 1953, because nostalgia
        atmosphere[.N2] = 7_000_000_000_000_000_000   // 70 % of 10²⁰ total
        atmosphere[.O2] = 2_000_000_000_000_000_000
        atmosphere[.CO2] = 300_000_000_000_000_000
        atmosphere[.H2O] = 100_000_000_000_000_000
        ocean[.H2O] = 100_000_000_000_000_000_000
        ocean[.Na] = 10_000_000_000_000_000_000
        ocean[.Cl] = 10_000_000_000_000_000_000
        // Spontaneous origin of life – because why wait
        for _ in 0..<16 {
            cells.append(Cell(genome: randomGenome(length: 64)))
        }
    }
    
    // UV pulse – you, the deity, smite or inspire
    func uv(x: Int, y: Int) {
        photonFlux = 1e6
        // any cell near (x,y) absorbs photons
        for cell in cells {
            let dx = abs(cell.x - x), dy = abs(cell.y - y)
            if dx*dx + dy*dy < 100 {
                cell.photonsAbsorbed += Int(photonFlux)
            }
        }
    }
    
    // One planetary heartbeat
    func tick() async {
        // Photochemistry
        if photonFlux > 0 {
            // CO2 + H2O + hν → CH2O + O2  (simplified photosynthesis)
            if let co2 = atmosphere[.CO2], let h2o = atmosphere[.H2O], co2 > 0, h2o > 0 {
                let reacted = min(co2, h2o, Count(photonFlux))
                atmosphere[.CO2, default: 0] -= reacted
                atmosphere[.H2O, default: 0] -= reacted
                atmosphere[.O2, default: 0] += reacted
                ocean[.Glucose, default: 0] += reacted
            }
        }
        photonFlux = 0
        
        // Cell metabolism & replication & death
        var nextGeneration: [Cell] = []
        for cell in cells {
            await cell.metabolize(with: self)
            if cell.alive {
                nextGeneration.append(cell)
                if cell.energy > 1000 {
                    var daughter = cell
                    daughter.mutate(rng: &rng)
                    daughter.energy /= 2
                    cell.energy /= 2
                    nextGeneration.append(daughter)
                }
            } else {
                // Death haiku
                print("""
                ───────────────────────────
                a membrane dissolves
                ions rush to equilibrium
                the planet exhales
                """)
            }
        }
        cells = nextGeneration
    }
    
    // Helpers for cells to query environment
    func take(_ species: Species, amount: Count) -> Count {
        let available = atmosphere[species, default: 0] + ocean[species, default: 0]
        let taken = min(amount, available)
        if atmosphere[species, default: 0] >= taken {
            atmosphere[species, default: 0] -= taken
        } else {
            let fromOcean = taken - (atmosphere[species, default: 0])
            atmosphere[species, default: 0] = 0
            ocean[species, default: 0] -= fromOcean
        }
        return taken
    }
    
    func put(_ species: Species, amount: Count) {
        if species == .CO2 || species == .O2 || species == .N2 {
            atmosphere[species, default: 0] += amount
        } else {
            ocean[species, default: 0] += amount
        }
    }
    
    func render() -> String {
        var out = ""
        out += "Atmosphere: \(atmosphere)\n"
        out += "Ocean: \(ocean)\n"
        out += "Cells alive: \(cells.count)\n"
        for (i, cell) in cells.enumerated() {
            out += "Cell #\(i): x=\(cell.x) y=\(cell.y) energy=\(cell.energy) photons=\(cell.photonsAbsorbed)\n"
        }
        return out
    }
    
    private func randomGenome(length: Int) -> Genome {
        (0..<length).map { _ in UInt8.random(in: 0x01...0x05) }
    }
}

// • MARK: - Cell: a lipid whisper that learned to replicate
private class Cell {
    var x: Int, y: Int
    var genome: Genome
    var energy: ℝ = 100
    var alive = true
    var photonsAbsorbed = 0
    private var pc: Int = 0 // program counter
    
    init(genome: Genome) {
        self.genome = genome
        let theta = Double.random(in: 0..<(2*π))
        self.x = Int(50 + 30 * cos(theta))
        self.y = Int(25 + 15 * sin(theta))
    }
    
    func mutate(rng: inout SeededGenerator) {
        for i in genome.indices where rng.nextDouble() < 0.02 { // 2 % point mutation
            genome[i] = UInt8.random(in: 0x01...0x05)
        }
    }
    
    func metabolize(with planet: Planet) async {
        guard alive else { return }
        
        // Photodamage
        if photonsAbsorbed > 3 {
            genome = genome.map { $0 == 0x02 ? 0x00 : $0 } // thymine dimer knocks out replication
            photonsAbsorbed = 0
        }
        
        // Interpret next op-code
        let op = genome[pc %% genome.count]
        pc += 1
        
        switch op {
        case 0x01: // transcribe protein – costs ATP
            let cost = 10
            let atp = planet.take(.ATP, amount: Count(cost))
            if atp == cost {
                energy += 5
            } else {
                planet.put(.ADP, amount: atp)
            }
            
        case 0x02: // duplicate genome – costs glucose
            let cost = 20
            let glucose = planet.take(.Glucose, amount: Count(cost))
            if glucose == cost {
                energy += 10
            }
            
        case 0x03: // ion channel – swap Na/K
            let na = planet.take(.Na, amount: 5)
            let k  = planet.take(.K,  amount: 5)
            planet.put(.K,  amount: na)
            planet.put(.Na, amount: k)
            energy += Double(na + k)
            
        case 0x04: // emit photon – bioluminescence
            planet.put(.Photon, amount: 1)
            energy -= 1
            
        case 0x05: // apoptosis – voluntary death
            alive = false
            
        default:
            break // intron – silence is also music
        }
        
        // Basic upkeep: burn glucose for ATP
        let glucose = planet.take(.Glucose, amount: 5)
        if glucose > 0 {
            planet.put(.ATP, amount: glucose * 2)
            planet.put(.CO2, amount: glucose)
            planet.put(.Lactate, amount: glucose)
        }
        
        // Entropic tax
        energy -= 0.5
        if energy <= 0 { alive = false }
    }
}

// • MARK: - Deterministic RNG
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &*= 2862933555777941757
        state &+= 3037000493
        return state
    }
}

// • MARK: - Display loop
@MainActor
final class BiosphereDisplay: ObservableObject {
    @Published var frame = ""
    private let planet = Planet()
    private var timer: DispatchSourceTimer?
    
    init() {
        timer = DispatchSource.makeTimerSource(queue: .global())
        timer?.schedule(deadline: .now(), repeating: .milliseconds(Int(𝜏 * 1000)))
        timer?.setEventHandler { [weak self] in Task { await self?.tick() } }
        timer?.resume()
    }
    
    private func tick() async {
        await planet.tick()
        await MainActor.run { frame = planet.render() }
    }
    
    func uv(x: Int, y: Int) {
        Task { await planet.uv(x: x, y: y) }
    }
}

// • MARK: - Entrypoint
@main
enum BiocosmosLauncher {
    static func main() async {
        print("\u{1B}[2J\u{1B}[H") // clear
        let display = await BiosphereDisplay()
        // CLI
        DispatchQueue.global().async {
            let stdin = FileHandle.standardInput
            while let line = try? stdin.readToEnd() {
                let parts = String(data: line, encoding: .utf8)?.split(separator: " ")
                if parts?.first == "uv", let x = Int(parts?[1] ?? ""), let y = Int(parts?[2] ?? "") {
                    display.uv(x: x, y: y)
                }
            }
        }
        // Rendering loop
        while true {
            try? await Task.sleep(nanoseconds: UInt64(𝜏 * 1_000_000_000))
            await MainActor.run { print(display.frame) }
        }
    }
}
