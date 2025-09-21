// src/main.rs
//
// 🌊 ReadWithCazzy: An Underwater World in Rust
// --------------------------------------------------
// This file is a **teaching artifact**. It shows:
//   1. How to structure a small Rust simulation project.
//   2. How to model entities with enums & structs.
//   3. How to combine random movement, rendering, and interaction.
//   4. How to document your thought process for others to learn.
// 
// Why Rust?
//   - Memory safety (no segfaults, no leaks).
//   - Expressiveness (pattern matching, enums).
//   - Community standards (cargo, clippy, fmt).
//
// Why underwater?
//   - Because imagination should feel *alive*.
//   - Because we’re exploring code like a diver explores coral.
//   - Because programming isn’t only logic; it’s art.
//
// Author: Cazzy 🐚
// Build: cargo run
//
// --------------------------------------------------

use rand::Rng;
use std::io::{self, Write};
use std::thread::sleep;
use std::time::Duration;

// ---------------- Constants ---------------- //
const MAP_W: i32 = 100;
const MAP_H: i32 = 30;
const VIEW_W: i32 = 40;
const VIEW_H: i32 = 15;

const NUM_FISH: usize = 15;
const NUM_JELLY: usize = 8;
const NUM_OCTOPUS: usize = 3;
const NUM_SEAWEED: usize = 20;
const NUM_BUBBLES: usize = 30;

// ---------------- Data Structures ---------------- //

#[derive(Clone, Copy)]
struct Entity {
    x: i32,
    y: i32,
    kind: Kind,
}

#[derive(Clone, Copy)]
enum Kind {
    Player,
    Fish,
    Jelly,
    Octopus,
    Seaweed,
    Bubble,
}

// Emojis: a pool for each type
fn emoji_for(kind: Kind) -> &'static str {
    match kind {
        Kind::Player => "🧑‍🚀",
        Kind::Fish => {
            let options = ["🐠", "🐟", "🐡", "🦈", "🐋"];
            options[rand::thread_rng().gen_range(0..options.len())]
        }
        Kind::Jelly => {
            let options = ["🪼", "🦀", "🦑"];
            options[rand::thread_rng().gen_range(0..options.len())]
        }
        Kind::Octopus => {
            let options = ["🐙", "🐳", "🫧"];
            options[rand::thread_rng().gen_range(0..options.len())]
        }
        Kind::Seaweed => {
            let options = ["🌿", "🌪️", "🪸", "🌱"];
            options[rand::thread_rng().gen_range(0..options.len())]
        }
        Kind::Bubble => {
            let options = ["💨", "💧", "⚪"];
            options[rand::thread_rng().gen_range(0..options.len())]
        }
    }
}

// ---------------- Game State ---------------- //

struct Game {
    player: Entity,
    entities: Vec<Entity>,
}

impl Game {
    fn new() -> Self {
        let mut rng = rand::thread_rng();

        // Player starts at center
        let player = Entity {
            x: MAP_W / 2,
            y: MAP_H / 2,
            kind: Kind::Player,
        };

        // Helper for spawning entities
        fn spawn_many(kind: Kind, count: usize, rng: &mut impl Rng) -> Vec<Entity> {
            (0..count)
                .map(|_| Entity {
                    x: rng.gen_range(0..MAP_W),
                    y: rng.gen_range(0..MAP_H),
                    kind,
                })
                .collect()
        }

        let mut entities = vec![];
        entities.extend(spawn_many(Kind::Fish, NUM_FISH, &mut rng));
        entities.extend(spawn_many(Kind::Jelly, NUM_JELLY, &mut rng));
        entities.extend(spawn_many(Kind::Octopus, NUM_OCTOPUS, &mut rng));
        entities.extend(spawn_many(Kind::Seaweed, NUM_SEAWEED, &mut rng));
        entities.extend(spawn_many(Kind::Bubble, NUM_BUBBLES, &mut rng));

        Game { player, entities }
    }

    // Draw viewport
    fn draw(&self) {
        print!("\x1B[2J\x1B[H"); // clear
        println!("Underwater World 🌊 (Rust Edition)\n");

        for y in 0..VIEW_H {
            for x in 0..VIEW_W {
                let wx = self.player.x - VIEW_W / 2 + x;
                let wy = self.player.y - VIEW_H / 2 + y;

                // Player first
                if wx == self.player.x && wy == self.player.y {
                    print!("{}", emoji_for(Kind::Player));
                    continue;
                }

                // Search for entity
                let mut symbol = "  ";
                for e in &self.entities {
                    if e.x == wx && e.y == wy {
                        symbol = emoji_for(e.kind);
                        break;
                    }
                }
                print!("{}", symbol);
            }
            println!();
        }
    }

    // Handle movement + interactions
    fn step(&mut self, input: char) {
        match input {
            'w' => self.player.y = (self.player.y - 1).max(0),
            's' => self.player.y = (self.player.y + 1).min(MAP_H - 1),
            'a' => self.player.x = (self.player.x - 1).max(0),
            'd' => self.player.x = (self.player.x + 1).min(MAP_W - 1),
            _ => {}
        }

        self.update_entities();
        self.interactions();
    }

    // Move entities
    fn update_entities(&mut self) {
        let mut rng = rand::thread_rng();
        for e in &mut self.entities {
            match e.kind {
                Kind::Fish | Kind::Jelly => {
                    e.x = (e.x + rng.gen_range(-1..=1)).clamp(0, MAP_W - 1);
                    e.y = (e.y + rng.gen_range(-1..=1)).clamp(0, MAP_H - 1);
                }
                Kind::Octopus => {
                    e.x = (e.x + rng.gen_range(-1..=1)).clamp(0, MAP_W - 1);
                }
                Kind::Bubble => {
                    e.y -= 1;
                    if e.y < 0 {
                        e.y = MAP_H - 1;
                        e.x = rng.gen_range(0..MAP_W);
                    }
                }
                _ => {}
            }
        }
    }

    // Describe what happens
    fn interactions(&self) {
        for e in &self.entities {
            if e.x == self.player.x && e.y == self.player.y {
                match e.kind {
                    Kind::Fish => println!("🐠 A school of fish swims by!"),
                    Kind::Jelly => println!("🪼 A jellyfish drifts!"),
                    Kind::Octopus => println!("🐙 The octopus waves a tentacle!"),
                    Kind::Seaweed => println!("🌿 The seaweed sways."),
                    Kind::Bubble => println!("💧 A bubble pops near you!"),
                    _ => {}
                }
            }
        }
    }
}

// ---------------- Main Loop ---------------- //

fn main() {
    let mut game = Game::new();

    loop {
        game.draw();

        print!("\nMove WASD, q to quit: ");
        io::stdout().flush().unwrap();

        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();
        let c = input.chars().next().unwrap_or('\n');

        if c == 'q' {
            println!("Goodbye, diver 👋");
            break;
        }

        game.step(c);
        sleep(Duration::from_millis(200));
    }
}