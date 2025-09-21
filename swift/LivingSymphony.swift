//
// LivingSymphony.swift
// by Cazzy
//
// A surreal Swift project that blends math, music, randomness, and philosophy.
// Each run is unique — the symphony evolves like a living organism.
//

import Foundation

// MARK: - Protocols for Abstract "Voices"

protocol Voice {
    associatedtype Element
    func sing(_ input: [Element]) -> [Element]
}

/// Type-erased wrapper
struct AnyVoice<T>: Voice {
    private let _sing: ([T]) -> [T]
    init<V: Voice>(_ base: V) where V.Element == T {
        self._sing = base.sing
    }
    func sing(_ input: [T]) -> [T] { _sing(input) }
}

// MARK: - Motifs (Transformations)

struct Motif<T>: Voice {
    let transform: ([T]) -> [T]
    func sing(_ input: [T]) -> [T] { transform(input) }
}

// Numeric motifs
extension Motif where T == Int {
    static var doubling: Motif { Motif { $0.map { $0 * 2 } } }
    static var halving: Motif { Motif { $0.map { max(1, $0 / 2) } } }
    static var shuffle: Motif { Motif { $0.shuffled() } }
    static var fibonacci: Motif {
        Motif { input in
            guard let n = input.last else { return input }
            var seq = [0, 1]
            while seq.count < n { seq.append(seq[seq.count-1] + seq[seq.count-2]) }
            return seq
        }
    }
    static var fractal: Motif {
        Motif { input in
            // A recursive fractal-like expansion
            func grow(_ x: Int, depth: Int) -> [Int] {
                if depth == 0 { return [x] }
                return [x] + grow(x/2 + 1, depth: depth - 1) + grow(x*2, depth: depth - 1)
            }
            return input.flatMap { grow($0, depth: 2) }
        }
    }
}

// MARK: - The Conductor

struct Conductor<T> {
    private var voices: [AnyVoice<T>]
    
    init(_ voices: [AnyVoice<T>]) {
        self.voices = voices
    }
    
    mutating func evolve() {
        // Randomly insert or remove voices to simulate a "living" score
        if Bool.random(), let randomVoice = [Motif<T>.shuffle].compactMap({ $0 as? Voice }).first {
            voices.append(AnyVoice(randomVoice as! Motif<T>))
        }
        if Bool.random(), !voices.isEmpty {
            voices.remove(at: Int.random(in: 0..<voices.count))
        }
    }
    
    func perform(with seed: [T]) -> [T] {
        voices.reduce(seed) { result, voice in
            voice.sing(result)
        }
    }
}

// MARK: - Composition (Philosophy)

struct Composition<T> {
    let title: String
    var conductor: Conductor<T>
    let seed: [T]
    
    mutating func perform(iterations: Int) {
        print("\n🎼 Performing: \(title)")
        var state = seed
        for i in 1...iterations {
            state = conductor.perform(with: state)
            print("Iteration \(i):", state)
            conductor.evolve()
        }
        print("✨ Final form of '\(title)':", state)
        print("🌌 Reflection: Every run is a mirror of chance and choice.\n")
    }
}

// MARK: - Run Surreal Symphony

@main
struct Run {
    static func main() {
        print("🌠 Living Symphony — by Cazzy 🌠")
        
        var fractalDream = Composition(
            title: "Fractal Dream",
            conductor: Conductor([
                AnyVoice(Motif<Int>.doubling),
                AnyVoice(Motif<Int>.fractal),
                AnyVoice(Motif<Int>.shuffle)
            ]),
            seed: [7]
        )
        
        var cosmicFibonacci = Composition(
            title: "Cosmic Fibonacci",
            conductor: Conductor([
                AnyVoice(Motif<Int>.fibonacci),
                AnyVoice(Motif<Int>.halving)
            ]),
            seed: [12]
        )
        
        fractalDream.perform(iterations: 5)
        cosmicFibonacci.perform(iterations: 5)
        
        print("🌀 The code itself is an improvisation —")
        print("a reminder that algorithms can *breathe* like poems.")
    }
}