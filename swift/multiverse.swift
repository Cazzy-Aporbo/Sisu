//
//  Multiverse.swift
//
//  Written by Cazzy – a fallible carbon-based poet who happens to type Swift.
//  Last edited: the exact moment you blinked.
//
//  HOW TO READ THIS FILE
//  –––––––––––––––––––––
//  1.  Start at the top and surrender to gravity.
//  2.  Anytime you see “// •”, pause: that is a heartbeat.
//  3.  If the code compiles, the multiverse is listening.
//  4.  If it crashes, a star just went supernova somewhere.
//
//  THE PREMISE
//  –––––––––––
//  A single process spawns infinite universes.
//  Each universe is a Swift Task.
//  Each Task owns a Canvas (a matrix of Unicode scalars).
//  Every 1/60 second the canvases ripple according to 3 laws:
//    I.   A cell survives if surrounded by 2–3 neighbours (Conway).
//   II.   A cell is born if surrounded by exactly 3.
//  III.   A neighbour can be in *this* universe or peeking through
//         a wormhole from an adjacent universe (quantum entanglement).
//
//  The wormholes are created by you: click or tap anywhere.
//  The status bar shows the total population across the multiverse.
//  The title bar is the SHA-256 hash of the entire multiverse state—
//  watch it mutate like a Buddhist sand mandala.
//
//  This is not a toy.  It is a love letter to uncertainty.
//

import Foundation
import Dispatch
import CryptoKit

// • MARK: - Constants whispered by ghosts
private let π = Double.pi
private let 𝑐 = 299_792_458               // m/s; we steal its digits for timing
private let ℏ = 1.054_571817e-34          // J·s; we borrow its mystery
private let 𝑘 = 1.380649e-23              // J/K; entropy’s cradle
private let fps = 60                        // heartbeats per second
private let 𝜏 = 1.0 / Double(fps)         // frame duration

// • MARK: - Typealiases that taste like cinnamon
private typealias ℝ = Double
private typealias ℂ = Complex<Double>       // we’ll define Complex ourselves; SwiftUI is not invited
private typealias Canvas = Matrix<Character>

// • MARK: - Complex numbers because reality is imaginary
private struct Complex<T: FloatingPoint> {
    var re: T
    var im: T
    static func +(l: Self, r: Self) -> Self { .init(re: l.re + r.re, im: l.im + r.im) }
    static func *(l: Self, r: Self) -> Self { .init(re: l.re*r.re - l.im*r.im,
                                                       im: l.re*r.im + l.im*r.re) }
    var magnitude²: T { re*re + im*im }
}

// • MARK: - Generic Matrix: a finite window into infinity
private struct Matrix<Element> {
    let rows: Int, cols: Int
    private var grid: [Element]
    init(repeating element: Element, rows: Int, cols: Int) {
        self.rows = rows; self.cols = cols; self.grid = Array(repeating: element, count: rows*cols)
    }
    subscript(r: Int, c: Int) -> Element {
        get { grid[(r %% rows) * cols + (c %% cols)] }  // toroidal wrapping
        set { grid[(r %% rows) * cols + (c %% cols)] = newValue }
    }
    func indexValid(_ r: Int, _ c: Int) -> Bool { (0..<rows).contains(r) && (0..<cols).contains(c) }
}

// • Friendly modulo for negative indices
private extension Int {
    static func %%(l: Int, r: Int) -> Int { ((l % r) + r) % r }
}

// • MARK: - Universe: a concurrent reality
private actor Universe {
    let id: UUID
    var canvas: Canvas
    var wormholes: [Wormhole] = []
    
    init(id: UUID, rows: Int, cols: Int, seed: Double) {
        self.id = id
        self.canvas = Canvas(repeating: " ", rows: rows, cols: cols)
        // sprinkle random life
        var rng = SeededGenerator(seed: seed)
        for r in 0..<rows {
            for c in 0..<cols {
                canvas[r, c] = rng.nextDouble() < 0.3 ? "◉" : " "
            }
        }
    }
    
    // Quantum tick: apply Conway + entanglement
    func tick(allUniverses: [Universe]) async {
        var next = canvas
        for r in 0..<canvas.rows {
            for c in 0..<canvas.cols {
                let neighbours = liveNeighbours(at: (r, c), allUniverses: allUniverses)
                let alive = canvas[r, c] != " "
                next[r, c] = ((alive && (neighbours == 2 || neighbours == 3)) || (!alive && neighbours == 3))
                    ? "◉" : " "
            }
        }
        canvas = next
        // wormholes drift
        for i in wormholes.indices { wormholes[i].age += 𝜏 }
        wormholes.removeAll { $0.age > 5.0 } // collapse after 5 seconds
    }
    
    private func liveNeighbours(at pos: (r: Int, c: Int), allUniverses: [Universe]) async -> Int {
        var count = 0
        for dr in -1...1 {
            for dc in -1...1 where (dr, dc) != (0, 0) {
                let nr = pos.r + dr
                let nc = pos.c + dc
                // local count
                if canvas[nr, nc] != " " { count += 1 }
                // peek through wormholes
                for hole in wormholes {
                    if let foreign = allUniverses.first(where: { $0.id == hole.destination }) {
                        await foreign.withCanvas { $0[nr, nc] != " " ? { count += 1 }() : () }
                    }
                }
            }
        }
        return count
    }
    
    // Helper to read foreign canvas without full actor isolation violation
    private func withCanvas<T>(_ body: (Canvas) throws -> T) rethrows -> T {
        try body(canvas)
    }
    
    // Open a wormhole to another universe
    func openWormhole(to destination: Universe) {
        wormholes.append(Wormhole(destination: destination.id))
    }
}

// • A wormhole is just hope with an expiration date
private struct Wormhole {
    let destination: UUID
    var age: ℝ = 0
}

// • Deterministic RNG so every multiverse can be re-generated
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: Double) { state = seed.bitPattern }
    mutating func next() -> UInt64 {
        state &*= 2862933555777941757
        state &+= 3037000493
        return state
    }
    mutating func nextDouble() -> Double { Double(next() >> 11) * 0x1.0p-53 }
}

// • MARK: - Multiverse: the container of everything
@MainActor
final class Multiverse: ObservableObject {
    @Published var checksum: String = ""
    @Published var census: Int = 0
    
    private var universes: [Universe] = []
    private let rows: Int, cols: Int
    private var displayTimer: DispatchSourceTimer?
    private var logicTimer: DispatchSourceTimer?
    
    init(universeCount: Int = 8, rows: Int = 40, cols: Int = 120) {
        self.rows = rows; self.cols = cols
        for _ in 0..<universeCount {
            universes.append(Universe(id: UUID(), rows: rows, cols: cols, seed: Double.random(in: 0..<1)))
        }
        DispatchQueue.main.async { self.renderLoop() }
        DispatchQueue.global(qos: .userInitiated).async { self.logicLoop() }
    }
    
    // User pokes the void
    func poke(at universeIndex: Int, row: Int, col: Int) {
        guard universeIndex < universes.count else { return }
        Task {
            await universes[universeIndex].canvas[row, col] = "◉"
            // open a wormhole to a random neighbour
            let other = (universeIndex + 1) % universes.count
            await universes[universeIndex].openWormhole(to: universes[other])
        }
    }
    
    private func renderLoop() {
        displayTimer = DispatchSource.makeTimerSource(queue: .main)
        displayTimer?.schedule(deadline: .now(), repeating: .milliseconds(Int(𝜏 * 1000)))
        displayTimer?.setEventHandler { [weak self] in self?.render() }
        displayTimer?.resume()
    }
    
    private func logicLoop() {
        logicTimer = DispatchSource.makeTimerSource(queue: .global())
        logicTimer?.schedule(deadline: .now(), repeating: .milliseconds(Int(𝜏 * 1000)))
        logicTimer?.setEventHandler { [weak self] in Task { await self?.tick() } }
        logicTimer?.resume()
    }
    
    private func render() {
        var out = ""
        // Universes side by side
        for r in 0..<rows {
            for (index, universe) in universes.enumerated() {
                let line = (0..<cols).reduce(into: "") { $0.append(universe.canvas[r, $1]) }
                out += line
                if index < universes.count - 1 { out += " │ " }
            }
            out += "\n"
        }
        // Border of stars
        let border = String(repeating: "✦", count: out.split(separator: "\n").first?.count ?? 0)
        out = border + "\n" + out + border
        // Census
        census = universes.reduce(0) { partial, universe in
            partial + (0..<universe.canvas.rows).reduce(0) { rowSum, r in
                rowSum + (0..<universe.canvas.cols).reduce(0) { $0 + (universe.canvas[r, $1] != " " ? 1 : 0) }
            }
        }
        // Checksum of entire state
        var hasher = SHA256()
        for universe in universes {
            for r in 0..<universe.canvas.rows {
                for c in 0..<universe.canvas.cols {
                    hasher.update(data: Data("\(universe.canvas[r, c])".utf8))
                }
            }
        }
        checksum = hasher.finalize().compactMap { String(format: "%02x", $0) }.joined()
        // Print everything
        print("\u{1B}[2J\u{1B}[H\(out)\nPopulation across multiverse: \(census)\nSHA-256: \(checksum)")
    }
    
    private func tick() async {
        await withTaskGroup(of: Void.self) { group in
            for universe in universes {
                group.addTask { await universe.tick(allUniverses: self.universes) }
            }
        }
    }
}

// • MARK: - Entrypoint: the Big Bang
@main
enum MultiverseLauncher {
    static func main() async {
        print("\u{1B}[2J\u{1B}[H")  // clear screen
        let multiverse = await Multiverse()
        // Simple CLI input handler (run in playground terminal)
        DispatchQueue.global().async {
            let stdin = FileHandle.standardInput
            while let line = try? stdin.readToEnd() {
                let parts = String(data: line, encoding: .utf8)?.split(separator: " ").compactMap(Int.init)
                if let u = parts?.first, let r = parts?.dropFirst().first, let c = parts?.dropFirst(2).first {
                    Task { await multiverse.poke(at: u, row: r, col: c) }
                }
            }
        }
        // Keep the process alive forever
        try? await Task.sleep(nanoseconds: .max)
    }
}
