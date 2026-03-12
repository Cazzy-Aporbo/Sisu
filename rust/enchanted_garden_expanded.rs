// Enchanted Garden 🌱✨🦋
// Expanded variation: day/night cycle, more entities,
// dynamic behaviors, planting & harvesting.
//
// Run: cargo run

use std::io::{self, Read};
use std::thread::sleep;
use std::time::Duration;
use rand::Rng;

const W: usize = 60;
const H: usize = 20;

#[derive(Debug, Clone)]
enum EntityType {
    Flower,
    Tree,
    Fountain,
    Butterfly,
    Statue,
    Mushroom,
    Treasure,
    Firefly,
    River,
    FruitTree,
    Beehive,
    Spirit,
}

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
            x: rng.gen_range(0..W),
            y: rng.gen_range(0..H),
            kind,
            symbol,
        }
    }
}

struct Player {
    x: usize,
    y: usize,
    energy: i32,
    joy: i32,
    seeds: i32,
}

impl Player {
    fn new() -> Self {
        Self {
            x: W / 2,
            y: H / 2,
            energy: 100,
            joy: 0,
            seeds: 3,
        }
    }
    fn move_player(&mut self, dx: isize, dy: isize) {
        self.x = ((self.x as isize + dx).clamp(0, (W - 1) as isize)) as usize;
        self.y = ((self.y as isize + dy).clamp(0, (H - 1) as isize)) as usize;
        self.energy -= 1;
    }
}

trait Magical {
    fn interact(&self, player: &mut Player, time: usize);
}

impl Magical for Entity {
    fn interact(&self, player: &mut Player, time: usize) {
        match self.kind {
            EntityType::Flower => {
                println!("🌸 The flower shimmers in the breeze. Joy +2");
                player.joy += 2;
            }
            EntityType::Tree => {
                println!("🌳 You rest beneath the tree. Energy +5");
                player.energy += 5;
            }
            EntityType::FruitTree => {
                println!("🍎 You pick ripe fruit. Energy +3, Joy +1");
                player.energy += 3;
                player.joy += 1;
            }
            EntityType::Fountain => {
                println!("⛲ The fountain sparkles mysteriously. Joy +3");
                player.joy += 3;
            }
            EntityType::Butterfly => {
                println!("🦋 A butterfly circles you. Joy +1");
                player.joy += 1;
            }
            EntityType::Statue => {
                let sayings = [
                    "🗿 'Patience grows roots.'",
                    "🗿 'Joy is its own light.'",
                    "🗿 'The soil remembers kindness.'",
                ];
                let mut rng = rand::thread_rng();
                println!("{}", sayings[rng.gen_range(0..sayings.len())]);
                player.joy += 2;
            }
            EntityType::Mushroom => {
                if time % 2 == 0 {
                    println!("🍄 The mushroom heals you. Energy +5");
                    player.energy += 5;
                } else {
                    println!("🍄 The mushroom was strange… Energy -3");
                    player.energy -= 3;
                }
            }
            EntityType::Treasure => {
                println!("💎 Hidden treasure sparkles! Joy +10");
                player.joy += 10;
            }
            EntityType::Firefly => {
                if time % 2 == 0 {
                    println!("🌟 Fireflies flicker, guiding your steps. Joy +2");
                    player.joy += 2;
                }
            }
            EntityType::River => {
                println!("〰️ The river babbles softly. Joy +1");
                player.joy += 1;
            }
            EntityType::Beehive => {
                let mut rng = rand::thread_rng();
                if rng.gen_bool(0.7) {
                    println!("🐝 Bees share honey. Energy +4, Joy +2");
                    player.energy += 4;
                    player.joy += 2;
                } else {
                    println!("🐝 Bees sting! Energy -5");
                    player.energy -= 5;
                }
            }
            EntityType::Spirit => {
                if player.joy > 20 {
                    println!("👻 A spirit blesses you. Joy +5, Energy +5");
                    player.energy += 5;
                    player.joy += 5;
                } else {
                    println!("👻 You feel a chill, but nothing happens.");
                }
            }
        }
    }
}

fn draw(player: &Player, entities: &[Entity], frame: usize) {
    print!("\x1B[2J\x1B[H");
    let day_night = match frame % 30 {
        0..=9 => "🌞 Day",
        10..=19 => "🌇 Twilight",
        _ => "🌙 Night",
    };
    println!("Enchanted Garden - Energy: {} | Joy: {} | Seeds: {} | {}", 
             player.energy, player.joy, player.seeds, day_night);
    println!();

    for y in 0..H {
        for x in 0..W {
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
                print!(" ");
            }
        }
        println!();
    }
}

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
    let mut rng = rand::thread_rng();
    let mut entities = vec![
        Entity::new(EntityType::Flower, "🌸"),
        Entity::new(EntityType::Tree, "🌳"),
        Entity::new(EntityType::FruitTree, "🍎"),
        Entity::new(EntityType::Fountain, "⛲"),
        Entity::new(EntityType::Butterfly, "🦋"),
        Entity::new(EntityType::Statue, "🗿"),
        Entity::new(EntityType::Mushroom, "🍄"),
        Entity::new(EntityType::Treasure, "💎"),
        Entity::new(EntityType::Beehive, "🍯"),
        Entity::new(EntityType::River, "〰️"),
        Entity::new(EntityType::Firefly, "🌟"),
    ];

    let mut frame = 0;
    loop {
        draw(&player, &entities, frame);

        for e in &entities {
            if e.x == player.x && e.y == player.y {
                e.interact(&mut player, frame);
            }
        }

        if player.energy <= 0 {
            println!("🌙 You collapse. The garden dreams without you.");
            break;
        }

        if let Some(c) = read_input() {
            match c {
                'w' => player.move_player(0, -1),
                's' => player.move_player(0, 1),
                'a' => player.move_player(-1, 0),
                'd' => player.move_player(1, 0),
                'p' => { // plant
                    if player.seeds > 0 {
                        entities.push(Entity { 
                            x: player.x, 
                            y: player.y, 
                            kind: EntityType::Flower, 
                            symbol: "🌱" 
                        });
                        player.seeds -= 1;
                        println!("🌱 You planted a seed.");
                    }
                }
                'q' => break,
                _ => {}
            }
        }

        frame += 1;
        sleep(Duration::from_millis(300));
    }

    println!("Final Joy: {}", player.joy);
    println!("The garden remembers your footsteps. 🌿");
}