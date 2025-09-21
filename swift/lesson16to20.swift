//
// lesson16to20.swift
// Swift Lessons 16–20 — poetic, creative, inspiring
// by Cazzy
//

import Foundation

func header(_ title: String) {
    print("\n" + String(repeating: "🌌", count: 40))
    print("  \(title)")
    print(String(repeating: "🌌", count: 40) + "\n")
}

// -----------------------------------------------------------------------------
// Lesson 16 — Async / Await (time as poetry)
// -----------------------------------------------------------------------------

func lesson16_Async() async {
    header("Lesson 16 — Async & Await ⏳\nWe bend time, letting code breathe between moments.")

    // Way 1: Sleep like a sigh
    print("Waiting...")
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    print("One second has passed 🌙")

    // Way 2: Async function that returns a promise of words
    func fetchVerse() async -> String {
        try? await Task.sleep(nanoseconds: 500_000_000)
        return "The stars reply: patience is a loop."
    }
    let verse = await fetchVerse()
    print(verse)

    // Way 3: Multiple async tasks racing like comets
    async let comet1 = fetchVerse()
    async let comet2 = fetchVerse()
    print("Comets spoke:", await comet1, "|", await comet2)

    // Way 4: Sequential vs parallel
    print("Observe: one after another feels slow; all at once feels cosmic.")

    // QUIZ: Write an async function `dream()` that waits 2 seconds then prints "✨ Dream complete".
}

// -----------------------------------------------------------------------------
// Lesson 17 — Higher-Order Whispers (functional thinking)
// -----------------------------------------------------------------------------

func lesson17_Functional() {
    header("Lesson 17 — Higher-Order Whispers 🌀\nFunctions shaping functions, like rivers carve valleys.")

    let numbers = [1,2,3,4,5]

    // Way 1: Map as transformation spell
    let doubled = numbers.map { $0 * 2 }
    print("Doubled:", doubled)

    // Way 2: Filter as sieve
    let primes = numbers.filter { [2,3,5].contains($0) }
    print("Filtered primes:", primes)

    // Way 3: Reduce as storyfold
    let poem = ["Swift","is","a","river"].reduce("") { $0 + " " + $1 }
    print("Folded poem:", poem)

    // Way 4: Compose functions
    func inc(_ x:Int)->Int{x+1}
    func sq(_ x:Int)->Int{x*x}
    func compose<A,B,C>(_ f:@escaping (B)->C,_ g:@escaping (A)->B)->(A)->C{
        return { f(g($0)) }
    }
    let incThenSq = compose(sq,inc)
    print("Compose inc→sq on 3:", incThenSq(3))

    // QUIZ: Use reduce to compute the product of [2,3,4].
}

// -----------------------------------------------------------------------------
// Lesson 18 — Pattern Matching (poetry of choices)
// -----------------------------------------------------------------------------

func lesson18_Patterns() {
    header("Lesson 18 — Pattern Matching 🔮\nPattern as prophecy: see shapes in values.")

    // Way 1: Switch on ranges
    let age = 17
    switch age {
    case 0..<13: print("Child 🌱")
    case 13..<20: print("Teen 🌿")
    default: print("Adult 🌳")
    }

    // Way 2: Tuples
    let point = (2,0)
    switch point {
    case (0,0): print("Origin ✨")
    case (let x,0): print("On x-axis at \(x)")
    default: print("Somewhere else")
    }

    // Way 3: where clause
    let n = 7
    switch n {
    case let x where x % 2 == 0: print("\(x) is even")
    default: print("\(n) is odd")
    }

    // Way 4: if-case
    let status: Result<String,Error> = .success("Glow")
    if case .success(let msg) = status { print("Success carries:", msg) }

    // QUIZ: Write a switch that classifies any Int as "negative", "zero", or "positive".
}

// -----------------------------------------------------------------------------
// Lesson 19 — Extensions of Imagination
// -----------------------------------------------------------------------------

func lesson19_Extensions() {
    header("Lesson 19 — Extensions 🌈\nTeach old types new tricks.")

    // Way 1: Extend String
    extension String {
        var reversedWords: String {
            self.split(separator: " ").reversed().joined(separator: " ")
        }
    }
    print("Swift is love".reversedWords)

    // Way 2: Extend Int
    extension Int {
        func times(_ action: ()->Void) {
            for _ in 0..<self { action() }
        }
    }
    3.times { print("✨ sparkle") }

    // Way 3: Extend Array with safe indexing
    extension Array {
        subscript(safe i:Int)->Element?{ (0..<count).contains(i) ? self[i] : nil }
    }
    print([1,2,3][safe: 5] as Any)

    // Way 4: Extend Double with degrees→radians
    extension Double {
        var radians: Double { self * .pi / 180 }
    }
    print("180 degrees =", 180.0.radians, "radians")

    // QUIZ: Extend Bool with a toggle() mutating method.
}

// -----------------------------------------------------------------------------
// Lesson 20 — Metaphors of Generics
// -----------------------------------------------------------------------------

func lesson20_MetaphorGenerics() {
    header("Lesson 20 — Generics as Metaphor ✨\nWe whisper: 'code that loves all types equally'.")

    // Way 1: Generic Box
    struct Box<T> {
        var value:T
        func describe(){print("A box with:",value)}
    }
    Box(value:"🌹").describe()

    // Way 2: Generic function compare
    func equal<T:Equatable>(_ a:T,_ b:T)->Bool {a==b}
    print("equal(3,3)?",equal(3,3))

    // Way 3: Protocol with associated type
    protocol Container {
        associatedtype Item
        mutating func add(_ item:Item)
        var items:[Item]{get}
    }
    struct Bag<T>:Container{
        var items:[T]=[]
        mutating func add(_ item:T){items.append(item)}
    }
    var bag=Bag<String>()
    bag.add("apple");print("Bag:",bag.items)

    // Way 4: Higher generic artistry
    func repeatItem<T>(_ item:T, times:Int)->[T] {
        Array(repeating:item, count:times)
    }
    print("repeatItem(\"⭐\",3)=",repeatItem("⭐",times:3))

    // QUIZ: Write a generic Pair<T,U> that holds two values.
}

// -----------------------------------------------------------------------------
// Run All
// -----------------------------------------------------------------------------

@main
struct Lessons {
    static func main() async {
        await lesson16_Async()
        lesson17_Functional()
        lesson18_Patterns()
        lesson19_Extensions()
        lesson20_MetaphorGenerics()
        header("Lessons 16–20 complete 🌠\nCode is not just logic — it is poetry in motion.")
    }
}