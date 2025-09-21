// CazzyExploresRust2.rs
// Author: Cazzy
// Purpose: Advanced Rust exploration - generics, traits, lifetimes, async, and high-level patterns
// Written in a clear, exploratory style, designed for learning and experimentation.

use std::collections::HashMap;
use std::future::Future;
use std::pin::Pin;
use std::time::Duration;
use std::thread;

// =======================
// Section 1: Generics & Traits
// =======================
trait Summable<T> {
    fn sum_items(&self) -> T;
}

impl Summable<i32> for Vec<i32> {
    fn sum_items(&self) -> i32 {
        self.iter().sum()
    }
}

fn generics_and_traits() {
    println!("-- Generics & Traits Section --");

    let numbers = vec![10, 20, 30];
    println!("Numbers: {:?}", numbers);
    println!("Sum via trait: {}", numbers.sum_items());

    // Generic function
    fn print_type_and_value<T: std::fmt::Debug>(value: T) {
        println!("Type & value: {:?}", value);
    }

    print_type_and_value(42);
    print_type_and_value("Hello Rust!");
}

// =======================
// Section 2: Lifetimes Explained
// =======================
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    // Returns the longer string; lifetime ensures reference is valid
    if x.len() > y.len() { x } else { y }
}

fn lifetimes_section() {
    println!("-- Lifetimes Section --");

    let string1 = String::from("short");
    let string2 = String::from("longer string");
    let result = longest(&string1, &string2);
    println!("Longest string: {}", result);
}

// =======================
// Section 3: Advanced Enums & Pattern Matching
// =======================
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}

fn enums_and_matching() {
    println!("-- Advanced Enums Section --");

    let messages = vec![
        Message::Quit,
        Message::Move { x: 10, y: 20 },
        Message::Write(String::from("Hello World")),
        Message::ChangeColor(255, 255, 0),
    ];

    for msg in messages {
        match msg {
            Message::Quit => println!("Quit message received"),
            Message::Move { x, y } => println!("Move to ({}, {})", x, y),
            Message::Write(text) => println!("Write message: {}", text),
            Message::ChangeColor(r, g, b) => println!("Change color to RGB({}, {}, {})", r, g, b),
        }
    }
}

// =======================
// Section 4: Closures & Higher-Order Functions
// =======================
fn higher_order_section() {
    println!("-- Closures & Higher-Order Functions --");

    let add = |a: i32, b: i32| a + b;
    let multiply = |a: i32, b: i32| a * b;

    fn apply<F>(func: F, x: i32, y: i32) -> i32
    where
        F: Fn(i32, i32) -> i32,
    {
        func(x, y)
    }

    println!("Apply add: {}", apply(add, 5, 7));
    println!("Apply multiply: {}", apply(multiply, 5, 7));
}

// =======================
// Section 5: Async & Concurrency (Exploratory)
// =======================
fn async_example() {
    println!("-- Async & Concurrency Section --");

    fn pretend_async_task(name: &str, duration_ms: u64) -> Pin<Box<dyn Future<Output = String>>> {
        let name = name.to_string();
        Box::pin(async move {
            thread::sleep(Duration::from_millis(duration_ms));
            format!("Task {} complete after {}ms", name, duration_ms)
        })
    }

    let task1 = pretend_async_task("A", 500);
    let task2 = pretend_async_task("B", 300);

    // Simple executor simulation
    let rt = futures::executor::block_on(async {
        let res1 = task1.await;
        let res2 = task2.await;
        println!("{}", res1);
        println!("{}", res2);
    });
}

// =======================
// Section 6: Mini Exploratory Project
// =======================
struct Particle {
    x: f64,
    y: f64,
    vx: f64,
    vy: f64,
}

impl Particle {
    fn update(&mut self) {
        self.x += self.vx;
        self.y += self.vy;
    }

    fn display(&self) {
        println!("Particle at ({:.2}, {:.2}) moving ({:.2}, {:.2})", self.x, self.y, self.vx, self.vy);
    }
}

fn particle_simulation() {
    println!("-- Particle Simulation --");
    let mut particles = vec![
        Particle { x: 0.0, y: 0.0, vx: 1.0, vy: 0.5 },
        Particle { x: 5.0, y: 5.0, vx: -0.3, vy: 0.8 },
    ];

    for step in 0..5 {
        println!("Step {}", step);
        for p in &mut particles {
            p.update();
            p.display();
        }
    }
}

// =======================
// Main Function
// =======================
fn main() {
    println!("Welcome to CazzyExploresRust2!");
    generics_and_traits();
    lifetimes_section();
    enums_and_matching();
    higher_order_section();
    async_example();
    particle_simulation();
    println!("Exploration complete! Keep experimenting and building in Rust.");
}