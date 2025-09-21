//
// lesson11to15.swift
// Swift Advanced Intro — Lessons 11 to 15 (by Cazzy)
// More unique thinking, engaging teaching, and multiple approaches
//

import Foundation

func header(_ title: String) {
    print("\n" + String(repeating: "✦", count: 60))
    print("  \(title)")
    print(String(repeating: "✦", count: 60) + "\n")
}

// -----------------------------------------------------------------------------
// Lesson 11 — Functions as First-Class Citizens
// -----------------------------------------------------------------------------

func lesson11_Functions() {
    header("Lesson 11 — Functions as First-Class Citizens 🪄")

    // Way 1: Function assigned to a variable
    func square(_ x: Int) -> Int { x * x }
    let f = square
    print("Square via f:", f(5))

    // Way 2: Inline closure
    let cube = { (x: Int) -> Int in x * x * x }
    print("Cube via closure:", cube(3))

    // Way 3: Passing functions
    func applyTwice(_ f: (Int) -> Int, _ value: Int) -> Int {
        f(f(value))
    }
    print("applyTwice(square, 2) =", applyTwice(square, 2))

    // Way 4: Returning functions
    func makeAdder(_ n: Int) -> (Int) -> Int {
        return { $0 + n }
    }
    let addTen = makeAdder(10)
    print("5 + 10 =", addTen(5))

    // QUIZ: Write a function `makeMultiplier` that returns a closure multiplying by `n`.
}

// -----------------------------------------------------------------------------
// Lesson 12 — Enumerations with Power
// -----------------------------------------------------------------------------

func lesson12_Enums() {
    header("Lesson 12 — Enums with Associated Values 🌀")

    // Way 1: Basic enum
    enum Direction { case north, south, east, west }
    let dir: Direction = .north
    print("Direction is", dir)

    // Way 2: Enums with raw values
    enum Planet: Int { case mercury = 1, venus, earth, mars }
    print("Planet earth has raw value:", Planet.earth.rawValue)

    // Way 3: Enums with associated values
    enum Result {
        case success(String)
        case failure(Int)
    }
    let outcome = Result.success("Data loaded")
    switch outcome {
    case .success(let msg): print("Success:", msg)
    case .failure(let code): print("Error code:", code)
    }

    // Way 4: Recursive enums (mind bender)
    indirect enum Expr {
        case number(Int)
        case add(Expr, Expr)
    }
    let expr = Expr.add(.number(2), .add(.number(3), .number(4)))
    print("Nested expression created!")
    
    // QUIZ: Define an enum `Mood` with cases happy, sad(String), excited(Int).
}

// -----------------------------------------------------------------------------
// Lesson 13 — Protocols and Extensions
// -----------------------------------------------------------------------------

func lesson13_Protocols() {
    header("Lesson 13 — Protocols & Extensions 🧩")

    // Way 1: Protocol definition
    protocol Greetable { func greet() }
    struct Person: Greetable {
        var name: String
        func greet() { print("Hi, I'm \(name)") }
    }
    Person(name: "Sam").greet()

    // Way 2: Protocol with property
    protocol Named { var name: String { get } }
    struct Dog: Named { var name: String }
    print("Dog named:", Dog(name: "Fido").name)

    // Way 3: Extensions
    extension Int {
        var squared: Int { self * self }
    }
    print("5 squared =", 5.squared)

    // Way 4: Protocol + extension default implementation
    protocol Describable { func describe() }
    extension Describable {
        func describe() { print("Just something describable.") }
    }
    struct Book: Describable {}
    Book().describe()

    // QUIZ: Make a protocol `Playable` with a `play()` method. Conform `Guitar` to it.
}

// -----------------------------------------------------------------------------
// Lesson 14 — Error Handling
// -----------------------------------------------------------------------------

func lesson14_Errors() {
    header("Lesson 14 — Error Handling 🚨")

    enum MathError: Error { case divideByZero }

    // Way 1: Throwing function
    func safeDivide(_ a: Int, _ b: Int) throws -> Int {
        if b == 0 { throw MathError.divideByZero }
        return a / b
    }

    // Way 2: do-catch
    do {
        let result = try safeDivide(10, 0)
        print("Result:", result)
    } catch {
        print("Caught an error:", error)
    }

    // Way 3: try? turns failure into nil
    let maybeResult = try? safeDivide(10, 2)
    print("try? result:", maybeResult ?? "nil")

    // Way 4: try! crashes if error happens (⚠️ dangerous)
    // let crashResult = try! safeDivide(1, 0)

    // QUIZ: Write a throwing function `squareRoot` that throws if input < 0.
}

// -----------------------------------------------------------------------------
// Lesson 15 — Generics & Creativity
// -----------------------------------------------------------------------------

func lesson15_Generics() {
    header("Lesson 15 — Generics 🌈")

    // Way 1: Generic identity function
    func identity<T>(_ x: T) -> T { x }
    print("identity(42) =", identity(42))
    print("identity(\"hi\") =", identity("hi"))

    // Way 2: Generic stack
    struct Stack<T> {
        private var items: [T] = []
        mutating func push(_ item: T) { items.append(item) }
        mutating func pop() -> T? { items.popLast() }
    }
    var intStack = Stack<Int>()
    intStack.push(1); intStack.push(2)
    print("Popped:", intStack.pop() ?? "nil")

    // Way 3: Generic constraint
    func areEqual<T: Equatable>(_ a: T, _ b: T) -> Bool { a == b }
    print("Compare:", areEqual("cat", "dog"))

    // Way 4: Mix generics with extensions
    extension Array where Element: Comparable {
        func secondSmallest() -> Element? {
            let sortedArr = self.sorted()
            return sortedArr.count > 1 ? sortedArr[1] : nil
        }
    }
    print("[3,1,2].secondSmallest() =", [3,1,2].secondSmallest() ?? "nil")

    // QUIZ: Make a generic function `swapTwo` that swaps two values.
}

// -----------------------------------------------------------------------------
// Run All
// -----------------------------------------------------------------------------

func runAllLessons() {
    lesson11_Functions()
    lesson12_Enums()
    lesson13_Protocols()
    lesson14_Errors()
    lesson15_Generics()
    header("Lessons 11–15 complete 🌟 — Time for you to solve the quizzes!")
}

runAllLessons()