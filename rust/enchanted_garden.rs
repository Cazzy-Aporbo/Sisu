// CazzyTeachesRust: Enchanted Garden 🌱🦋
// ---------------------------------------
// Welcome to the Enchanted Garden.
// This file is not only a *simulation* — it’s also a *lesson*.
// We'll cover Rust concepts like:
//   - enums and pattern matching
//   - traits for polymorphism
//   - generics for flexibility
//   - ownership & borrowing in context
//
// Think: Alice in Wonderland + Rust compiler 🦀.
// Everything is peculiar but still… *works*.
//
// Run it with: cargo run
// Quit with: q

use std::io::{self, Read};
use std::thread::sleep;
use std::time::Duration;
use rand::Rng;

// Garden dimensions
const GARDEN_W: usize = 50;
const GARDEN_H: usize = 20;

// Define "things" in the garden
#[derive(Debug, Clone)]
enum EntityType {
    Flower,
    Tree,
    Fountain,
    Butterfly,
    Statue,
    Mushroom,
    Treasure,
}

// Each thing has coordinates, a symbol, and some story
#[derive(Debug, Clone)]
struct Entity {
    x: usize,
    y: usize,
    kind: EntityType,
    symbol: &'static str,
}

impl Entity {
    fn new(kind: EntityType, symbol: &'static str) -> Self {
        let mut rng = rand::thread_rng();
        Self {
            x: rng.gen_range(0..GARDEN_W),
            y: rng.gen_range(0..GARDEN_H),
            kind,
            symbol,
        }
    }
}

// Player = gardener
struct Player {
    x: usize,
    y: usize,
    energy: i32,
    joy: i32,
}

impl Player {
    fn new() -> Self {
        Self {
            x: GARDEN_W / 2,
            y: GARDEN_H / 2,
            energy: 100,
            joy: 0,
        }
    }

    fn move_player(&mut self, dx: isize, dy: isize) {
        self.x = ((self.x as isize + dx).clamp(0, (GARDEN_W - 1) as isize)) as usize;
        self.y = ((self.y as isize + dy).clamp(0, (GARDEN_H - 1) as isize)) as usize;
        self.energy -= 1;
    }
}

// Trait: all magical things can "interact"
trait Magical {
    fn interact(&self, player: &mut Player);
}

// Implement magical effects
impl Magical for Entity {
    fn interact(&self, player: &mut Player) {
        match self.kind {
            EntityType::Flower => {
                println!("🌸 The flower blooms brighter as you pass. Joy +2");
                player.joy += 2;
            }
            EntityType::Tree => {
                println!("🌳 You rest in the shade of a tree. Energy +5");
                player.energy += 5;
            }
            EntityType::Fountain => {
                println!("⛲ The fountain sparkles mysteriously. Joy +3");
                player.joy += 3;
            }
            EntityType::Butterfly => {
                println!("🦋 A butterfly lands on your shoulder. Joy +1");
                player.joy += 1;
            }
            EntityType::Statue => {
                println!("🗿 The statue whispers secrets of the garden… Energy -2, Joy +4");
                player.energy -= 2;
                player.joy += 4;
            }
            EntityType::Mushroom => {
                println!("🍄 A strange mushroom glows. Energy +10, but feels odd.");
                player.energy += 10;
            }
            EntityType::Treasure => {
                println!("💎 Hidden treasure in the soil! Joy +10");
                player.joy += 10;
            }
        }
    }
}

// Render the garden
fn draw(player: &Player, entities: &[Entity]) {
    print!("\x1B[2J\x1B[H");
    println!("🧑‍🌾 Enchanted Garden - Energy: {} | Joy: {}", player.energy, player.joy);
    println!();

    for y in 0..GARDEN_H {
        for x in 0..GARDEN_W {
            if player.x == x && player.y == y {
                print!("🧑‍🌾");
                continue;
            }

            let mut printed = false;
            for e in entities {
                if e.x == x && e.y == y {
                    print!("{}", e.symbol);
                    printed = true;
                    break;
                }
            }

            if !printed {
                print!(" "); // empty patch of soil
            }
        }
        println!();
    }
}

// Input
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
    let mut player = Player::new();
    let mut entities = vec![
        Entity::new(EntityType::Flower, "🌸"),
        Entity::new(EntityType::Tree, "🌳"),
        Entity::new(EntityType::Fountain, "⛲"),
        Entity::new(EntityType::Butterfly, "🦋"),
        Entity::new(EntityType::Statue, "🗿"),
        Entity::new(EntityType::Mushroom, "🍄"),
        Entity::new(EntityType::Treasure, "💎"),
    ];

    loop {
        draw(&player, &entities);

        // Check interactions
        for e in &entities {
            if e.x == player.x && e.y == player.y {
                e.interact(&mut player);
            }
        }

        if player.energy <= 0 {
            println!("You collapse from exhaustion. The garden closes its eyes. 🌙");
            break;
        }

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

        sleep(Duration::from_millis(300));
    }

    println!("Final Joy: {}", player.joy);
    println!("The garden remembers you. 🌱");
}