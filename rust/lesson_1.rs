/*
 * RUST TUTOR: A COMPREHENSIVE LEARNING JOURNEY
 * 
 * This file serves as an interactive Rust tutorial, covering fundamental to
 * advanced concepts with detailed explanations, practical examples, and
 * hands-on exercises.
 */

// ==========================================================================
// 1. GETTING STARTED: RUST FUNDAMENTALS
// ==========================================================================

/// Section 1: Variables and Mutability
/// -----------------------------------
/// Rust variables are immutable by default. Use `mut` to make them mutable.
/// This encourages safe programming practices and prevents accidental mutations.
fn variables_and_mutability() {
    println!("\n=== VARIABLES AND MUTABILITY ===");
    
    // Immutable variable
    let x = 5;
    println!("Immutable x: {}", x);
    // x = 6; // This would cause a compile error!
    
    // Mutable variable
    let mut y = 5;
    println!("Original y: {}", y);
    y = 10;
    println!("Modified y: {}", y);
    
    // Constants (must have type annotation)
    const MAX_POINTS: u32 = 100_000;
    println!("Constant MAX_POINTS: {}", MAX_POINTS);
    
    // Shadowing (creating a new variable with the same name)
    let z = 5;
    let z = z + 1;
    let z = z * 2;
    println!("Shadowed z: {}", z);
    
    // Shadowing vs mutability
    let spaces = "   ";
    let spaces = spaces.len(); // This is allowed (shadowing)
    println!("Spaces length: {}", spaces);
    
    // mut spaces = spaces.len(); // This would cause a type error!
}

/// Exercise 1: Fix the code to make it compile
fn exercise_1() {
    println!("\n--- Exercise 1 ---");
    let number = 3;
    // number = 5; // Fix this line to make it compile
    println!("Number should be 5: {}", number);
}

// ==========================================================================
// 2. DATA TYPES: STATIC TYPING IN RUST
// ==========================================================================

/// Section 2: Data Types
/// ---------------------
/// Rust is statically typed, meaning it must know all types at compile time.
/// The compiler can usually infer types, but sometimes annotations are needed.
fn data_types() {
    println!("\n=== DATA TYPES ===");
    
    // Scalar types: integers, floating-point, boolean, character
    let integer: i32 = 42;
    let float: f64 = 3.14;
    let boolean: bool = true;
    let character: char = 'R';
    
    println!("Integer: {}, Float: {}, Boolean: {}, Char: {}", 
             integer, float, boolean, character);
    
    // Compound types: tuples and arrays
    let tuple: (i32, f64, char) = (42, 3.14, 'R');
    println!("Tuple: ({}, {}, {})", tuple.0, tuple.1, tuple.2);
    
    // Destructuring a tuple
    let (a, b, c) = tuple;
    println!("Destructured: {}, {}, {}", a, b, c);
    
    // Arrays (fixed length)
    let array: [i32; 5] = [1, 2, 3, 4, 5];
    println!("Array: {:?}", array);
    println!("First element: {}", array[0]);
    
    // Vector (dynamic array)
    let vector: Vec<i32> = vec![1, 2, 3, 4, 5];
    println!("Vector: {:?}", vector);
}

/// Exercise 2: Create a tuple with three different types and print them
fn exercise_2() {
    println!("\n--- Exercise 2 ---");
    // Your code here
}

// ==========================================================================
// 3. FUNCTIONS AND CONTROL FLOW
// ==========================================================================

/// Section 3: Functions
/// --------------------
/// Functions are declared with `fn`. Return type is specified with `->`.
/// The last expression in a function is implicitly returned.
fn functions_and_control_flow() {
    println!("\n=== FUNCTIONS AND CONTROL FLOW ===");
    
    // Function call
    let result = add_numbers(5, 7);
    println!("5 + 7 = {}", result);
    
    // Expression vs statement
    let y = {
        let x = 3;
        x + 1 // No semicolon makes this an expression that returns a value
    };
    println!("The value of y is: {}", y);
    
    // Conditional statements
    let number = 7;
    if number < 5 {
        println!("Condition was true");
    } else {
        println!("Condition was false");
    }
    
    // Using if in a let statement
    let condition = true;
    let value = if condition { 5 } else { 6 };
    println!("The value is: {}", value);
    
    // Loops
    let mut counter = 0;
    let result = loop {
        counter += 1;
        if counter == 10 {
            break counter * 2; // Break with a value
        }
    };
    println!("The result is: {}", result);
    
    // While loop
    let mut number = 3;
    while number != 0 {
        println!("{}!", number);
        number -= 1;
    }
    println!("LIFTOFF!!!");
    
    // For loop (safer and more concise)
    let array = [10, 20, 30, 40, 50];
    for element in array.iter() {
        println!("The value is: {}", element);
    }
    
    // Range with for loop
    for number in (1..4).rev() {
        println!("{}!", number);
    }
    println!("LIFTOFF!!!");
}

fn add_numbers(x: i32, y: i32) -> i32 {
    x + y // No semicolon = return value
}

/// Exercise 3: Create a function that returns the factorial of a number
fn exercise_3(n: u32) -> u32 {
    println!("\n--- Exercise 3 ---");
    // Your code here (calculate factorial of n)
    1 // placeholder
}

// ==========================================================================
// 4. OWNERSHIP: RUST'S MOST UNIQUE FEATURE
// ==========================================================================

/// Section 4: Ownership
/// --------------------
/// Ownership is Rust's most unique feature that enables memory safety without
/// garbage collection. It's based on three rules:
/// 1. Each value has a variable called its owner.
/// 2. There can only be one owner at a time.
/// 3. When the owner goes out of scope, the value is dropped.
fn ownership_demo() {
    println!("\n=== OWNERSHIP ===");
    
    // String type (heap-allocated) vs string literal (compile-time)
    let s1 = String::from("hello");
    let s2 = s1; // s1 is moved to s2, s1 is no longer valid
    
    // println!("{}", s1); // This would cause a compile error!
    println!("s2: {}", s2);
    
    // Clone to deeply copy the heap data
    let s3 = s2.clone();
    println!("s2: {}, s3: {}", s2, s3);
    
    // Ownership and functions
    let s = String::from("hello");
    takes_ownership(s);
    // println!("{}", s); // This would error - s was moved
    
    let x = 5;
    makes_copy(x);
    println!("x is still valid: {}", x); // x is fine because i32 has Copy trait
    
    // Return values and scope
    let s1 = gives_ownership();
    let s2 = String::from("hello");
    let s3 = takes_and_gives_back(s2);
    
    println!("s1: {}, s3: {}", s1, s3);
}

fn takes_ownership(some_string: String) {
    println!("{}", some_string);
} // some_string goes out of scope and drop is called

fn makes_copy(some_integer: i32) {
    println!("{}", some_integer);
} // some_integer goes out of scope but nothing special happens

fn gives_ownership() -> String {
    let some_string = String::from("hello");
    some_string
}

fn takes_and_gives_back(a_string: String) -> String {
    a_string
}

/// Exercise 4: Fix the ownership error in this function
fn exercise_4() {
    println!("\n--- Exercise 4 ---");
    let s1 = String::from("hello");
    let s2 = s1;
    // println!("{}, world!", s1); // Fix this line
}

// ==========================================================================
// 5. REFERENCES AND BORROWING
// ==========================================================================

/// Section 5: References and Borrowing
/// -----------------------------------
/// References allow you to refer to a value without taking ownership.
/// Rules:
/// 1. At any time, you can have either one mutable reference or any number of immutable references.
/// 2. References must always be valid.
fn references_and_borrowing() {
    println!("\n=== REFERENCES AND BORROWING ===");
    
    let s1 = String::from("hello");
    let len = calculate_length(&s1);
    println!("The length of '{}' is {}.", s1, len);
    
    // Mutable references
    let mut s = String::from("hello");
    change(&mut s);
    println!("After change: {}", s);
    
    // Only one mutable reference at a time
    let r1 = &mut s;
    // let r2 = &mut s; // This would cause a compile error!
    println!("r1: {}", r1);
    
    // Multiple immutable references are fine
    let r1 = &s;
    let r2 = &s;
    println!("r1: {}, r2: {}", r1, r2);
    
    // References must not dangle!
    let reference = no_dangle();
    println!("Not dangling: {}", reference);
}

fn calculate_length(s: &String) -> usize {
    s.len()
}

fn change(s: &mut String) {
    s.push_str(", world");
}

fn no_dangle() -> String {
    let s = String::from("hello");
    s
}

/// Exercise 5: Create a function that takes a mutable reference to a string
/// and appends " Rust!" to it
fn exercise_5(s: &mut String) {
    println!("\n--- Exercise 5 ---");
    // Your code here
}

// ==========================================================================
// 6. STRUCTS: DEFINING CUSTOM DATA TYPES
// ==========================================================================

/// Section 6: Structs
/// ------------------
/// Structs allow you to create custom data types that group related values.
#[derive(Debug)]
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}

#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    // Method (takes &self)
    fn area(&self) -> u32 {
        self.width * self.height
    }
    
    // Associated function (doesn't take self)
    fn square(size: u32) -> Rectangle {
        Rectangle {
            width: size,
            height: size,
        }
    }
}

fn structs_demo() {
    println!("\n=== STRUCTS ===");
    
    // Creating a struct instance
    let user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };
    
    println!("User: {:?}", user1);
    println!("User email: {}", user1.email);
    
    // Creating a struct from another struct
    let user2 = User {
        email: String::from("another@example.com"),
        username: String::from("anotherusername567"),
        ..user1 // Use the rest of the fields from user1
    };
    
    println!("User2: {:?}", user2);
    
    // Tuple structs
    struct Color(i32, i32, i32);
    let black = Color(0, 0, 0);
    println!("Black: ({}, {}, {})", black.0, black.1, black.2);
    
    // Method syntax
    let rect = Rectangle {
        width: 30,
        height: 50,
    };
    
    println!("Rectangle: {:?}", rect);
    println!("Area: {}", rect.area());
    
    // Associated function
    let square = Rectangle::square(10);
    println!("Square: {:?}", square);
    println!("Square area: {}", square.area());
}

/// Exercise 6: Create a struct called Book with title, author, and page_count
/// Then create a method that returns a summary string
fn exercise_6() {
    println!("\n--- Exercise 6 ---");
    // Your code here
}

// ==========================================================================
// 7. ENUMS AND PATTERN MATCHING
// ==========================================================================

/// Section 7: Enums and Pattern Matching
/// -------------------------------------
/// Enums allow you to define a type by enumerating its possible variants.
/// Pattern matching with match provides control flow based on enum variants.
#[derive(Debug)]
enum IpAddr {
    V4(String),
    V6(String),
}

enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}

impl Message {
    fn call(&self) {
        // Method body would be defined here
    }
}

fn enums_and_pattern_matching() {
    println!("\n=== ENUMS AND PATTERN MATCHING ===");
    
    // Enum variants
    let home = IpAddr::V4(String::from("127.0.0.1"));
    let loopback = IpAddr::V6(String::from("::1"));
    
    println!("Home: {:?}", home);
    println!("Loopback: {:?}", loopback);
    
    // The Option enum (Rust's solution to null values)
    let some_number = Some(5);
    let some_string = Some("a string");
    let absent_number: Option<i32> = None;
    
    println!("some_number: {:?}", some_number);
    println!("some_string: {:?}", some_string);
    println!("absent_number: {:?}", absent_number);
    
    // Pattern matching with match
    let value = Some(3);
    match value {
        Some(3) => println!("three"),
        Some(7) => println!("seven"),
        Some(x) => println!("Other: {}", x),
        None => println!("Nothing"),
    }
    
    // if let syntax (concise control flow)
    let some_value = Some(7);
    if let Some(7) = some_value {
        println!("That's my lucky number!");
    }
}

/// Exercise 7: Create an enum called Shape with variants Circle, Square, and Rectangle
/// Then create a function that calculates area based on the shape
fn exercise_7() {
    println!("\n--- Exercise 7 ---");
    // Your code here
}

// ==========================================================================
// 8. ERROR HANDLING: THE RUST WAY
// ==========================================================================

/// Section 8: Error Handling
/// -------------------------
/// Rust groups errors into two major categories: recoverable (Result<T, E>)
/// and unrecoverable (panic!). Rust doesn't have exceptions.
fn error_handling() {
    println!("\n=== ERROR HANDLING ===");
    
    // Recoverable errors with Result
    let result = read_file("hello.txt");
    match result {
        Ok(contents) => println!("File contents: {}", contents),
        Err(error) => println!("Error reading file: {}", error),
    }
    
    // Propagating errors with ?
    let result = read_file_and_propagate("hello.txt");
    match result {
        Ok(contents) => println!("File contents: {}", contents),
        Err(error) => println!("Error reading file: {}", error),
    }
    
    // Unrecoverable errors with panic!
    // panic!("crash and burn"); // Uncomment to see a panic
    
    // Using unwrap and expect (for prototyping)
    let contents = read_file("hello.txt").unwrap(); // Panics on Err
    println!("Contents: {}", contents);
    
    let contents = read_file("hello.txt").expect("Failed to read file"); // Panics with custom message
    println!("Contents: {}", contents);
}

fn read_file(filename: &str) -> Result<String, String> {
    // Simulate file reading
    if filename == "hello.txt" {
        Ok(String::from("Hello, world!"))
    } else {
        Err(String::from("File not found"))
    }
}

fn read_file_and_propagate(filename: &str) -> Result<String, String> {
    let contents = read_file(filename)?;
    Ok(contents)
}

/// Exercise 8: Create a function that divides two numbers and returns a Result
/// Return an error if dividing by zero
fn exercise_8(a: f64, b: f64) -> Result<f64, String> {
    println!("\n--- Exercise 8 ---");
    // Your code here
    Ok(0.0) // placeholder
}

// ==========================================================================
// 9. GENERICS, TRAITS, AND LIFETIMES
// ==========================================================================

/// Section 9: Generics, Traits, and Lifetimes
/// ------------------------------------------
/// Generics allow you to write code that works with multiple types.
/// Traits define shared behavior across types.
/// Lifetimes ensure references are valid as long as we need them to be.
fn generics_traits_lifetimes() {
    println!("\n=== GENERICS, TRAITS, AND LIFETIMES ===");
    
    // Generic function
    let number_list = vec![34, 50, 25, 100, 65];
    let result = largest(&number_list);
    println!("The largest number is {}", result);
    
    let char_list = vec!['y', 'm', 'a', 'q'];
    let result = largest(&char_list);
    println!("The largest char is {}", result);
    
    // Traits
    let tweet = Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people"),
        reply: false,
        retweet: false,
    };
    
    println!("1 new tweet: {}", tweet.summarize());
    
    // Lifetimes
    let string1 = String::from("abcd");
    let string2 = "xyz";
    
    let result = longest(string1.as_str(), string2);
    println!("The longest string is {}", result);
}

// Generic function with trait bounds
fn largest<T: PartialOrd + Copy>(list: &[T]) -> T {
    let mut largest = list[0];
    
    for &item in list.iter() {
        if item > largest {
            largest = item;
        }
    }
    
    largest
}

// Trait definition
pub trait Summary {
    fn summarize(&self) -> String;
}

// Trait implementation
struct Tweet {
    username: String,
    content: String,
    reply: bool,
    retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}

// Function with lifetime annotations
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

/// Exercise 9: Create a generic function that returns the smallest element in a list
fn exercise_9<T: PartialOrd + Copy>(list: &[T]) -> T {
    println!("\n--- Exercise 9 ---");
    // Your code here
    list[0] // placeholder
}

// ==========================================================================
// 10. COLLECTIONS: VECTORS, STRINGS, AND HASH MAPS
// ==========================================================================

/// Section 10: Collections
/// -----------------------
/// The standard library includes several useful collections: Vec, String, HashMap.
fn collections_demo() {
    println!("\n=== COLLECTIONS ===");
    
    // Vectors
    let mut v: Vec<i32> = Vec::new();
    v.push(1);
    v.push(2);
    v.push(3);
    
    println!("Vector: {:?}", v);
    println!("First element: {}", v[0]);
    
    // Iterating over a vector
    for i in &v {
        println!("{}", i);
    }
    
    // Strings
    let mut s = String::from("foo");
    s.push_str("bar");
    println!("String: {}", s);
    
    // Hash maps
    use std::collections::HashMap;
    
    let mut scores = HashMap::new();
    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Yellow"), 50);
    
    println!("Scores: {:?}", scores);
    println!("Blue team score: {}", scores.get("Blue").unwrap());
}

/// Exercise 10: Create a function that counts word frequencies in a string
fn exercise_10(text: &str) -> HashMap<String, u32> {
    println!("\n--- Exercise 10 ---");
    // Your code here
    HashMap::new() // placeholder
}

// ==========================================================================
// MAIN FUNCTION: RUNNING THE TUTORIAL
// ==========================================================================

fn main() {
    println!("🎓 RUST TUTOR: COMPREHENSIVE LEARNING JOURNEY");
    println!("==============================================");
    
    // Run all tutorial sections
    variables_and_mutability();
    exercise_1();
    
    data_types();
    exercise_2();
    
    functions_and_control_flow();
    let _ = exercise_3(5);
    
    ownership_demo();
    exercise_4();
    
    references_and_borrowing();
    let mut s = String::from("Hello");
    exercise_5(&mut s);
    
    structs_demo();
    exercise_6();
    
    enums_and_pattern_matching();
    exercise_7();
    
    error_handling();
    let _ = exercise_8(10.0, 2.0);
    
    generics_traits_lifetimes();
    let numbers = vec![34, 50, 25, 100, 65];
    let _ = exercise_9(&numbers);
    
    collections_demo();
    let _ = exercise_10("hello world hello");
    
    println!("\n🎉 TUTORIAL COMPLETED! You've learned the fundamentals of Rust!");
    println!("\nNext steps:");
    println!("1. Practice with Rustlings (https://github.com/rust-lang/rustlings)");
    println!("2. Build a project with The Book (https://doc.rust-lang.org/book/)");
    println!("3. Explore Rust by Example (https://doc.rust-lang.org/rust-by-example/)");
    println!("4. Join the Rust community at https://www.rust-lang.org/community");
}