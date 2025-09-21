//
// lesson21to25.swift
// Swift Lessons 21–25 — intermediate/advanced, surreal, visionary
// by Cazzy
//

import Foundation

func header(_ title: String) {
    print("\n" + String(repeating: "🚀", count: 50))
    print("  \(title)")
    print(String(repeating: "🚀", count: 50) + "\n")
}

// -----------------------------------------------------------------------------
// Lesson 21 — Result & Error Futures
// -----------------------------------------------------------------------------

func lesson21_Result() {
    header("Lesson 21 — Result as Schrödinger’s Box 📦🐱\nSuccess + Failure coexist until opened.")

    // Way 1: Result type
    enum MathError: Error { case imaginary }
    func safeRoot(_ x: Double) -> Result<Double, MathError> {
        if x < 0 { return .failure(.imaginary) }
        return .success(sqrt(x))
    }

    // Way 2: Switch result
    let outcome = safeRoot(-9)
    switch outcome {
    case .success(let v): print("Root:", v)
    case .failure: print("The cat is imaginary 🐱✨")
    }

    // Way 3: Map over result
    let result = safeRoot(16).map { $0 * 2 }
    print("Mapped result:", result)

    // Way 4: FlatMap
    let chained = safeRoot(25).flatMap { safeRoot($0) }
    print("Chained result:", chained)

    // QUIZ: Write a function `safeDivide(a:b:) -> Result<Double,Error>`.
}

// -----------------------------------------------------------------------------
// Lesson 22 — Concurrency: Async Sequences
// -----------------------------------------------------------------------------

func lesson22_AsyncSeq() async {
    header("Lesson 22 — Async Sequences 🌊\nA river of values flowing over time.")

    // Way 1: Simple async sequence
    struct Counter: AsyncSequence {
        typealias Element = Int
        struct AsyncIterator: AsyncIteratorProtocol {
            var current = 0
            mutating func next() async -> Int? {
                guard current < 3 else { return nil }
                defer { current += 1 }
                return current
            }
        }
        func makeAsyncIterator() -> AsyncIterator { AsyncIterator() }
    }

    for await n in Counter() {
        print("Async count:", n)
    }

    // Way 2: AsyncStream
    let stream = AsyncStream(String.self) { continuation in
        continuation.yield("First drop 💧")
        continuation.yield("Second drop 💧")
        continuation.finish()
    }
    for await drop in stream {
        print("Stream says:", drop)
    }

    // QUIZ: Build an AsyncStream that yields 🌙 every second, 3 times.
}

// -----------------------------------------------------------------------------
// Lesson 23 — Memory Games (Value vs Reference)
// -----------------------------------------------------------------------------

func lesson23_Memory() {
    header("Lesson 23 — Memory: Value vs Reference 🧠\nTwo ways to exist in time.")

    // Way 1: Struct = copy
    struct Hero { var name:String }
    var a = Hero(name:"Neo")
    var b = a
    b.name = "Trinity"
    print("a:",a.name,"b:",b.name)

    // Way 2: Class = reference
    class Villain { var name:String; init(_ n:String){name=n} }
    let x = Villain("Agent")
    let y = x
    y.name = "Smith"
    print("x:",x.name,"y:",y.name)

    // Way 3: Identity check
    print("x and y are same object?", x === y)

    // Way 4: Copy-on-write
    var arr1 = [1,2,3]
    var arr2 = arr1
    arr2.append(4)
    print("arr1:",arr1,"arr2:",arr2)

    // QUIZ: Create a struct `Book` and a class `Library`. Show how mutating copies differ.
}

// -----------------------------------------------------------------------------
// Lesson 24 — SwiftUI Spirit (DSL Thinking)
// -----------------------------------------------------------------------------

func lesson24_SwiftUI() {
    header("Lesson 24 — SwiftUI Spirit 🎨\nCode as canvas, describing worlds.")

    // Even without real SwiftUI imports, we mimic DSL thinking.

    // Way 1: Declarative vibe
    func Button(_ label:String, action:()->Void) {
        print("Button[\(label)] clicked")
        action()
    }
    Button("Hello") { print("World!") }

    // Way 2: Nested trees
    struct VStack {
        let children:[String]
        func render(){print("Vertical stack:",children)}
    }
    VStack(children:["🌹","🌻","🌼"]).render()

    // Way 3: Functions returning UI pieces
    func Greeting(name:String)->String{ "Hello, \(name)" }
    print(Greeting(name:"Cazzy"))

    // Way 4: Functional DSL
    let ui = ["Button: Tap Me","Label: Stars ✨"]
    ui.forEach{print("UI:",$0)}

    // QUIZ: Pretend to build a “LoginView” with username + password + submit button.
}

// -----------------------------------------------------------------------------
// Lesson 25 — Metaprogramming Vibes
// -----------------------------------------------------------------------------

func lesson25_Meta() {
    header("Lesson 25 — Metaprogramming Vibes 🧬\nCode gazes into its own mirror.")

    // Swift doesn’t allow macros yet in full, but we play.

    // Way 1: Reflection with Mirror
    struct Person { let name:String; let age:Int }
    let p = Person(name:"Ada",age:36)
    let m = Mirror(reflecting:p)
    for child in m.children {
        print("Mirror sees:",child.label ?? "?",child.value)
    }

    // Way 2: Generic reflection helper
    func describe<T>(_ value:T){
        let mirror=Mirror(reflecting:value)
        print("Describing",type(of:value))
        for c in mirror.children{print("·",c.label ?? "?",c.value)}
    }
    describe(p)

    // Way 3: Dynamic key-value via Dictionary
    let obj:[String:Any]=["planet":"Mars","distance":225e6]
    for(k,v)in obj{print("Key:",k,"Val:",v)}

    // Way 4: Pretend DSL: code that writes code
    func macro(_ name:String)->String{"Generated code for \(name)"}
    print(macro("FutureType"))

    // QUIZ: Use Mirror to inspect an Array of 3 elements.
}

// -----------------------------------------------------------------------------
// Run All
// -----------------------------------------------------------------------------

@main
struct Lessons {
    static func main() async {
        lesson21_Result()
        await lesson22_AsyncSeq()
        lesson23_Memory()
        lesson24_SwiftUI()
        lesson25_Meta()
        header("Lessons 21–25 complete 🌠\nBeyond basics, Swift becomes philosophy.")
    }
}