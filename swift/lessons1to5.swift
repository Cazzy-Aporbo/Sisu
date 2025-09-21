//
// lesson1to5.swift
// Swift Intro — Lessons 1 to 5 (by Cazzy)
// Copy this whole file into a Playground or run with `swift lesson1to5.swift`
//
// Each lesson is self-contained with multiple approaches and gentle, plain-language notes.
// Students: read the printed notes, study the code examples, then tinker!
//

import Foundation

// small helper to print section headers prettily
func header(_ title: String) {
    print("\n" + String(repeating: "=", count: 60))
    print("  \(title)")
    print(String(repeating: "=", count: 60) + "\n")
}

// small helper for gentle pauses (only to improve readability when running live)
func briefPause(_ ms: UInt32 = 400) {
    // only use this if running interactively in Terminal/Playground that supports sleep
    usleep(ms * 1000)
}

// -----------------------------------------------------------------------------
// Lesson 1 — Hello, Swift
// Goals: printing, strings, interpolation, small functions.
// -----------------------------------------------------------------------------

func lesson1_HelloSwift() {
    header("Lesson 1 — Hello, Swift 🌸\nGoal: print text, strings, interpolation")

    // Way 1: Classic Hello World
    print("// Way 1: classic")
    print("print(\"Hello, Swift!\")")
    print("Output:")
    print("Hello, Swift!")
    briefPause()

    // Way 2: Concatenate strings with +
    print("\n// Way 2: concatenation")
    let greeting = "Hello, "
    let name = "world"
    print("let greeting = \"Hello, \"")
    print("let name = \"world\"")
    print("print(greeting + name + \"!\")")
    print("Output:")
    print(greeting + name + "!")
    briefPause()

    // Way 3: Interpolation (clean, preferred)
    print("\n// Way 3: interpolation (preferred)")
    let person = "Cazzy"
    print("let person = \"Cazzy\"")
    print("print(\"Hello, \\(person)!\")")
    print("Output:")
    print("Hello, \(person)!")
    briefPause()

    // Way 4: Function for reuse
    print("\n// Way 4: reusable function")
    func greet(_ who: String) {
        print("Hello, \(who)!")        // interpolation again
    }
    print("greet(\"students\") -> output:")
    greet("students")
    print("greet(\"Swift learners\") -> output:")
    greet("Swift learners")
    briefPause()

    print("\nTeacher note: try replacing the string with emoji (\"🌍\") — Swift treats emoji as text.")
}

// -----------------------------------------------------------------------------
// Lesson 2 — Variables & Constants
// Goals: let vs var, types, annotations, mutability.
// -----------------------------------------------------------------------------

func lesson2_VariablesConstants() {
    header("Lesson 2 — Variables & Constants ⭐\nGoal: let vs var, type annotations, mutability")

    // Way 1: Constants with `let`
    print("// Way 1: let — constant")
    print("let pi = 3.14159")
    let pi = 3.14159
    print("Output: pi = \(pi)")
    briefPause()

    // Way 2: Variables with `var`
    print("\n// Way 2: var — variable that can change")
    var counter = 0
    print("var counter = 0")
    print("counter -> \(counter)")
    counter += 1
    print("after counter += 1 -> \(counter)")
    briefPause()

    // Way 3: Type annotation (explicit)
    print("\n// Way 3: explicit type annotation")
    var message: String = "Hello!"
    var age: Int = 8
    print("var message: String = \"Hello!\"")
    print("var age: Int = 8")
    print("Output: message = \(message), age = \(age)")
    briefPause()

    // Way 4: Multiple variables and constants
    print("\n// Way 4: multiple declarations")
    var x = 10, y = 20, z = 30
    print("var x = 10, y = 20, z = 30 -> \(x), \(y), \(z)")
    let twins = (a: 2, b: 2)
    print("let twins = (a:2, b:2) -> \(twins)")
    briefPause()

    print("\nTeacher note: prefer `let` unless you specifically need to change the value — it's safer and documents intent.")
}

// -----------------------------------------------------------------------------
// Lesson 3 — Types & Math
// Goals: Int, Double, conversion, operators, functions from Foundation.
// -----------------------------------------------------------------------------

func lesson3_TypesAndMath() {
    header("Lesson 3 — Types & Math ⚡\nGoal: numeric types, conversions, math functions")

    // Integers: Int
    print("// Integers (Int)")
    let a: Int = 7
    let b: Int = 3
    print("let a = 7, b = 3")
    print("a + b = \(a + b)")
    print("a / b = \(a / b)  // integer division truncates")
    briefPause()

    // Floating point: Double
    print("\n// Floating point (Double)")
    let c: Double = 7.0
    let d: Double = 3.0
    print("let c = 7.0, d = 3.0")
    print("c / d = \(c / d)  // floating division")
    briefPause()

    // Mixing requires explicit conversion
    print("\n// Mixing types — explicit conversion")
    let whole: Int = 5
    let fraction: Double = 2.5
    // print(whole + fraction) // ❌ not allowed
    print("Double(whole) + fraction = \(Double(whole) + fraction)")
    briefPause()

    // Useful math functions
    print("\n// Using Foundation math functions: sqrt, pow")
    print("sqrt(16.0) = \(sqrt(16.0))")
    print("pow(2.0, 8.0) = \(pow(2.0, 8.0))")
    briefPause()

    // Way 2: Show a small function that computes average
    print("\n// Small function: compute average of Int array")
    func average(_ numbers: [Int]) -> Double {
        guard !numbers.isEmpty else { return 0.0 }
        let sum = numbers.reduce(0, +)
        return Double(sum) / Double(numbers.count)
    }
    let sample = [10, 20, 30, 40]
    print("sample = \(sample), average(sample) = \(average(sample))")
    briefPause()
}

// -----------------------------------------------------------------------------
// Lesson 4 — Control Flow & Collections
// Goals: if/else, switch, for-in, while, arrays, dictionaries.
// -----------------------------------------------------------------------------

func lesson4_ControlFlowCollections() {
    header("Lesson 4 — Control Flow & Collections 🔁\nGoal: conditionals, loops, arrays, dictionaries")

    // If / else
    print("// If / else")
    let score = 85
    if score >= 90 {
        print("Grade: A")
    } else if score >= 75 {
        print("Grade: B")
    } else {
        print("Grade: C or below")
    }
    briefPause()

    // Switch with range patterns and fallthrough comment
    print("\n// Switch (with pattern matching)")
    let number = 7
    switch number {
        case 0:
            print("zero")
        case 1...5:
            print("between 1 and 5")
        case 6...10:
            print("between 6 and 10")
        default:
            print("larger number")
    }
    briefPause()

    // For-in loops and arrays
    print("\n// Arrays and for-in")
    var fruits = ["apple", "banana", "cherry"]
    print("fruits:", fruits)
    for (index, fruit) in fruits.enumerated() {
        print("fruit[\(index)] = \(fruit)")
    }
    briefPause()

    // While loop & repeat-while
    print("\n// While and repeat-while")
    var countdown = 3
    while countdown > 0 {
        print("countdown:", countdown)
        countdown -= 1
    }
    var r = 0
    repeat {
        print("repeat block, r = \(r)")
        r += 1
    } while r < 2
    briefPause()

    // Dictionary example
    print("\n// Dictionary (maps)")
    var ages: [String: Int] = ["Alice": 10, "Bob": 12]
    ages["Cazzy"] = 9
    for (name, age) in ages {
        print("\(name) is \(age)")
    }
    briefPause()

    print("\nTeacher note: show students how to mutate arrays/dictionaries and how `let` vs `var` affects mutability.")
}

// -----------------------------------------------------------------------------
// Lesson 5 — Functions, Closures & Basics of Structs
// Goals: write functions, use closures, simple struct demo.
// -----------------------------------------------------------------------------

func lesson5_FunctionsClosuresStructs() {
    header("Lesson 5 — Functions, Closures, and Structs 🧩\nGoal: functions, closures, and simple data types")

    // Functions — named, with return
    print("// Named function")
    func add(_ x: Int, _ y: Int) -> Int {
        return x + y
    }
    print("add(3, 4) = \(add(3,4))")
    briefPause()

    // Function shorthand (single-expression)
    print("\n// Single-expression function (implicit return)")
    func square(_ x: Int) -> Int { x * x }
    print("square(6) = \(square(6))")
    briefPause()

    // Closures (inline functions)
    print("\n// Closures (anonymous functions)")
    let multiply: (Int, Int) -> Int = { (a, b) in
        return a * b
    }
    print("multiply(3, 5) = \(multiply(3,5))")

    // Trailing closure and shorthand argument names
    let numbers = [1, 2, 3, 4, 5]
    print("numbers.map { $0 * 2 } ->", numbers.map { $0 * 2 })
    briefPause()

    // Structs — simple immutable data type example
    print("\n// Struct example (value type)")
    struct Point {
        var x: Double
        var y: Double
        // method
        func distance(to other: Point) -> Double {
            let dx = x - other.x
            let dy = y - other.y
            return sqrt(dx*dx + dy*dy)
        }
    }
    let p1 = Point(x: 0, y: 0)
    let p2 = Point(x: 3, y: 4)
    print("p1 = (\(p1.x), \(p1.y)), p2 = (\(p2.x), \(p2.y))")
    print("distance p1 -> p2 = \(p1.distance(to: p2))")
    briefPause()

    // Mutating a struct's var properties
    print("\n// Mutating struct properties on a var instance")
    var moving = Point(x: 1, y: 1)
    print("moving before: \(moving)")
    moving.x = 2
    moving.y = 3
    print("moving after: \(moving)")
    briefPause()

    print("\nTeacher note: emphasize value semantics of structs (copy on assignment) vs classes (reference types) — saved for next lessons.")
}

// -----------------------------------------------------------------------------
// Utility: run selected lessons or all
// -----------------------------------------------------------------------------

func runAllLessons() {
    lesson1_HelloSwift()
    lesson2_VariablesConstants()
    lesson3_TypesAndMath()
    lesson4_ControlFlowCollections()
    lesson5_FunctionsClosuresStructs()
    header("All lessons completed — well done!")
    print("Encourage students to edit examples, change values, and re-run. Learning happens by tinkering.")
}

// If this file is run directly, run all lessons.
// In a Playground you can call individual lessons instead.
runAllLessons()