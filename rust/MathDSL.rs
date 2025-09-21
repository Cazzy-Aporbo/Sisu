// CazzyMathDSL.rs
// Author: Cazzy
// Purpose: Master-level Rust mini-project: small DSL interpreter

use std::str::Chars;

#[derive(Debug)]
enum Expr {
    Number(i32),
    Add(Box<Expr>, Box<Expr>),
    Mul(Box<Expr>, Box<Expr>),
}

fn parse_expr(chars: &mut Chars) -> Expr {
    let mut current = Expr::Number(chars.next().unwrap().to_digit(10).unwrap() as i32);

    while let Some(c) = chars.next() {
        match c {
            '+' => {
                let right = parse_expr(chars);
                current = Expr::Add(Box::new(current), Box::new(right));
            }
            '*' => {
                let right = parse_expr(chars);
                current = Expr::Mul(Box::new(current), Box::new(right));
            }
            _ => {}
        }
    }

    current
}

fn eval(expr: &Expr) -> i32 {
    match expr {
        Expr::Number(n) => *n,
        Expr::Add(a, b) => eval(a) + eval(b),
        Expr::Mul(a, b) => eval(a) * eval(b),
    }
}

fn main() {
    println!("Welcome to Cazzy's Mini Math DSL!");
    let input = "2+3*4";
    println!("Evaluating expression: {}", input);

    let mut chars = input.chars();
    let expr = parse_expr(&mut chars);
    let result = eval(&expr);

    println!("Result: {}", result);
    println!("Try expanding: add parentheses, subtraction, or variables!");
}