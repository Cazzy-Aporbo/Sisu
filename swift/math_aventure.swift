//
// MathAdventure.swift
// A whimsical project to showcase Swift skills
// by Cazzy
//

import Foundation

// MARK: - Core Models

enum GameError: Error {
    case invalidChoice
    case wrongAnswer
}

struct Puzzle {
    let question: String
    let answer: Int
}

class Player {
    var name: String
    var score: Int = 0
    
    init(name: String) {
        self.name = name
    }
}

// MARK: - Puzzle Bank

struct PuzzleBank {
    static let puzzles: [Puzzle] = [
        Puzzle(question: "🌌 What is 5 + 7?", answer: 12),
        Puzzle(question: "🌊 What is 9 × 3?", answer: 27),
        Puzzle(question: "🌿 What is 15 − 4?", answer: 11),
        Puzzle(question: "🔥 What is 20 ÷ 5?", answer: 4)
    ]
}

// MARK: - Generic Helpers

func ask<T>(_ prompt: String, transform: (String) -> T?) -> T {
    while true {
        print(prompt, terminator: " ")
        if let input = readLine(), let value = transform(input) {
            return value
        } else {
            print("⚠️ Invalid input, try again.")
        }
    }
}

// MARK: - Game Engine

class MathAdventure {
    let player: Player
    var puzzles = PuzzleBank.puzzles.shuffled()
    
    init(player: Player) {
        self.player = player
    }
    
    func start() async {
        print("\n🚀 Welcome, \(player.name), to the Math Adventure!\n")
        try? await explore()
        print("\n🌟 Final score: \(player.score)")
    }
    
    private func explore() async throws {
        for (i, puzzle) in puzzles.enumerated() {
            print("Level \(i+1): \(puzzle.question)")
            let guess: Int = ask("Your answer?") { Int($0) }
            
            if guess == puzzle.answer {
                player.score += 10
                print("✅ Correct! Score: \(player.score)\n")
            } else {
                throw GameError.wrongAnswer
            }
            
            // Add async pause for effect
            try await Task.sleep(nanoseconds: 500_000_000)
        }
        print("🎉 You solved all puzzles!")
    }
}

// MARK: - Fancy Showcase: DSL-style menus

enum MenuOption: String, CaseIterable {
    case start = "Start Adventure"
    case quit = "Quit"
}

func showMenu() -> MenuOption {
    print("\n=== MAIN MENU ===")
    for (i, option) in MenuOption.allCases.enumerated() {
        print("\(i+1). \(option.rawValue)")
    }
    let choice: Int = ask("Choose:") { Int($0) }
    guard let option = MenuOption.allCases[safe: choice-1] else {
        print("⚠️ Invalid choice, quitting.")
        return .quit
    }
    return option
}

// MARK: - Safe Collection Indexing

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Run Project

@main
struct Run {
    static func main() async {
        print("🎮 Math Adventure by Cazzy 🎮")
        
        let playerName = ask("Enter your name:") { $0.isEmpty ? nil : $0 }
        let player = Player(name: playerName)
        
        var running = true
        while running {
            switch showMenu() {
            case .start:
                let game = MathAdventure(player: player)
                do {
                    try await game.start()
                } catch {
                    print("💔 Oops, wrong answer. Game over.")
                }
            case .quit:
                running = false
                print("👋 Goodbye, adventurer!")
            }
        }
    }
}