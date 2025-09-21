// CazzyExploresRust.rs
// Author: Cazzy
// Purpose: An exploratory, educational Rust file demonstrating fundamental and advanced concepts
// This file is written in a learning-first, explanatory style, meant to be both readable and exploratory.

use std::collections::HashMap;
use std::io::{self, Write};

// =======================
// Section 1: Basics
// =======================
fn basics() {
    println!("-- Basics Section --");

    // Variables and mutability
    let x = 5; // immutable by default
    let mut y = 10; // mutable variable
    println!("x = {}, y = {}", x, y);
    y += x;
    println!("After y += x, y = {}", y);

    // Constants
    const MAX_POINTS: u32 = 100_000;
    println!("MAX_POINTS = {}", MAX_POINTS);

    // Shadowing
    let x = x + 1; // we can re-use variable name with new value
    println!("Shadowed x = {}", x);
}

// =======================
// Section 2: Functions & Closures
// =======================
fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn functions_section() {
    println!("-- Functions & Closures Section --");

    let sum = add(3, 7);
    println!("add(3,7) = {}", sum);

    // Closure example
    let multiply = |a: i32, b: i32| a * b;
    println!("Closure multiply(4,5) = {}", multiply(4,5));

    // Higher-order function
    fn apply<F>(func: F, x: i32, y: i32) -> i32
    where
        F: Fn(i32, i32) -> i32,
    {
        func(x, y)
    }

    let result = apply(|a, b| a - b, 10, 3);
    println!("apply closure subtraction 10 - 3 = {}", result);
}

// =======================
// Section 3: Structs & Enums
// =======================
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }

    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}

enum Shape {
    Circle(f64),
    Square(f64),
    Rectangle(f64, f64),
}

fn structs_enums() {
    println!("-- Structs & Enums Section --");

    let rect1 = Rectangle { width: 30, height: 50 };
    let rect2 = Rectangle { width: 10, height: 40 };

    println!("rect1 area = {}", rect1.area());
    println!("rect1 can hold rect2? {}", rect1.can_hold(&rect2));

    let circle = Shape::Circle(5.0);
    match circle {
        Shape::Circle(radius) => println!("Circle radius = {}", radius),
        Shape::Square(side) => println!("Square side = {}", side),
        Shape::Rectangle(w,h) => println!("Rectangle {}x{}", w, h),
    }
}

// =======================
// Section 4: Vectors, Iterators, & Recursion
// =======================
fn recursion_example(n: u32) -> u32 {
    if n <= 1 {
        1
    } else {
        n * recursion_example(n - 1)
    }
}

fn collections_and_iterators() {
    println!("-- Vectors & Iterators Section --");

    let mut v = vec![10, 20, 30, 40];
    v.push(50);
    println!("Vector v = {:?}", v);

    let sum: i32 = v.iter().sum();
    println!("Sum of v = {}", sum);

    // Recursive factorial example
    let fact5 = recursion_example(5);
    println!("Factorial of 5 = {}", fact5);

    // Map over vector
    let doubled: Vec<i32> = v.iter().map(|x| x * 2).collect();
    println!("Doubled vector = {:?}", doubled);
}

// =======================
// Section 5: HashMap & Interactive Example
// =======================
fn hashmap_example() {
    println!("-- HashMap & Interactive Section --");

    let mut scores = HashMap::new();
    scores.insert(String::from("Alice"), 50);
    scores.insert(String::from("Bob"), 70);

    println!("Initial scores: {:?}", scores);

    // Interactive user input example
    print!("Enter your name: ");
    io::stdout().flush().unwrap();
    let mut name = String::new();
    io::stdin().read_line(&mut name).expect("Failed to read line");
    let name = name.trim();

    let score = scores.get(name).unwrap_or(&0);
    println!("Score for {} = {}", name, score);
}

// =======================
// Section 6: Exploratory Exercises
// =======================
fn exploratory() {
    println!("-- Exploratory Section --");

    // Multiple ways to sum numbers
    let numbers = vec![1,2,3,4,5];

    // Method 1: Iterative
    let mut sum = 0;
    for n in &numbers { sum += n; }
    println!("Sum via loop = {}", sum);

    // Method 2: Iterator
    let sum2: i32 = numbers.iter().sum();
    println!("Sum via iter().sum() = {}", sum2);

    // Method 3: Recursive
    fn recursive_sum(nums: &[i32]) -> i32 {
        if nums.is_empty() { 0 } else { nums[0] + recursive_sum(&nums[1..]) }
    }
    println!("Sum via recursion = {}", recursive_sum(&numbers));
}

// =======================
// Main Function
// =======================
fn main() {
    println!("Welcome to CazzyExploresRust!");
    basics();
    functions_section();
    structs_enums();
    collections_and_iterators();
    hashmap_example();
    exploratory();
    println!("All done! Keep exploring Rust and have fun learning. 🚀");
}