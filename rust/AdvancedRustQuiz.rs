// CazzyRustAdvancedQuiz.rs
// Author: Cazzy
// Purpose: Advanced Rust quiz with randomized questions, difficulty levels, explanations, and progress tracking.

use rand::seq::SliceRandom;
use std::collections::HashMap;
use std::fs::{self, OpenOptions};
use std::io::{self, Write};
use std::path::Path;

struct Question<'a> {
    prompt: &'a str,
    options: Vec<&'a str>,
    answer: usize,
    explanation: &'a str,
    difficulty: &'a str,
}

fn main() {
    println!("Welcome to Cazzy's Advanced Rust Quiz!");
    println!("Choose difficulty level: 1. Beginner 2. Intermediate 3. Advanced");

    let mut level_input = String::new();
    io::stdin().read_line(&mut level_input).unwrap();
    let difficulty = match level_input.trim() {
        "1" => "Beginner",
        "2" => "Intermediate",
        "3" => "Advanced",
        _ => {
            println!("Invalid input, defaulting to Beginner.");
            "Beginner"
        }
    };

    // Question bank
    let mut questions = vec![
        Question {
            prompt: "Which keyword defines a constant in Rust?",
            options: vec!["var", "let", "const", "static"],
            answer: 2,
            explanation: "const is used for compile-time constants.",
            difficulty: "Beginner",
        },
        Question {
            prompt: "Which trait allows {:?} formatting?",
            options: vec!["Display", "Debug", "Clone", "Copy"],
            answer: 1,
            explanation: "Debug trait allows {:?} formatting.",
            difficulty: "Beginner",
        },
        Question {
            prompt: "Which statement about ownership is true?",
            options: vec![
                "Rust prevents dangling pointers",
                "Rust ignores lifetimes",
                "Variables can be copied freely",
                "Borrowing is optional",
            ],
            answer: 0,
            explanation: "Ownership ensures memory safety by preventing dangling pointers.",
            difficulty: "Intermediate",
        },
        Question {
            prompt: "What is a valid way to declare a generic function?",
            options: vec![
                "fn add<T>(x:T,y:T)->T { x+y }",
                "fn add<T: std::ops::Add<Output=T>>(x:T,y:T)->T { x+y }",
                "fn add(x,y) { x+y }",
                "fn add<T: Clone>(x:T,y:T) { x+y }",
            ],
            answer: 1,
            explanation: "You need a trait bound specifying Add<Output=T> for generics.",
            difficulty: "Advanced",
        },
        Question {
            prompt: "Which is a correct async block?",
            options: vec![
                "async { 5 + 5 }",
                "await { 5 + 5 }",
                "async fn x { 5+5 }",
                "fn async { 5+5 }",
            ],
            answer: 0,
            explanation: "Async block syntax is async { ... }.",
            difficulty: "Advanced",
        },
    ];

    // Filter by difficulty
    questions.retain(|q| q.difficulty == difficulty);

    // Shuffle questions
    let mut rng = rand::thread_rng();
    questions.shuffle(&mut rng);

    // Load previous score
    let score_file = "quiz_score.txt";
    let mut total_score: HashMap<String, u32> = if Path::new(score_file).exists() {
        let content = fs::read_to_string(score_file).unwrap_or_default();
        serde_json::from_str(&content).unwrap_or_default()
    } else {
        HashMap::new()
    };

    let mut session_score = 0;

    for q in &questions {
        println!("\n{}", q.prompt);
        for (i, option) in q.options.iter().enumerate() {
            println!("  {}. {}", i + 1, option);
        }

        print!("Your answer: ");
        io::stdout().flush().unwrap();
        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();

        match input.trim().parse::<usize>() {
            Ok(num) if num > 0 && num <= q.options.len() => {
                if num - 1 == q.answer {
                    println!("✅ Correct!");
                    session_score += 1;
                } else {
                    println!("❌ Incorrect. Correct: {}", q.options[q.answer]);
                }
                println!("💡 Explanation: {}", q.explanation);
            }
            _ => println!("Invalid input, skipping..."),
        }
    }

    println!("\nSession Score: {}/{}", session_score, questions.len());

    // Update total score
    let entry = total_score.entry(difficulty.to_string()).or_insert(0);
    *entry += session_score;

    // Save scores
    let content = serde_json::to_string(&total_score).unwrap();
    fs::write(score_file, content).unwrap();

    println!("Total score for {}: {}", difficulty, total_score[difficulty]);
    println!("Thanks for playing! Keep exploring Rust and learning!");
}