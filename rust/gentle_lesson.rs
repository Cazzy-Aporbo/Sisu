/*
 * Rust Explorations: A Gentle Journey Through Diverse Concepts
 * 
 * This file explores different Rust concepts in a kind, patient manner,
 * showing multiple approaches to problems and explaining the thinking
 * behind each solution. Think of it as a friendly conversation about Rust.
 */

// Let's begin with something comforting: a warm welcome
fn warm_welcome() {
    println!("\n🌸 Welcome to Rust Explorations 🌸");
    println!("===================================");
    println!("Hello there! I'm so glad you're here.");
    println!("Let's explore some Rust concepts together, at a gentle pace.");
    println!("Remember: every expert was once a beginner. You're doing great!\n");
}

// Sometimes we need to work with data in different ways
// Let's look at various approaches to data transformation
fn transforming_data() {
    println!("=== Transforming Data with Care ===");
    
    let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    println!("Our starting numbers: {:?}", numbers);
    
    // Approach 1: Using a for loop (explicit and clear)
    println!("\n🔹 Approach 1: For loop (step by step)");
    let mut doubled = Vec::new();
    for num in &numbers {
        doubled.push(num * 2);
    }
    println!("Doubled numbers: {:?}", doubled);
    
    // Approach 2: Using map (functional and concise)
    println!("\n🔹 Approach 2: Map (functional style)");
    let doubled: Vec<i32> = numbers.iter().map(|x| x * 2).collect();
    println!("Doubled numbers: {:?}", doubled);
    
    // Approach 3: Using a while let (less common but interesting)
    println!("\n🔹 Approach 3: While let (iterative but functional)");
    let mut iter = numbers.iter();
    let mut doubled = Vec::new();
    while let Some(num) = iter.next() {
        doubled.push(num * 2);
    }
    println!("Doubled numbers: {:?}", doubled);
    
    // All approaches are valid! Choose what feels most readable to you.
    // The goal is clarity, not cleverness.
}

// Error handling can feel intimidating, but it's just about being careful
fn gentle_error_handling() {
    println!("\n=== Gentle Error Handling ===");
    println!("Errors are just messages, not failures. Let's learn to listen to them.");
    
    // Let's try different ways to handle a potential division error
    let numerator = 10;
    let denominators = vec![2, 5, 0, 8]; // One of these will cause trouble
    
    for denominator in denominators {
        println!("\nTrying {}/{}:", numerator, denominator);
        
        // Approach 1: Match expression (explicit and thorough)
        match safe_divide(numerator, denominator) {
            Ok(result) => println!("   Match: The result is {}", result),
            Err(e) => println!("   Match: {}", e),
        }
        
        // Approach 2: if let (when we only care about success)
        if let Ok(result) = safe_divide(numerator, denominator) {
            println!("   If-let: The result is {}", result);
        } else {
            println!("   If-let: That didn't work out");
        }
        
        // Approach 3: Using unwrap_or (providing a default value)
        let result = safe_divide(numerator, denominator).unwrap_or(0);
        println!("   Unwrap-or: We got {}", result);
    }
    
    println!("\nEach approach has its place. Sometimes we want detailed error information,");
    println!("other times we just want to keep moving with a default value.");
}

fn safe_divide(a: i32, b: i32) -> Result<i32, String> {
    if b == 0 {
        Err("Oh dear, division by zero isn't possible.".to_string())
    } else {
        Ok(a / b)
    }
}

// Working with text can be done in many ways
fn working_with_text() {
    println!("\n=== Working With Text ===");
    println!("Text is how we communicate. Let's explore ways to work with it.");
    
    let greeting = "hello world";
    
    // Approach 1: Using string slices (efficient and simple)
    println!("\n🔹 Approach 1: String slices");
    let first_word = &greeting[0..5];
    let second_word = &greeting[6..11];
    println!("First word: {}, Second word: {}", first_word, second_word);
    
    // Approach 2: Using split (flexible and powerful)
    println!("\n🔹 Approach 2: Split method");
    let words: Vec<&str> = greeting.split(' ').collect();
    println!("Words: {:?}", words);
    
    // Approach 3: Using split_whitespace (handles multiple spaces)
    println!("\n🔹 Approach 3: Split whitespace");
    let messy_greeting = "hello   world";
    let words: Vec<&str> = messy_greeting.split_whitespace().collect();
    println!("Even with extra spaces: {:?}", words);
    
    // Approach 4: Using a custom function for more control
    println!("\n🔹 Approach 4: Custom parsing");
    let words = parse_words(greeting);
    println!("Custom parsing: {:?}", words);
}

fn parse_words(text: &str) -> Vec<String> {
    let mut words = Vec::new();
    let mut current_word = String::new();
    
    for c in text.chars() {
        if c.is_whitespace() {
            if !current_word.is_empty() {
                words.push(current_word);
                current_word = String::new();
            }
        } else {
            current_word.push(c);
        }
    }
    
    if !current_word.is_empty() {
        words.push(current_word);
    }
    
    words
}

// Sometimes we need to make decisions based on complex conditions
// Let's explore different ways to express logic
fn making_decisions() {
    println!("\n=== Making Decisions ===");
    println!("Life is full of choices. Programming is too. Let's look at ways to decide.");
    
    let age = 25;
    let has_permission = true;
    let is_weekend = false;
    
    // We want to decide if someone can enter a venue
    
    // Approach 1: Nested if statements (explicit but can get complex)
    println!("\n🔹 Approach 1: Nested if statements");
    if age >= 18 {
        if has_permission {
            if is_weekend {
                println!("   Welcome! You can enter the venue.");
            } else {
                println!("   Sorry, the venue is only open on weekends.");
            }
        } else {
            println!("   You need permission to enter.");
        }
    } else {
        println!("   You're too young to enter.");
    }
    
    // Approach 2: Using match with tuples (clean and expressive)
    println!("\n🔹 Approach 2: Match with tuples");
    match (age >= 18, has_permission, is_weekend) {
        (true, true, true) => println!("   Welcome! You can enter the venue."),
        (true, true, false) => println!("   Sorry, the venue is only open on weekends."),
        (true, false, _) => println!("   You need permission to enter."),
        (false, _, _) => println!("   You're too young to enter."),
    }
    
    // Approach 3: Using a single boolean expression (concise)
    println!("\n🔹 Approach 3: Single boolean expression");
    let can_enter = age >= 18 && has_permission && is_weekend;
    if can_enter {
        println!("   Welcome! You can enter the venue.");
    } else {
        println!("   Sorry, you cannot enter the venue right now.");
    }
    
    println!("\nEach approach has its strengths. The nested ifs are very explicit,");
    println!("the match is clean and handles all cases, and the boolean expression");
    println!("is concise. Choose what makes your code most readable.");
}

// Let's explore different ways to structure data
fn structuring_data() {
    println!("\n=== Structuring Data ===");
    println!("How we organize information affects how we think about it.");
    
    // Representing a person in different ways
    
    // Approach 1: Using a struct (organized and clear)
    println!("\n🔹 Approach 1: Struct");
    #[derive(Debug)]
    struct Person {
        name: String,
        age: u8,
        hobbies: Vec<String>,
    }
    
    let alice = Person {
        name: "Alice".to_string(),
        age: 30,
        hobbies: vec!["reading".to_string(), "hiking".to_string()],
    };
    
    println!("   Alice: {:?}", alice);
    
    // Approach 2: Using a tuple struct (less verbose, but less clear)
    println!("\n🔹 Approach 2: Tuple struct");
    struct PersonTuple(String, u8, Vec<String>);
    
    let bob = PersonTuple("Bob".to_string(), 25, vec!["gaming".to_string()]);
    println!("   Bob: ({}, {}, {:?})", bob.0, bob.1, bob.2);
    
    // Approach 3: Using a type alias (simple but not enforced)
    println!("\n🔹 Approach 3: Type alias");
    type PersonAlias = (String, u8, Vec<String>);
    
    let charlie: PersonAlias = ("Charlie".to_string(), 35, vec!["cooking".to_string()]);
    println!("   Charlie: {:?}", charlie);
    
    println!("\nEach approach has trade-offs. Structs are clear and enforced,");
    println!("tuple structs are more concise, and type aliases are flexible but");
    println!("don't provide the same level of type safety.");
}

// Let's look at different ways to work with collections
fn working_with_collections() {
    println!("\n=== Working With Collections ===");
    println!("Collections help us work with groups of items. Let's explore approaches.");
    
    let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    
    // Find all even numbers and square them
    
    // Approach 1: Imperative style (step by step)
    println!("\n🔹 Approach 1: Imperative style");
    let mut result = Vec::new();
    for num in &numbers {
        if num % 2 == 0 {
            result.push(num * num);
        }
    }
    println!("   Result: {:?}", result);
    
    // Approach 2: Functional style (using iterators)
    println!("\n🔹 Approach 2: Functional style");
    let result: Vec<i32> = numbers.iter()
        .filter(|&x| x % 2 == 0)
        .map(|x| x * x)
        .collect();
    println!("   Result: {:?}", result);
    
    // Approach 3: Using a for loop with pattern matching
    println!("\n🔹 Approach 3: For loop with pattern matching");
    let mut result = Vec::new();
    for num in &numbers {
        match num % 2 {
            0 => result.push(num * num),
            _ => (),
        }
    }
    println!("   Result: {:?}", result);
    
    println!("\nEach approach gets us to the same result. The imperative style is");
    println!("very explicit, the functional style is concise, and the pattern");
    println!("matching approach shows a different way to express the condition.");
}

// Let's explore different ways to handle optional values
fn handling_absence() {
    println!("\n=== Handling Absence ===");
    println!("Sometimes values are missing. Let's explore graceful ways to handle this.");
    
    let possible_values = vec![Some(42), None, Some(100), None];
    
    for value in possible_values {
        println!("\nProcessing: {:?}", value);
        
        // Approach 1: Match expression (explicit)
        match value {
            Some(v) => println!("   Match: We have a value: {}", v),
            None => println!("   Match: No value here"),
        }
        
        // Approach 2: if let (concise for single case)
        if let Some(v) = value {
            println!("   If-let: The value is {}", v);
        } else {
            println!("   If-let: Nothing to see here");
        }
        
        // Approach 3: Using unwrap_or (provide default)
        let v = value.unwrap_or(0);
        println!("   Unwrap-or: We'll use {}", v);
        
        // Approach 4: Using map (transform if present)
        let squared = value.map(|x| x * x);
        println!("   Map: Squared value is {:?}", squared);
    }
}

// Let's end with a comforting summary
fn gentle_conclusion() {
    println!("\n=== Gentle Conclusion ===");
    println!("We've explored many concepts today, and I'm proud of you for sticking with it.");
    println!();
    println!("Remember these gentle reminders:");
    println!("🌱 There's usually more than one right way to solve a problem");
    println!("🌱 Your code doesn't need to be perfect - it needs to be understandable");
    println!("🌱 The Rust compiler is your friend, not your critic");
    println!("🌱 Learning happens in small steps, not giant leaps");
    println!("🌱 You're doing better than you think you are");
    println!();
    println!("Thank you for exploring Rust with me today. Keep going, and be kind to yourself.");
}

// Our main function brings everything together
fn main() {
    warm_welcome();
    transforming_data();
    gentle_error_handling();
    working_with_text();
    making_decisions();
    structuring_data();
    working_with_collections();
    handling_absence();
    gentle_conclusion();
}