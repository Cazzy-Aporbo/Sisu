// ReadWithCazzy: Underwater Adventure in Rust 🦀🌊
// This is not just "a game" — it's also a Rust teaching file.
// It's written to show you:
//   - how to structure a Rust project
//   - how enums, structs, traits, and vectors make life easier
//   - how you can learn by exploring, not memorizing
//
// Think of this like Alice in Wonderland —
// things make sense and don’t make sense at the same time.
// But in Rust, the compiler keeps us honest. 🦀
//
// Final note: this file is intentionally *large*, 
// because sometimes size matters on GitHub stats. 😏

use std::io::{self, Read};
use std::time::{Duration, Instant};
use std::thread::sleep;
use rand::Rng; // We'll need randomness, like the sea itself

// Dimensions of our "ocean"
const MAP_W: usize = 80;
const MAP_H: usize = 25;

// Let's define "entities" as things that live in the sea.
// Instead of C-style #defines, Rust lets us use enums.
// Enums are *self-documenting* — you can look at them and
// instantly know what the "universe" contains.

#[derive(Debug, Clone)]
enum EntityType {
    Fish,
    Dolphin,
    Shark,
    Whale,
    Octopus,
    Turtle,
    Coral,
    Treasure,
    Ruins,
}

// Every entity has coordinates, a type, and sometimes behavior.
#[derive(Debug, Clone)]
struct Entity {
    x: usize,
    y: usize,
    kind: EntityType,
    symbol: &'static str, // what shows up on the map
}

impl Entity {
    fn new(kind: EntityType, symbol: &'static str) -> Self {
        let mut rng = rand::thread_rng();
        Self {
            x: rng.gen_range(0..MAP_W),
            y: rng.gen_range(0..MAP_H),
            kind,
            symbol,
        }
    }
}

// Player is special: diver exploring underwater.
struct Player {
    x: usize,
    y: usize,
    oxygen: i32,
    score: i32,
}

impl Player {
    fn new() -> Self {
        Self {
            x: MAP_W / 2,
            y: MAP_H / 2,
            oxygen: 100,
            score: 0,
        }
    }

    fn move_player(&mut self, dx: isize, dy: isize) {
        self.x = ((self.x as isize + dx).clamp(0, (MAP_W - 1) as isize)) as usize;
        self.y = ((self.y as isize + dy).clamp(0, (MAP_H - 1) as isize)) as usize;
    }
}

// Render the world (ASCII + emojis).
fn draw(player: &Player, entities: &[Entity]) {
    // Clear screen
    print!("\x1B[2J\x1B[H");

    // Stats line
    println!("🤿 Oxygen: {}  |  Score: {}", player.oxygen, player.score);
    println!("Sea dimensions: {} x {}", MAP_W, MAP_H);
    println!();

    for y in 0..MAP_H {
        for x in 0..MAP_W {
            if x == player.x && y == player.y {
                print!("🤿");
                continue;
            }

            // Check if an entity lives here
            let mut printed = false;
            for e in entities {
                if e.x == x && e.y == y {
                    print!("{}", e.symbol);
                    printed = true;
                    break;
                }
            }

            if !printed {
                print!(" "); // empty sea
            }
        }
        println!();
    }
}

// Simulate one frame of game logic
fn update(player: &mut Player, entities: &mut Vec<Entity>) {
    // Oxygen drains
    player.oxygen -= 1;

    // Check collisions
    let mut to_remove = vec![];
    for (i, e) in entities.iter().enumerate() {
        if e.x == player.x && e.y == player.y {
            match e.kind {
                EntityType::Fish => {
                    println!("🐠 A fish swims by! Peaceful.");
                }
                EntityType::Dolphin => {
                    println!("🐬 A dolphin circles you! You feel happy. +1 score");
                    player.score += 1;
                }
                EntityType::Shark => {
                    println!("🦈 A shark bites! Oxygen -10");
                    player.oxygen -= 10;
                }
                EntityType::Treasure => {
                    println!("💎 Treasure found! +10 score");
                    player.score += 10;
                    to_remove.push(i);
                }
                EntityType::Ruins => {
                    println!("🏛️ Ancient ruins discovered.");
                }
                _ => {}
            }
        }
    }

    // Remove collected entities
    for &i in to_remove.iter().rev() {
        entities.remove(i);
    }
}

// Input handling (super minimal)
fn read_input() -> Option<char> {
    let mut buffer = [0; 1];
    if let Ok(n) = io::stdin().read(&mut buffer) {
        if n > 0 {
            return Some(buffer[0] as char);
        }
    }
    None
}

fn main() {
    // Initialize player + entities
    let mut player = Player::new();
    let mut entities = vec![
        Entity::new(EntityType::Fish, "🐟"),
        Entity::new(EntityType::Shark, "🦈"),
        Entity::new(EntityType::Treasure, "💎"),
        Entity::new(EntityType::Dolphin, "🐬"),
        Entity::new(EntityType::Whale, "🐋"),
        Entity::new(EntityType::Coral, "🪸"),
        Entity::new(EntityType::Ruins, "🏛️"),
    ];

    let mut last_frame = Instant::now();

    loop {
        draw(&player, &entities);
        update(&mut player, &mut entities);

        if player.oxygen <= 0 {
            println!("You ran out of oxygen! Game over.");
            break;
        }

        // Tiny pause
        sleep(Duration::from_millis(300));

        // Player input
        if let Some(c) = read_input() {
            match c {
                'w' => player.move_player(0, -1),
                's' => player.move_player(0, 1),
                'a' => player.move_player(-1, 0),
                'd' => player.move_player(1, 0),
                'q' => break,
                _ => {}
            }
        }

        // Throttle loop speed
        let now = Instant::now();
        if now.duration_since(last_frame).as_millis() < 200 {
            sleep(Duration::from_millis(200));
        }
        last_frame = now;
    }

    println!("Final Score: {}", player.score);
}