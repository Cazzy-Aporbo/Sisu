/*
 * Rust Learning Companion: A Gentle Guide Through Multiple Approaches
 * 
 * This file takes you on a journey through Rust concepts, showing different
 * ways to solve problems while explaining the thinking behind each approach.
 * Think of me as your patient coding friend, here to guide you.
 */

// Let's start with something simple: saying hello
// There are several ways to greet in Rust, each with its own charm

fn gentle_greeting() {
    println!("\n=== Gentle Greetings ===");
    
    // The straightforward approach
    println!("Hello, friend!");
    
    // A more personal approach
    let name = "learner";
    println!("Hello, {}! It's good to see you.", name);
    
    // Using a format string first, then printing
    let greeting = format!("Hi there, {}! Are you ready to learn?", name);
    println!("{}", greeting);
    
    // Sometimes we want to return a greeting instead of printing it
    let custom_greeting = create_greeting(name, "wonderful");
    println!("{}", custom_greeting);
}

// A function that creates personalized greetings
fn create_greeting(name: &str, adjective: &str) -> String {
    // We can build strings in different ways
    format!("Hey {}! You're having a {} day with Rust, aren't you?", name, adjective)
}

// Now let's explore variables and mutability
// Rust has interesting rules about changing values
fn exploring_variables() {
    println!("\n=== Exploring Variables ===");
    
    // Immutable by default - like a promise not to change
    let answer = 42;
    println!("The answer is: {}", answer);
    
    // When we need change, we ask politely with 'mut'
    let mut counter = 0;
    println!("Starting at: {}", counter);
    
    counter += 1;
    println!("Now at: {}", counter);
    
    // Shadowing lets us "reuse" variable names
    // It's like getting a new notebook but keeping the same title
    let message = "initial value";
    println!("First message: {}", message);
    
    let message = "changed value";
    println!("Second message: {}", message);
    
    // This is different from mutation:
    let mut mutable_message = String::from("hello");
    mutable_message.push_str(" world");
    println!("Mutated message: {}", mutable_message);
}

// Functions can express the same logic in different ways
// Let's look at calculating a sum
fn exploring_functions() {
    println!("\n=== Exploring Functions ===");
    
    let numbers = vec![1, 2, 3, 4, 5];
    
    // Approach 1: Imperative style - step by step
    let mut sum1 = 0;
    for num in &numbers {
        sum1 += num;
    }
    println!("Imperative sum: {}", sum1);
    
    // Approach 2: Functional style - what, not how
    let sum2: i32 = numbers.iter().sum();
    println!("Functional sum: {}", sum2);
    
    // Approach 3: Using a method
    let sum3 = numbers.iter().fold(0, |acc, x| acc + x);
    println!("Fold sum: {}", sum3);
    
    // Each approach has its place. The imperative style might be easier
    // to understand when you're learning. The functional style is often
    // more concise. Choose what feels most clear to you.
}

// Error handling in Rust might feel different at first
// Let's explore it gently
fn gentle_error_handling() {
    println!("\n=== Gentle Error Handling ===");
    
    // Rust doesn't have exceptions like other languages
    // Instead, it uses Result and Option types
    
    // Let's try a function that might fail
    match safe_division(10.0, 2.0) {
        Ok(result) => println!("Division succeeded: {}", result),
        Err(e) => println!("Division failed: {}", e),
    }
    
    match safe_division(10.0, 0.0) {
        Ok(result) => println!("Division succeeded: {}", result),
        Err(e) => println!("Division failed: {}", e),
    }
    
    // Sometimes we want to handle options
    let some_value = Some(42);
    let no_value: Option<i32> = None;
    
    // Approach 1: Pattern matching
    match some_value {
        Some(v) => println!("Got a value: {}", v),
        None => println!("Got nothing"),
    }
    
    // Approach 2: if let (when you only care about one case)
    if let Some(v) = some_value {
        println!("Value is: {}", v);
    }
    
    // Approach 3: Using unwrap (be careful with this one!)
    // Only use when you're sure there's a value
    println!("Some value: {}", some_value.unwrap());
    
    // For no_value, unwrap would panic, so we might use unwrap_or
    println!("No value: {}", no_value.unwrap_or(0));
}

// A function that might fail
fn safe_division(a: f64, b: f64) -> Result<f64, String> {
    if b == 0.0 {
        Err(String::from("Cannot divide by zero"))
    } else {
        Ok(a / b)
    }
}

// Working with collections - there are often multiple approaches
fn working_with_collections() {
    println!("\n=== Working With Collections ===");
    
    let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    
    // Let's find even numbers
    // Approach 1: Imperative
    let mut evens1 = Vec::new();
    for num in &numbers {
        if num % 2 == 0 {
            evens1.push(*num);
        }
    }
    println!("Imperative evens: {:?}", evens1);
    
    // Approach 2: Functional
    let evens2: Vec<i32> = numbers.iter()
        .filter(|&x| x % 2 == 0)
        .cloned()
        .collect();
    println!("Functional evens: {:?}", evens2);
    
    // Approach 3: Using a for loop with filter
    let mut evens3 = Vec::new();
    for &num in numbers.iter().filter(|&x| x % 2 == 0) {
        evens3.push(num);
    }
    println!("Hybrid evens: {:?}", evens3);
    
    // None is inherently better - it depends on what's most readable to you
    // and your specific situation
}

// Structs help us organize related data
// Let's create a simple person struct
#[derive(Debug)]
struct Person {
    name: String,
    age: u8,
    favorite_color: String,
}

// We can implement methods on our struct
impl Person {
    // A constructor method - convention is to call this new
    fn new(name: String, age: u8, favorite_color: String) -> Self {
        Self {
            name,
            age,
            favorite_color,
        }
    }
    
    // Another way to create a person - with default color
    fn with_default_color(name: String, age: u8) -> Self {
        Self {
            name,
            age,
            favorite_color: String::from("blue"),
        }
    }
    
    // A method that borrows self
    fn describe(&self) -> String {
        format!("{} is {} years old and loves the color {}", 
               self.name, self.age, self.favorite_color)
    }
    
    // A method that might change self
    fn have_birthday(&mut self) {
        self.age += 1;
        println!("Happy birthday, {}! You're now {}.", self.name, self.age);
    }
}

fn exploring_structs() {
    println!("\n=== Exploring Structs ===");
    
    // Different ways to create a person
    let alice = Person {
        name: String::from("Alice"),
        age: 30,
        favorite_color: String::from("green"),
    };
    
    let bob = Person::new(
        String::from("Bob"),
        25,
        String::from("red"),
    );
    
    let charlie = Person::with_default_color(
        String::from("Charlie"),
        35,
    );
    
    println!("Alice: {:?}", alice);
    println!("Bob: {:?}", bob);
    println!("Charlie: {:?}", charlie);
    
    // Using methods
    println!("{}", alice.describe());
    
    let mut mut_bob = bob;
    mut_bob.have_birthday();
}

// Enums and pattern matching are powerful features
// Let's explore them gently
fn gentle_pattern_matching() {
    println!("\n=== Gentle Pattern Matching ===");
    
    // Enums let us represent different possibilities
    enum WebEvent {
        PageLoad,
        PageUnload,
        KeyPress(char),
        Paste(String),
        Click { x: i64, y: i64 },
    }
    
    // Let's process different events
    let events = [
        WebEvent::PageLoad,
        WebEvent::KeyPress('a'),
        WebEvent::Paste(String::from("hello world")),
        WebEvent::Click { x: 10, y: 20 },
    ];
    
    for event in events.iter() {
        // Pattern matching helps us handle each case
        match event {
            WebEvent::PageLoad => println!("Page loaded"),
            WebEvent::PageUnload => println!("Page unloaded"),
            WebEvent::KeyPress(c) => println!("Pressed key: {}", c),
            WebEvent::Paste(s) => println!("Pasted text: {}", s),
            WebEvent::Click { x, y } => println!("Clicked at ({}, {})", x, y),
        }
    }
    
    // Sometimes we only care about one case
    if let WebEvent::KeyPress(c) = events[1] {
        println!("The second event was a key press: {}", c);
    }
}

// Let's talk about ownership and borrowing
// This is Rust's most unique feature, and it takes time to feel comfortable
fn gentle_ownership_guide() {
    println!("\n=== Gentle Ownership Guide ===");
    
    // Ownership is about who's responsible for cleaning up memory
    let s1 = String::from("hello"); // s1 owns the string
    
    // When we assign s1 to s2, ownership moves
    let s2 = s1;
    // println!("{}", s1); // This would error - s1 no longer owns the string
    println!("s2: {}", s2);
    
    // If we want to keep using the original, we can clone
    let s3 = String::from("world");
    let s4 = s3.clone(); // Makes a full copy
    println!("s3: {}, s4: {}", s3, s4);
    
    // Borrowing lets us temporarily share access
    let s5 = String::from("borrowing");
    let len = calculate_length(&s5); // We borrow s5
    println!("The length of '{}' is {}.", s5, len); // We can still use s5
    
    // Mutable borrowing allows changes
    let mut s6 = String::from("hello");
    change_string(&mut s6);
    println!("After change: {}", s6);
    
    // The rules:
    // 1. You can have either one mutable reference or any number of immutable references
    // 2. References must always be valid
    // These rules prevent data races at compile time!
}

fn calculate_length(s: &String) -> usize {
    s.len()
}

fn change_string(s: &mut String) {
    s.push_str(", world");
}

// Finally, let's look at a practical example that brings it all together
// We'll create a simple library system
fn practical_example() {
    println!("\n=== Practical Example: Library System ===");
    
    #[derive(Debug)]
    struct Book {
        title: String,
        author: String,
        year: u32,
        is_checked_out: bool,
    }
    
    impl Book {
        fn new(title: String, author: String, year: u32) -> Self {
            Self {
                title,
                author,
                year,
                is_checked_out: false,
            }
        }
        
        fn check_out(&mut self) -> Result<(), String> {
            if self.is_checked_out {
                Err(format!("'{}' is already checked out", self.title))
            } else {
                self.is_checked_out = true;
                Ok(())
            }
        }
        
        fn check_in(&mut self) -> Result<(), String> {
            if !self.is_checked_out {
                Err(format!("'{}' is not checked out", self.title))
            } else {
                self.is_checked_out = false;
                Ok(())
            }
        }
    }
    
    // Create some books
    let mut books = vec![
        Book::new(
            String::from("The Rust Programming Language"),
            String::from("Steve Klabnik and Carol Nichols"),
            2018,
        ),
        Book::new(
            String::from("Atomic Habits"),
            String::from("James Clear"),
            2018,
        ),
    ];
    
    // Check out a book
    match books[0].check_out() {
        Ok(()) => println!("Checked out '{}'", books[0].title),
        Err(e) => println!("Error: {}", e),
    }
    
    // Try to check out the same book again
    match books[0].check_out() {
        Ok(()) => println!("Checked out '{}'", books[0].title),
        Err(e) => println!("Error: {}", e),
    }
    
    // Check it back in
    match books[0].check_in() {
        Ok(()) => println!("Checked in '{}'", books[0].title),
        Err(e) => println!("Error: {}", e),
    }
    
    // Print all books
    for book in &books {
        let status = if book.is_checked_out {
            "checked out"
        } else {
            "available"
        };
        println!("'{}' by {} ({}) - {}", book.title, book.author, book.year, status);
    }
}

// Our main function - the starting point of our program
fn main() {
    println!("🌟 Rust Learning Companion 🌟");
    println!("=============================");
    println!("Welcome! Let's explore Rust together, one step at a time.");
    println!("Remember: it's okay to feel confused sometimes. That's how learning works!");
    
    gentle_greeting();
    exploring_variables();
    exploring_functions();
    gentle_error_handling();
    working_with_collections();
    exploring_structs();
    gentle_pattern_matching();
    gentle_ownership_guide();
    practical_example();
    
    println!("\n🎉 You made it through! Remember:");
    println!("- Rust has a learning curve, but it's worth it");
    println!("- The compiler is your friend, not your enemy");
    println!("- There's usually more than one way to solve a problem");
    println!("- Keep practicing, and be patient with yourself");
}