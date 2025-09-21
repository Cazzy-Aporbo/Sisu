use rand::prelude::*;
use std::io::{self, Read};
use std::{thread, time::Duration};
use std::sync::mpsc::{self, TryRecvError};

// Terminal clear
fn clear_screen() { print!("\x1B[2J\x1B[H"); }

// Non-blocking input setup
fn setup_input() -> mpsc::Receiver<char> {
    let (tx, rx) = mpsc::channel();
    thread::spawn(move || {
        let stdin = io::stdin();
        for byte in stdin.bytes() {
            if let Ok(b) = byte { tx.send(b as char).unwrap(); }
        }
    });
    rx
}

// Generate starfield and hazards
fn generate_space(width: usize, height: usize) -> Vec<Vec<char>> {
    let mut rng = rand::thread_rng();
    let mut map = vec![vec![' '; width]; height];
    for y in 0..height {
        for x in 0..width {
            let r: u8 = rng.gen_range(0..30);
            map[y][x] = match r {
                0 => '*',
                1 => '·',
                2 => '⚡',
                3 => '☄',
                4 => '🪐',
                _ => ' ',
            };
        }
    }
    map
}

// Draw cockpit HUD
fn draw_hud(energy: usize, shields: usize, hull: usize, warp: usize, speed: usize, step: usize) {
    println!("================ SISU-1 COMMAND DASHBOARD ================");
    println!("Step: {:03} | Energy: {:02} 🔋 | Shields: {:02} 🛡️ | Hull: {:02} ❤️ | Warp: {:02} ⚡ | Speed: {:02} m/s", 
             step, energy, shields, hull, warp, speed);
    println!("Controls: W/A/S/D move | E boost warp | Q quit | Cosmic events will appear in-map");
    println!("=========================================================");
}

// Draw mini-map with ship
fn draw_map(map: &Vec<Vec<char>>, ship_x: usize, ship_y: usize, boosting: bool) {
    for (y, row) in map.iter().enumerate() {
        for (x, &c) in row.iter().enumerate() {
            if x == ship_x && y == ship_y {
                if boosting { print!("🚀"); } else { print!("🛸"); }
            } else {
                print!("{}", c);
            }
        }
        println!();
    }
}

// Random cosmic events
fn cosmic_event(ship_x: usize, ship_y: usize, width: usize, height: usize) -> Option<(usize, usize, &'static str)> {
    let mut rng = rand::thread_rng();
    match rng.gen_range(0..50) {
        0 => Some((rng.gen_range(0..width), rng.gen_range(0..height), "💥 Asteroid")),
        1 => Some((rng.gen_range(0..width), rng.gen_range(0..height), "🌀 Wormhole")),
        2 => Some((rng.gen_range(0..width), rng.gen_range(0..height), "👾 Alien Ship")),
        3 => Some((rng.gen_range(0..width), rng.gen_range(0..height), "🌌 Nebula")),
        _ => None,
    }
}

fn main() {
    let width = 40;
    let height = 15;

    let mut rng = rand::thread_rng();
    let mut map = generate_space(width, height);

    let mut ship_x = width / 2;
    let mut ship_y = height / 2;
    let mut energy = 10;
    let mut shields = 5;
    let mut hull = 5;
    let mut warp_charge = 3;
    let mut speed = 1;
    let mut step = 0;

    let input_rx = setup_input();

    loop {
        step += 1;
        clear_screen();
        draw_hud(energy, shields, hull, warp_charge, speed, step);
        draw_map(&map, ship_x, ship_y, speed > 1);

        // Random event overlay
        if let Some((ex, ey, event)) = cosmic_event(ship_x, ship_y, width, height) {
            if ex == ship_x && ey == ship_y {
                println!("🚨 Event triggered! {}", event);
                match event {
                    "💥 Asteroid" => if shields > 0 { shields -= 1; } else { hull -= 1; },
                    "🌀 Wormhole" => { ship_x = rng.gen_range(0..width); ship_y = rng.gen_range(0..height); },
                    "👾 Alien Ship" => if energy > 0 { energy -= 1; },
                    "🌌 Nebula" => if energy < 10 { energy += 1; },
                    _ => {},
                }
            } else {
                map[ey][ex] = match event {
                    "💥 Asteroid" => '💥',
                    "🌀 Wormhole" => '🌀',
                    "👾 Alien Ship" => '👾',
                    "🌌 Nebula" => '🌌',
                    _ => '?',
                };
            }
        }

        // Game over
        if hull == 0 || energy == 0 {
            println!("\n💀 Your ship has been destroyed! Game Over.");
            break;
        }

        // Input handling
        match input_rx.try_recv() {
            Ok(c) => match c {
                'w' => if ship_y > 0 { ship_y -= 1; },
                's' => if ship_y < height-1 { ship_y += 1; },
                'a' => if ship_x > 0 { ship_x -= 1; },
                'd' => if ship_x < width-1 { ship_x += 1; },
                'e' => { if warp_charge > 0 { speed = 3; warp_charge -= 1; } },
                'q' => break,
                _ => {},
            },
            Err(TryRecvError::Empty) => { speed = 1; },
            Err(TryRecvError::Disconnected) => break,
        }

        // Drift stars for motion effect
        map = generate_space(width, height);

        thread::sleep(Duration::from_millis(250));
    }

    println!("\n🌟 Thanks for piloting SISU-1 Interstellar Command 🌟");
}