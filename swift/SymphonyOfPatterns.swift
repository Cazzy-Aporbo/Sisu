//
// SymphonyOfPatterns.swift
// by Cazzy
//
// A conceptual project demonstrating higher-level thinking.
// It weaves algorithms as if they were instruments in an orchestra.
// Each part is modular, expressive, and metaphorical.
//

import Foundation

// MARK: - Core Abstractions

/// A musical "Voice" — any process that transforms an input sequence into an output.
protocol Voice {
    associatedtype Element
    func sing(_ input: [Element]) -> [Element]
}

/// A "Motif" is just a function lifted into a Voice.
struct Motif<T>: Voice {
    let transform: ([T]) -> [T]
    func sing(_ input: [T]) -> [T] { transform(input) }
}

// MARK: - Example Motifs (Mathematical Transformations)

extension Motif where T == Int {
    static var doubling: Motif { Motif { $0.map { $0 * 2 } } }
    static var filteringOdds: Motif { Motif { $0.filter { $0 % 2 == 0 } } }
    static var fibonacci: Motif {
        Motif { input in
            guard let n = input.last else { return input }
            var seq = [0, 1]
            while seq.count < n { seq.append(seq[seq.count-1] + seq[seq.count-2]) }
            return seq
        }
    }
}

// MARK: - The Conductor

/// The conductor orchestrates multiple voices together.
struct Conductor<T> {
    private let voices: [AnyVoice<T>]
    
    init(_ voices: [AnyVoice<T>]) {
        self.voices = voices
    }
    
    func perform(with seed: [T]) -> [T] {
        voices.reduce(seed) { result, voice in
            voice._sing(result)
        }
    }
}

/// Type erasure for any Voice
struct AnyVoice<T>: Voice {
    private let _singClosure: ([T]) -> [T]
    init<V: Voice>(_ base: V) where V.Element == T {
        self._singClosure = base.sing
    }
    func sing(_ input: [T]) -> [T] { _singClosure(input) }
    var _sing: ([T]) -> [T] { _singClosure }
}

// MARK: - Philosophy Layer

/// A "Composition" is a higher-order idea:
/// it is not about the numbers, but the *journey* of transformation.
struct Composition<T> {
    let title: String
    let conductor: Conductor<T>
    let seed: [T]
    
    func perform() {
        print("\n🎼 Performing: \(title)")
        let result = conductor.perform(with: seed)
        print("✨ Result:", result)
    }
}

// MARK: - Example Performances

let doublingThenFibonacci = Composition(
    title: "Doubling then Fibonacci",
    conductor: Conductor([
        AnyVoice(Motif<Int>.doubling),
        AnyVoice(Motif<Int>.fibonacci)
    ]),
    seed: [5] // generate Fibonacci sequence of length 10
)

let purifyEvens = Composition(
    title: "Purify Evens",
    conductor: Conductor([
        AnyVoice(Motif<Int>.filteringOdds),
        AnyVoice(Motif<Int>.doubling)
    ]),
    seed: Array(1...10)
)

// MARK: - Run Symphony

@main
struct Run {
    static func main() {
        print("🎶 Symphony of Patterns — by Cazzy 🎶")
        
        doublingThenFibonacci.perform()
        purifyEvens.perform()
        
        // A final flourish: composing compositions
        let meta = Composition(
            title: "Meta Composition",
            conductor: Conductor([
                AnyVoice(Motif<Int>.doubling),
                AnyVoice(Motif<Int>.filteringOdds),
                AnyVoice(Motif<Int>.fibonacci)
            ]),
            seed: [12]
        )
        meta.perform()
        
        print("\n🌌 This program is not just math — it's a metaphor for how ideas evolve.")
    }
}