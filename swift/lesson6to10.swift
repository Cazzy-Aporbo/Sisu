//
// lesson6to10.swift
// Swift Intro — Lessons 6 to 10 (by Cazzy)
// Includes quizzes (with code) for practice!
//

import Foundation

func header(_ title: String) {
    print("\n" + String(repeating: "=", count: 60))
    print("  \(title)")
    print(String(repeating: "=", count: 60) + "\n")
}

// -----------------------------------------------------------------------------
// Lesson 6 — Optionals
// -----------------------------------------------------------------------------

func lesson6_Optionals() {
    header("Lesson 6 — Optionals ❓\nGoal: handling values that might be missing")

    // Way 1: Declaring an optional
    var maybeName: String? = "Alice"
    print("maybeName = \(maybeName!)")  // force unwrap (careful!)
    
    // Way 2: Nil value
    maybeName = nil
    print("maybeName = \(String(describing: maybeName))")
    
    // Way 3: Optional binding
    maybeName = "Bob"
    if let safeName = maybeName {
        print("Hello, \(safeName)!")
    }
    
    // Way 4: Nil coalescing
    maybeName = nil
    print("Hello, \(maybeName ?? "Guest")")
    
    // QUIZ
    print("\nQUIZ: Fix this code so it greets safely without crashing:")
    print("var pet: String? = \"Dog\"")
    print("print(pet!)  // 💥 may crash if nil")
}

// -----------------------------------------------------------------------------
// Lesson 7 — Strings and Characters
// -----------------------------------------------------------------------------

func lesson7_Strings() {
    header("Lesson 7 — Strings and Characters 🔤\nGoal: explore text manipulation")

    // Way 1: Count characters
    let word = "Swift"
    print("word.count = \(word.count)")
    
    // Way 2: Iterate characters
    for char in word {
        print("letter:", char)
    }
    
    // Way 3: String interpolation with numbers
    let score = 42
    print("You scored \(score) points!")
    
    // Way 4: Multiline string
    let poem = """
    Roses are red,
    Violets are blue,
    Swift is fun,
    And powerful too.
    """
    print(poem)
    
    // QUIZ
    print("\nQUIZ: Write code to count the number of vowels in \"education\".")
}

// -----------------------------------------------------------------------------
// Lesson 8 — Arrays and Higher-Order Functions
// -----------------------------------------------------------------------------

func lesson8_Arrays() {
    header("Lesson 8 — Arrays 📚\nGoal: collection operations, map/filter/reduce")

    let numbers = [1, 2, 3, 4, 5]
    
    // Way 1: Manual loop
    var squares: [Int] = []
    for n in numbers { squares.append(n*n) }
    print("Squares:", squares)
    
    // Way 2: map
    let cubes = numbers.map { $0 * $0 * $0 }
    print("Cubes:", cubes)
    
    // Way 3: filter
    let evens = numbers.filter { $0 % 2 == 0 }
    print("Evens:", evens)
    
    // Way 4: reduce
    let sum = numbers.reduce(0, +)
    print("Sum:", sum)
    
    // QUIZ
    print("\nQUIZ: Use map/filter/reduce to find the sum of all odd numbers in [10,11,12,13].")
}

// -----------------------------------------------------------------------------
// Lesson 9 — Dictionaries
// -----------------------------------------------------------------------------

func lesson9_Dictionaries() {
    header("Lesson 9 — Dictionaries 📖\nGoal: key-value pairs")

    // Way 1: Create dictionary
    var ages: [String: Int] = ["Alice": 12, "Bob": 14]
    print("Ages:", ages)
    
    // Way 2: Add/update
    ages["Charlie"] = 10
    print("Updated:", ages)
    
    // Way 3: Optional lookup
    if let age = ages["Alice"] {
        print("Alice is \(age)")
    }
    
    // Way 4: Loop over dictionary
    for (name, age) in ages {
        print("\(name): \(age)")
    }
    
    // QUIZ
    print("\nQUIZ: Create a dictionary of 3 fruits with their colors. Print only the keys (fruit names).")
}

// -----------------------------------------------------------------------------
// Lesson 10 — Structs and Methods
// -----------------------------------------------------------------------------

func lesson10_Structs() {
    header("Lesson 10 — Structs 🧩\nGoal: define custom types with properties and methods")

    // Way 1: Basic struct
    struct Dog {
        var name: String
        var age: Int
    }
    let rover = Dog(name: "Rover", age: 3)
    print("Dog:", rover)
    
    // Way 2: Method
    struct Cat {
        var name: String
        func meow() {
            print("\(name) says meow!")
        }
    }
    let whiskers = Cat(name: "Whiskers")
    whiskers.meow()
    
    // Way 3: Mutating method
    struct Counter {
        var value: Int = 0
        mutating func increment() { value += 1 }
    }
    var counter = Counter()
    counter.increment()
    print("Counter =", counter.value)
    
    // Way 4: Struct with computed property
    struct Rectangle {
        var width: Double
        var height: Double
        var area: Double { width * height }
    }
    let rect = Rectangle(width: 5, height: 4)
    print("Area =", rect.area)
    
    // QUIZ
    print("\nQUIZ: Define a struct `Circle` with a radius property and a computed property `circumference` (2 * pi * r).")
}

// -----------------------------------------------------------------------------
// Run all lessons
// -----------------------------------------------------------------------------

func runAllLessons() {
    lesson6_Optionals()
    lesson7_Strings()
    lesson8_Arrays()
    lesson9_Dictionaries()
    lesson10_Structs()
    header("All lessons 6–10 completed 🎉 — Try the quiz tasks now!")
}

runAllLessons()