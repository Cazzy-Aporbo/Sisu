// SISU-1 Ultimate Chaos.rs
// Author: Cazzy
// Purpose: Ultra-chaotic, interactive interstellar dashboard

use std::{thread::sleep, time::Duration};
use rand::prelude::*;
use std::io::{self, Write};

// Clear screen
fn clear_screen() {
    print!("\x1B[2J\x1B[H");
}

// Draw starfield with random symbols
fn draw_stars(width: usize, height: usize) {
    let mut rng = thread_rng();
    for _y in 0..height {
        for _x in 0..width {
            let c = match rng.gen_range(0..20) {
                0 => '*',
                1 => '.',
                2 => '+',
                _ => ' ',
            };
            print!("{}", c);
        }
        println!();
    }
}

// Draw ship with thrusters, shield, hull, fuel
fn draw_ship(x: usize, y: usize, thruster: bool, shield: i32, hull: i32, fuel: i32) {
    for _ in 0..y { println!(); }
    for _ in 0..x { print!(" "); }
    println!("   ^   ");
    for _ in 0..x { print!(" "); }
    println!("  /|\\  ");
    for _ in 0..x { print!(" "); }
    println!("  |||  ");
    for _ in 0..x { print!(" "); }
    if thruster {
        println!(" /===\\ 🔥🔥🔥");
    } else {
        println!(" /===\\");
    }
    for _ in 0..x { print!(" "); }
    println!("Shield: [{}{}]", "█".repeat(shield as usize), " ".repeat(10 - shield as usize));
    for _ in 0..x { print!(" "); }
    println!("Hull:   [{}{}]", "█".repeat(hull as usize), " ".repeat(10 - hull as usize));
    for _ in 0..x { print!(" "); }
    println!("Fuel:   [{}{}]", "█".repeat(fuel as usize), " ".repeat(10 - fuel as usize));
}

// Draw planets, loot, and random anomalies
fn draw_environment(width: usize, height: usize) {
    let mut rng = thread_rng();
    let symbols = ["🪐","🌕","🛸","💎","🛠️","🌠","☄️"];
    for _ in 0..5 {
        let px = rng.gen_range(0..width);
        let py = rng.gen_range(0..height);
        for _ in 0..py { println!(); }
        for _ in 0..px { print!(" "); }
        println!("{}", symbols[rng.gen_range(0..symbols.len())]);
    }
}

// Radar sweep
fn draw_radar() {
    let mut rng = thread_rng();
    println!("Radar Sweep:");
    for _ in 0..5 {
        for _ in 0..10 {
            let c = match rng.gen_range(0..10) {
                0 => '●', 1 => '◍', 2 => '◎',
                _ => ' ',
            };
            print!("{}", c);
        }
        println!();
    }
}

// Confetti explosion
fn confetti_explosion() {
    let mut rng = thread_rng();
    println!("🎉 CONFETTI EXPLOSION 🎉");
    for _ in 0..5 {
        for _ in 0..40 {
            let c = match rng.gen_range(0..6) {
                0 => '🎈',
                1 => '✨',
                2 => '🎆',
                3 => '🎇',
                4 => '🪅',
                _ => ' ',
            };
            print!("{}", c);
        }
        println!();
        sleep(Duration::from_millis(200));
    }
}

// Asteroid alert
fn asteroid_alert(shield: &mut i32, hull: &mut i32) {
    clear_screen();
    println!("⚠️  ALERT! ASTEROID FIELD! ⚠️");
    for _ in 0..3 {
        println!("💥💥💥 CRASH IMMINENT 💥💥💥");
        sleep(Duration::from_millis(800));
    }
    *shield -= rand::thread_rng().gen_range(1..3);
    *hull -= rand::thread_rng().gen_range(0..2);
    if *shield < 0 { *shield = 0; }
    if *hull < 0 { *hull = 0; }
    println!("You narrowly escaped!");
    sleep(Duration::from_millis(1000));
}

// Warp drive
fn warp_drive() {
    clear_screen();
    println!("⚡ Engaging Warp Drive ⚡");
    for _ in 0..5 {
        println!(">>> ZOOM >>>");
        sleep(Duration::from_millis(400));
    }
    println!("🌍 Destination Reached!");
    sleep(Duration::from_millis(800));
}

// Wormhole distortion
fn wormhole_distortion() {
    clear_screen();
    println!("🌀 Entering Random Wormhole! 🌀");
    for _ in 0..5 {
        println!("~~~ DISTORTION ~~~");
        sleep(Duration::from_millis(300));
    }
}

// Alien encounter
fn alien_encounter() {
    let aliens = ["👽 Friendly contact!", "👾 Hostile drones!", "🛸 Mysterious signals!"];
    println!("{}", aliens[rand::thread_rng().gen_range(0..aliens.len())]);
}

// AI assistant messages
fn ai_messages(step: usize) {
    let messages = [
        "All systems nominal.",
        "Warp core stable.",
        "Scanners detect anomalies.",
        "Navigational charts updated.",
        "Life support functioning optimally.",
        "Enemy signatures detected!",
        "Fuel consumption normal.",
        "Radiation spikes detected.",
    ];
    println!("AI> {}", messages[step % messages.len()]);
}

// Main loop
fn main() {
    let mut rng = thread_rng();
    clear_screen();
    println!("========================================");
    println!("        🚀 SISU-1 Ultimate Chaos 🚀");
    println!("========================================\n");
    println!("You are the captain. Brace for chaos...\n");
    sleep(Duration::from_millis(1000));

    let mut shield = 10;
    let mut hull = 10;
    let mut fuel = 10;
    let mut thruster = false;

    for step in 1..=25 {
        clear_screen();
        println!("Step {} | Shields:{} Hull:{} Fuel:{}\n", step, shield, hull, fuel);

        draw_stars(40, 8);
        draw_environment(40, 8);
        thruster = rng.gen_bool(0.7);
        draw_ship(10, 2, thruster, shield, hull, fuel);
        draw_radar();
        ai_messages(step);

        // Random events
        if rng.gen_bool(0.2) {
            asteroid_alert(&mut shield, &mut hull);
        }
        if rng.gen_bool(0.15) {
            warp_drive();
            fuel -= 1;
            if fuel < 0 { fuel = 0; }
        }
        if rng.gen_bool(0.1) {
            wormhole_distortion();
            fuel -= 1;
            shield -= 1;
            if fuel < 0 { fuel = 0; }
            if shield < 0 { shield = 0; }
        }
        if rng.gen_bool(0.15) {
            alien_encounter();
        }
        if rng.gen_bool(0.05) {
            confetti_explosion();
        }

        println!("\nPress Enter to continue...");
        let _ = io::stdin().read_line(&mut String::new());
    }

    println!("\nMission Complete! 🚀 Captain, the stars salute you!");
}