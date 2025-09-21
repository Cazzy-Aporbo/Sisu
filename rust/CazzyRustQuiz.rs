// CazzyRustQuiz.rs
// Author: Cazzy
// Purpose: Interactive Rust quiz to test knowledge and teach concepts

use std::io::{self, Write};

struct Question<'a> {
    prompt: &'a str,
    options: Vec<&'a str>,
    answer: usize, // index of correct option
}

fn main() {
    println!("Welcome to Cazzy's Rust Quiz! Let's test your Rust knowledge.");
    println!("Type the number of your choice and press Enter.\n");

    let questions = vec![
        Question {
            prompt: "1. Which keyword is used for defining a constant in Rust?",
            options: vec!["var", "let", "const", "static"],
            answer: 2,
        },
        Question {
            prompt: "2. Which trait allows a type to be printed using {:?}?",
            options: vec!["Display", "Debug", "Clone", "Copy"],
            answer: 1,
        },
        Question {
            prompt: "3. Which of the following is a valid enum in Rust?",
            options: vec![
                "enum Color { Red, Green, Blue }",
                "enum Color = [Red, Green, Blue]",
                "enum Color { Red = 1, Green = 2, Blue = 3 }",
                "Both 1 and 3 are valid",
            ],
            answer: 3,
        },
        Question {
            prompt: "4. What does 'ownership' in Rust prevent?",
            options: vec![
                "Memory leaks and dangling pointers",
                "Type mismatch",
                "Variable shadowing",
                "Syntax errors",
            ],
            answer: 0,
        },
        Question {
            prompt: "5. Which method is used to iterate over a vector's values?",
            options: vec!["v.iter()", "v.map()", "v.fold()", "v.collect()"],
            answer: 0,
        },
    ];

    let mut score = 0;

    for q in &questions {
        println!("{}", q.prompt);
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
                    println!("✅ Correct!\n");
                    score += 1;
                } else {
                    println!("❌ Incorrect. The correct answer was: {}\n", q.options[q.answer]);
                }
            }
            _ => println!("Invalid input, moving to next question.\n"),
        }
    }

    println!("Quiz Complete! Your score: {}/{}", score, questions.len());

    if score == questions.len() {
        println!("🎉 Perfect score! You're a Rust wizard!");
    } else if score >= questions.len() / 2 {
        println!("👍 Good job! Keep practicing to master Rust.");
    } else {
        println!("💡 Keep learning! Rust takes time, but you're on the path.");
    }
}