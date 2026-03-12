// CazzyRustMastery.rs
// Author: Cazzy
// Purpose: Explore Rust deeply with multiple approaches per topic
// Covers breadth (fundamentals to advanced) and depth (patterns, recursion, traits, async)
// Human-explanatory style

use std::collections::HashMap;
use std::future::Future;
use std::pin::Pin;
use std::thread;
use std::time::Duration;

// 1. Variables & Constants (Multiple Approaches)
fn variables_section() {
    println!("-- Variables & Constants --");

    // Approach 1: Immutable vs mutable
    let x = 10;
    let mut y = 5;
    y += x;
    println!("Immutable x = {}, mutable y after += x = {}", x, y);

    // Approach 2: Shadowing
    let y = y * 2; 
    println!("Shadowed y = {}", y);

    // Approach 3: Constants
    const MAX_POINTS: u32 = 100_000;
    println!("Constant MAX_POINTS = {}", MAX_POINTS);
}

// 2. Functions (Multiple Styles)
fn add(a: i32, b: i32) -> i32 { a + b }

fn functions_section() {
    println!("-- Functions Section --");

    // Approach 1: Simple function
    println!("add(3,4) = {}", add(3,4));

    // Approach 2: Closure
    let multiply = |a:i32,b:i32| a*b;
    println!("multiply closure(3,4) = {}", multiply(3,4));

    // Approach 3: Higher-order function
    fn apply<F>(f:F,x:i32,y:i32)->i32 where F: Fn(i32,i32)->i32 { f(x,y) }
    println!("apply subtraction = {}", apply(|a,b| a-b,10,3));
}

// 3. Structs & Methods (Multiple Patterns)
struct Rectangle { width:u32, height:u32 }

impl Rectangle {
    fn area(&self)->u32 { self.width * self.height }
    fn can_hold(&self, other:&Rectangle)->bool { self.width>other.width && self.height>other.height }
}

fn structs_section() {
    println!("-- Structs Section --");

    // Approach 1: Single struct
    let rect1 = Rectangle{width:30,height:50};
    let rect2 = Rectangle{width:10,height:40};
    println!("rect1 area = {}", rect1.area());
    println!("rect1 can hold rect2? {}", rect1.can_hold(&rect2));

    // Approach 2: Vector of structs
    let shapes = vec![rect1, rect2];
    for s in &shapes { println!("Shape area: {}", s.area()); }

    // Approach 3: Pattern matching via enums
    enum Shape { Circle(f64), Square(f64), Rect(u32,u32) }
    let shape = Shape::Circle(5.0);
    match shape {
        Shape::Circle(r)=> println!("Circle radius {}",r),
        Shape::Square(s)=> println!("Square side {}",s),
        Shape::Rect(w,h)=> println!("Rect {}x{}",w,h),
    }
}

// 4. Collections & Iterators (Multiple Approaches)
fn collections_section() {
    println!("-- Collections Section --");

    let v = vec![1,2,3,4,5];

    // Approach 1: for-loop sum
    let mut sum =0; for n in &v { sum += n; }
    println!("Sum via loop = {}", sum);

    // Approach 2: iterator
    let sum2: i32 = v.iter().sum();
    println!("Sum via iter().sum() = {}", sum2);

    // Approach 3: recursive sum
    fn rec_sum(nums:&[i32])->i32 { if nums.is_empty(){0}else{nums[0]+rec_sum(&nums[1..])} }
    println!("Sum via recursion = {}", rec_sum(&v));
}

// 5. HashMap & Interaction (Multiple Approaches)
fn hashmap_section() {
    println!("-- HashMap Section --");

    let mut scores = HashMap::new();
    scores.insert("Alice",50);
    scores.insert("Bob",70);

    // Approach 1: basic get
    println!("Alice score = {}", scores.get("Alice").unwrap());

    // Approach 2: default value
    println!("Charlie score = {}", scores.get("Charlie").unwrap_or(&0));

    // Approach 3: iterate
    for (name,score) in &scores { println!("{}: {}",name,score); }
}

// 6. Generics & Traits (Depth)
trait Summable<T> { fn sum_items(&self)->T; }

impl Summable<i32> for Vec<i32> { fn sum_items(&self)->i32 { self.iter().sum() } }

fn generics_traits_section() {
    println!("-- Generics & Traits Section --");
    let nums = vec![10,20,30];
    println!("Sum via trait = {}", nums.sum_items());

    fn print_debug<T:std::fmt::Debug>(value:T){ println!("Value: {:?}", value); }
    print_debug(42);
    print_debug("Hello Generics");
}

// 7. Async & Concurrency Exploration
fn async_section() {
    println!("-- Async & Concurrency Section --");

    fn fake_async(name:&str,duration:u64)->Pin<Box<dyn Future<Output=String>>>{
        let name = name.to_string();
        Box::pin(async move {
            thread::sleep(Duration::from_millis(duration));
            format!("Task {} done after {}ms",name,duration)
        })
    }

    let t1 = fake_async("X",400);
    let t2 = fake_async("Y",200);

    futures::executor::block_on(async {
        let r1 = t1.await;
        let r2 = t2.await;
        println!("{}",r1);
        println!("{}",r2);
    });
}

// 8. Exploratory Mini-Project: Particles
struct Particle{ x:f64, y:f64, vx:f64, vy:f64 }

impl Particle{
    fn update(&mut self){ self.x+=self.vx; self.y+=self.vy; }
    fn display(&self){ println!("Particle ({:.2},{:.2}) moving ({:.2},{:.2})",self.x,self.y,self.vx,self.vy); }
}

fn particle_section() {
    println!("-- Particle Simulation --");
    let mut particles = vec![ Particle{x:0.0,y:0.0,vx:1.0,vy:0.5}, Particle{x:5.0,y:5.0,vx:-0.3,vy:0.8} ];

    for step in 0..5 {
        println!("Step {}",step);
        for p in &mut particles { p.update(); p.display(); }
    }
}

// Main
fn main(){
    println!("Welcome to CazzyRustMastery!");

    variables_section();
    functions_section();
    structs_section();
    collections_section();
    hashmap_section();
    generics_traits_section();
    async_section();
    particle_section();

    println!("Exploration complete! You’ve seen multiple approaches to many Rust topics.");
}