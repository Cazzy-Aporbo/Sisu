/*
 * RUST EDUCATIONAL SHOWCASE: Learning Through Practical Examples
 * 
 * This file demonstrates key Rust concepts with practical examples and
 * detailed explanations. Each section focuses on a different Rust feature,
 * showing both basic usage and advanced applications.
 */

// 1. OWNERSHIP AND BORROWING: THE CORE OF RUST'S MEMORY SAFETY

/// Demonstrates Rust's ownership system - the key feature that prevents
/// memory bugs at compile time without a garbage collector.
fn ownership_demo() {
    println!("\n=== OWNERSHIP AND BORROWING ===");
    
    // String type (heap-allocated) vs string literal (compile-time)
    let s1 = String::from("hello");  // s1 owns the string data
    let s2 = s1;                     // Ownership moves to s2, s1 is no longer valid
    
    // println!("{}", s1);  // This would cause a compile error!
    println!("s2: {}", s2);
    
    // Borrowing instead of moving ownership
    let s3 = String::from("world");
    let len = calculate_length(&s3);  // Pass a reference (borrow)
    println!("The length of '{}' is {}.", s3, len);  // s3 is still valid
    
    // Mutable borrowing
    let mut s4 = String::from("foo");
    change_string(&mut s4);
    println!("Modified string: {}", s4);
    
    // Multiple immutable borrows are allowed
    let r1 = &s4;
    let r2 = &s4;
    println!("r1: {}, r2: {}", r1, r2);
    
    // But only one mutable borrow at a time
    // let r3 = &mut s4;  // This would cause a compile error!
}

fn calculate_length(s: &String) -> usize {
    s.len()
    // The reference goes out of scope here, but since it doesn't have ownership,
    // the string isn't dropped
}

fn change_string(s: &mut String) {
    s.push_str(" bar");
}

// 2. PATTERN MATCHING: RUST'S POWERFUL CONTROL FLOW CONSTRUCT

/// Shows how pattern matching works in Rust, which is more powerful than
/// traditional switch statements in other languages.
fn pattern_matching_demo() {
    println!("\n=== PATTERN MATCHING ===");
    
    // Basic match expression
    let number = 13;
    match number {
        1 => println!("One!"),
        2 | 3 | 5 | 7 | 11 | 13 => println!("This is a prime number"),
        14..=19 => println!("A teen number"),
        _ => println!("Something else"),
    }
    
    // Destructuring with pattern matching
    let point = (3, 5);
    match point {
        (0, 0) => println!("Origin"),
        (0, y) => println!("On y-axis at {}", y),
        (x, 0) => println!("On x-axis at {}", x),
        (x, y) => println!("On neither axis: ({}, {})", x, y),
    }
    
    // Matching with Option enum
    let some_value = Some(5);
    let absent_value: Option<i32> = None;
    
    match some_value {
        Some(i) => println!("Got a value: {}", i),
        None => println!("Got nothing"),
    }
    
    match absent_value {
        Some(i) => println!("Got a value: {}", i),
        None => println!("Got nothing"),
    }
    
    // if let syntax for concise matching
    if let Some(i) = some_value {
        println!("if let got: {}", i);
    }
}

// 3. ERROR HANDLING: THE RUST WAY WITH RESULT AND OPTION

/// Demonstrates Rust's approach to error handling, which is explicit and
/// forces developers to handle potential errors.
fn error_handling_demo() {
    println!("\n=== ERROR HANDLING ===");
    
    // Using Option for values that might be absent
    let some_number = Some(5);
    let no_number: Option<i32> = None;
    
    // Unwrapping options (dangerous but sometimes needed)
    println!("Some number: {}", some_number.unwrap());
    // println!("No number: {}", no_number.unwrap());  // This would panic!
    
    // Safer ways to handle options
    match some_number {
        Some(n) => println!("Got a number: {}", n),
        None => println!("Got no number"),
    }
    
    // Using Result for operations that might fail
    let result: Result<i32, &str> = Ok(42);
    let error_result: Result<i32, &str> = Err("Something went wrong");
    
    match result {
        Ok(n) => println!("Success: {}", n),
        Err(e) => println!("Error: {}", e),
    }
    
    match error_result {
        Ok(n) => println!("Success: {}", n),
        Err(e) => println!("Error: {}", e),
    }
    
    // The ? operator for propagating errors
    let res = might_fail(true);
    match res {
        Ok(n) => println!("Function succeeded: {}", n),
        Err(e) => println!("Function failed: {}", e),
    }
    
    let res2 = might_fail(false);
    match res2 {
        Ok(n) => println!("Function succeeded: {}", n),
        Err(e) => println!("Function failed: {}", e),
    }
}

fn might_fail(should_succeed: bool) -> Result<i32, String> {
    if should_succeed {
        Ok(42)
    } else {
        Err(String::from("It failed!"))
    }
}

// 4. TRAITS AND GENERICS: RUST'S APPROACH TO POLYMORPHISM

/// Shows how traits and generics work in Rust to provide polymorphism
/// and code reuse while maintaining performance.
fn traits_and_generics_demo() {
    println!("\n=== TRAITS AND GENERICS ===");
    
    // Using a generic function
    let numbers = vec![34, 50, 25, 100, 65];
    let largest_num = find_largest(&numbers);
    println!("The largest number is {}", largest_num);
    
    let chars = vec!['y', 'm', 'a', 'q'];
    let largest_char = find_largest(&chars);
    println!("The largest char is {}", largest_char);
    
    // Using traits
    let tweet = Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people"),
        reply: false,
        retweet: false,
    };
    
    println!("1 new tweet: {}", tweet.summarize());
    
    let news_article = NewsArticle {
        headline: String::from("Penguins win the Stanley Cup Championship!"),
        location: String::from("Pittsburgh, PA, USA"),
        author: String::from("Iceburgh"),
        content: String::from("The Pittsburgh Penguins once again are the best hockey team in the NHL."),
    };
    
    println!("New article available! {}", news_article.summarize());
    
    // Default trait implementation
    println!("Default summary: {}", tweet.default_summary());
}

// Generic function with trait bounds
fn find_largest<T: PartialOrd>(list: &[T]) -> &T {
    let mut largest = &list[0];
    
    for item in list {
        if item > largest {
            largest = item;
        }
    }
    
    largest
}

// Defining a trait
pub trait Summary {
    fn summarize(&self) -> String;
    
    // Default implementation
    fn default_summary(&self) -> String {
        String::from("(Read more...)")
    }
}

// Implementing a trait for a type
pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, by {} ({})", self.headline, self.author, self.location)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}

// 5. CONCURRENCY: SAFE PARALLEL EXECUTION WITH THREADS AND ASYNC

/// Demonstrates Rust's approach to concurrency, which prevents data races
/// at compile time through ownership and type system.
fn concurrency_demo() {
    println!("\n=== CONCURRENCY ===");
    
    // Spawning threads
    let handle = std::thread::spawn(|| {
        for i in 1..5 {
            println!("hi number {} from the spawned thread!", i);
            std::thread::sleep(std::time::Duration::from_millis(1));
        }
    });
    
    for i in 1..3 {
        println!("hi number {} from the main thread!", i);
        std::thread::sleep(std::time::Duration::from_millis(1));
    }
    
    handle.join().unwrap();
    
    // Using channels for thread communication
    let (tx, rx) = std::sync::mpsc::channel();
    
    std::thread::spawn(move || {
        let val = String::from("hi");
        tx.send(val).unwrap();
        // println!("val is {}", val);  // This would error - ownership moved!
    });
    
    let received = rx.recv().unwrap();
    println!("Got: {}", received);
    
    // Shared state concurrency with Mutex
    let counter = std::sync::Arc::new(std::sync::Mutex::new(0));
    let mut handles = vec![];
    
    for _ in 0..10 {
        let counter = std::sync::Arc::clone(&counter);
        let handle = std::thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
        });
        handles.push(handle);
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
    
    println!("Result: {}", *counter.lock().unwrap());
}

// 6. SMART POINTERS: MANAGING MEMORY WITH EXTRA CAPABILITIES

/// Shows how smart pointers in Rust provide functionality beyond references.
fn smart_pointers_demo() {
    println!("\n=== SMART POINTERS ===");
    
    // Box - for allocating values on the heap
    let b = Box::new(5);
    println!("b = {}", b);
    
    // Using Box for recursive types
    #[derive(Debug)]
    enum List {
        Cons(i32, Box<List>),
        Nil,
    }
    
    let list = List::Cons(1, Box::new(List::Cons(2, Box::new(List::Cons(3, Box::new(List::Nil)))));
    println!("Recursive list: {:?}", list);
    
    // Reference counting with Rc
    use std::rc::Rc;
    
    let a = Rc::new(String::from("hello"));
    println!("Reference count after creating a: {}", Rc::strong_count(&a));
    
    let b = Rc::clone(&a);
    println!("Reference count after creating b: {}", Rc::strong_count(&a));
    
    {
        let c = Rc::clone(&a);
        println!("Reference count after creating c: {}", Rc::strong_count(&a));
    }
    
    println!("Reference count after c goes out of scope: {}", Rc::strong_count(&a));
}

// 7. FUNCTIONAL PROGRAMMING FEATURES: ITERATORS AND CLOSURES

/// Demonstrates Rust's support for functional programming patterns.
fn functional_programming_demo() {
    println!("\n=== FUNCTIONAL PROGRAMMING ===");
    
    // Closures (anonymous functions)
    let add_one = |x| x + 1;
    println!("5 + 1 = {}", add_one(5));
    
    // Closures can capture their environment
    let x = 4;
    let equal_to_x = |z| z == x;
    let y = 4;
    println!("{} equals {}: {}", y, x, equal_to_x(y));
    
    // Using iterators
    let v1 = vec![1, 2, 3];
    let v1_iter = v1.iter();
    
    for val in v1_iter {
        println!("Got: {}", val);
    }
    
    // Iterator adapters
    let v2: Vec<i32> = vec![1, 2, 3];
    let v3: Vec<i32> = v2.iter().map(|x| x + 1).collect();
    println!("Mapped vector: {:?}", v3);
    
    // Using filter
    let numbers = vec![1, 2, 3, 4, 5, 6];
    let even_numbers: Vec<&i32> = numbers.iter().filter(|&x| x % 2 == 0).collect();
    println!("Even numbers: {:?}", even_numbers);
}

// 8. ADVANCED FEATURES: MACROS, UNSAFE RUST, AND MORE

/// Shows some of Rust's advanced features that provide extra power when needed.
fn advanced_features_demo() {
    println!("\n=== ADVANCED FEATURES ===");
    
    // Using macros
    println!("Macros make code generation easy!");
    
    // Creating a simple macro
    macro_rules! say_hello {
        () => {
            println!("Hello!")
        };
    }
    
    say_hello!();
    
    // Unsafe Rust - for when you need to bypass the compiler's checks
    unsafe {
        let mut num = 5;
        
        let r1 = &num as *const i32;
        let r2 = &mut num as *mut i32;
        
        println!("r1 is: {}", *r1);
        println!("r2 is: {}", *r2);
    }
    
    // Using external crates (would need to be added to Cargo.toml)
    // use rand::Rng;
    // let secret_number = rand::thread_rng().gen_range(1..101);
    // println!("Random number: {}", secret_number);
}

// MAIN FUNCTION: RUNNING ALL DEMOS

fn main() {
    println!("RUST EDUCATIONAL SHOWCASE");
    println!("==========================");
    
    ownership_demo();
    pattern_matching_demo();
    error_handling_demo();
    traits_and_generics_demo();
    concurrency_demo();
    smart_pointers_demo();
    functional_programming_demo();
    advanced_features_demo();
    
    println!("\n=== ALL DEMOS COMPLETED ===");
}