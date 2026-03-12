// main.rs
// Enchanted Garden — single-file Rust prototype
// Run: rustc main.rs -O && ./main
//
// No external crates required. This file is intentionally verbose and documented
// — read the comments; they are the learning material as well as the code.
//
// Author: Cazzy 🌿
//

use std::io::{self, Write};
use std::thread::sleep;
use std::time::Duration;

const WIDTH: usize = 60;
const HEIGHT: usize = 20;
const INITIAL_SEEDS: i32 = 3;
const TICKS_PER_SEASON: usize = 40; // how many frames each season lasts
const FLOWER_GROW_TICKS: usize = 6; // planted seed -> flower

// avoids depending on external crates; deterministic if you seed it.
struct SimpleRng {
    state: u64,
}
impl SimpleRng {
    fn new(seed: u64) -> Self { Self { state: seed.wrapping_add(0x9e3779b97f4a7c15) } }
    fn u64(&mut self) -> u64 {
        let mut x = self.state;
        x ^= x >> 12;
        x ^= x << 25;
        x ^= x >> 27;
        self.state = x;
        x.wrapping_mul(2685821657736338717u64)
    }
    fn usize(&mut self, bound: usize) -> usize {
        if bound == 0 { return 0; }
        (self.u64() as usize) % bound
    }
    fn boolp(&mut self, p: f64) -> bool {
        let u = (self.u64() as f64) / (std::u64::MAX as f64);
        u < p
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Season { Spring, Summer, Autumn, Winter }

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum TimeOfDay { Day, Twilight, Night }

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Kind {
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
    Seedling, // planted seed which will grow
}

#[derive(Clone, Debug)]
struct Entity {
    x: usize,
    y: usize,
    kind: Kind,
    variant: u8,   // small variety index
    age: usize,    // ticks alive (used for growth or blinking)
    alive: bool,   // treasure can be collected -> alive = false
}

impl Entity {
    fn new(x: usize, y: usize, kind: Kind, variant: u8) -> Self {
        Self { x, y, kind, variant, age: 0, alive: true }
    }

    // Provide emoji/symbol representation, influenced by season/time/age
    fn symbol(&self, season: Season, tod: TimeOfDay) -> &'static str {
        use Kind::*;
        match self.kind {
            Flower => match season {
                Season::Spring => "🌸",
                Season::Summer => "🌼",
                Season::Autumn => "🌺",
                Season::Winter => "❁",
            },
            Tree => match season {
                Season::Winter => "🌲",
                _ => "🌳",
            },
            Fountain => "⛲",
            Butterfly => "🦋",
            Statue => "🗿",
            Mushroom => {
                if self.age % 2 == 0 { "🍄" } else { "🍄" } // could vary
            }
            Treasure => "💎",
            Firefly => if tod == TimeOfDay::Night && self.age % 2 == 0 { "✨" } else { " " },
            River => "〰️",
            FruitTree => "🍎",
            Beehive => "🍯",
            Spirit => "👻",
            Seedling => "🌱",
        }
    }
}

struct Player {
    x: usize,
    y: usize,
    energy: i32,
    joy: i32,
    seeds: i32,
    journal: Vec<String>,
}
impl Player {
    fn new() -> Self {
        Self {
            x: WIDTH/2, y: HEIGHT/2,
            energy: 100, joy: 0, seeds: INITIAL_SEEDS,
            journal: Vec::new(),
        }
    }
    fn record(&mut self, s: String) {
        if self.journal.len() > 50 { self.journal.remove(0); }
        self.journal.push(s);
    }
}

struct World {
    entities: Vec<Entity>,
    rng: SimpleRng,
    tick: usize,
    season: Season,
    time_of_day: TimeOfDay,
}

impl World {
    fn new(seed: u64) -> Self {
        let mut rng = SimpleRng::new(seed);
        let mut entities = Vec::new();

        // Rivers: horizontal bands of river tiles
        for _ in 0..3 {
            let y = rng.usize(HEIGHT) / 3;
            for x in 0..WIDTH {
                if rng.usize(10) < 7 { // river patchiness
                    entities.push(Entity::new(x, y, Kind::River, 0));
                }
            }
        }

        // Clusters: flowers, trees, coral-like groupings
        for _ in 0..30 {
            let x = rng.usize(WIDTH);
            let y = rng.usize(HEIGHT);
            let k = match rng.usize(12) {
                0..=2 => Kind::Flower,
                3..=4 => Kind::Tree,
                5 => Kind::Fountain,
                6..=7 => Kind::Butterfly,
                8 => Kind::Statue,
                9 => Kind::Mushroom,
                10 => Kind::Beehive,
                11 => Kind::Treasure,
                _ => Kind::Flower,
            };
            entities.push(Entity::new(x, y, k, rng.usize(3) as u8));
        }

        // Fireflies: many; they blink at night
        for _ in 0..20 {
            entities.push(Entity::new(rng.usize(WIDTH), rng.usize(HEIGHT), Kind::Firefly, 0));
        }

        // Spirits hidden — appear only later if joy increases
        for _ in 0..6 {
            entities.push(Entity::new(rng.usize(WIDTH), rng.usize(HEIGHT), Kind::Spirit, 0));
        }

        Self {
            entities,
            rng,
            tick: 0,
            season: Season::Spring,
            time_of_day: TimeOfDay::Day,
        }
    }

    fn step(&mut self) {
        self.tick += 1;
        // Update season
        if self.tick % TICKS_PER_SEASON == 0 {
            self.season = match self.season {
                Season::Spring => Season::Summer,
                Season::Summer => Season::Autumn,
                Season::Autumn => Season::Winter,
                Season::Winter => Season::Spring,
            };
        }
        // Update time of day (simple cycle)
        let phase = (self.tick / 8) % 3;
        self.time_of_day = match phase {
            0 => TimeOfDay::Day,
            1 => TimeOfDay::Twilight,
            2 => TimeOfDay::Night,
            _ => TimeOfDay::Day,
        };

        // Age entities and apply behaviors
        for e in &mut self.entities {
            e.age += 1;
            match e.kind {
                Kind::Butterfly => {
                    // randomly flutter a tile
                    if self.rng.usize(3) == 0 {
                        e.x = (e.x + WIDTH + (self.rng.usize(3) as isize -1) as usize) % WIDTH;
                        e.y = (e.y + HEIGHT + (self.rng.usize(3) as isize -1) as usize) % HEIGHT;
                    }
                }
                Kind::Spirit => {
                    // Spirits are quiet unless player joy is high (handled by interact)
                }
                Kind::Mushroom => {
                    // possible sporadic flashing (visual)
                }
                Kind::Seedling => {
                    // grow into a flower after enough age
                    if e.age >= FLOWER_GROW_TICKS {
                        e.kind = Kind::Flower;
                        e.age = 0;
                    }
                }
                Kind::River => {
                    // rivers can shift within a small band occasionally
                    if self.rng.usize(100) == 0 {
                        let dy = if self.rng.boolp(0.5) { 1 } else { -1 };
                        let ny = ((e.y as isize + dy).clamp(0, (HEIGHT-1) as isize)) as usize;
                        e.y = ny;
                    }
                }
                Kind::Treasure => {
                    // treasure might slowly fade (no-op here)
                }
                Kind::Firefly => {
                    // they blink by virtue of symbol() depending on time and age
                }
                _ => {}
            }
        }

        // Occasionally spawn new butterflies/flowers
        if self.rng.usize(40) == 0 {
            self.entities.push(Entity::new(self.rng.usize(WIDTH), self.rng.usize(HEIGHT), Kind::Butterfly, 0));
        }
        if self.rng.usize(120) == 0 {
            self.entities.push(Entity::new(self.rng.usize(WIDTH), self.rng.usize(HEIGHT), Kind::Flower, 0));
        }
    }

    fn symbol_at(&self, x: usize, y: usize) -> Option<&'static str> {
        // Highest priority drawn first: player override handled by caller.
        // We search entities in reverse so newer ones overlay older ones.
        for e in self.entities.iter().rev() {
            if !e.alive { continue; }
            if e.x == x && e.y == y {
                return Some(e.symbol(self.season, self.time_of_day));
            }
        }
        None
    }

    fn collect_at(&mut self, x: usize, y: usize) -> Option<usize> {
        // Return index of found entity for collection/interaction
        for (i, e) in self.entities.iter().enumerate().rev() {
            if e.x == x && e.y == y && e.alive {
                return Some(i);
            }
        }
        None
    }
}

fn clear() {
    print!("\x1B[2J\x1B[H");
}

fn draw(world: &World, player: &Player) {
    clear();
    let season_emoji = match world.season {
        Season::Spring => "🌱 Spring",
        Season::Summer => "☀️ Summer",
        Season::Autumn => "🍂 Autumn",
        Season::Winter => "❄️ Winter",
    };
    let tod = match world.time_of_day {
        TimeOfDay::Day => "🌞 Day",
        TimeOfDay::Twilight => "🌇 Twilight",
        TimeOfDay::Night => "🌙 Night",
    };
    println!("Enchanted Garden — {} | {}  | Energy: {}  Joy: {}  Seeds: {}",
             season_emoji, tod, player.energy, player.joy, player.seeds);
    println!("Controls: W/A/S/D move, p plant, h harvest, r rest, . wait, q quit");
    println!();

    for y in 0..HEIGHT {
        for x in 0..WIDTH {
            if x == player.x && y == player.y {
                print!("🤠");
                continue;
            }
            if let Some(sym) = world.symbol_at(x, y) {
                // Firefly may show as space when not lit
                print!("{}", sym);
            } else {
                // empty ground: choose background by season (simple)
                match world.season {
                    Season::Spring => print!("·"),
                    Season::Summer => print!(" "),
                    Season::Autumn => print!("🍂"),
                    Season::Winter => print!(" "),
                }
            }
        }
        println!();
    }

    // Show last few journal lines
    println!("\n-- Journal --");
    let last = &player.journal;
    let s = last.len();
    for i in (if s>5 { s-5 } else { 0 })..s {
        println!("{}", last[i]);
    }
    io::stdout().flush().ok();
}

fn interact_at(world: &mut World, player: &mut Player) {
    if let Some(idx) = world.collect_at(player.x, player.y) {
        // clone to inspect kind
        let k = world.entities[idx].kind;
        match k {
            Kind::Flower => {
                player.joy += 2;
                player.record(format!("🌸 You admire a flower. Joy +2"));
            }
            Kind::Tree => {
                player.energy += 5;
                player.record(format!("🌳 You rest under a tree. Energy +5"));
            }
            Kind::Fountain => {
                player.joy += 3;
                player.record(format!("⛲ The fountain sings. Joy +3"));
            }
            Kind::Butterfly => {
                player.joy += 1;
                player.record("🦋 A butterfly flutters by. Joy +1".to_string());
            }
            Kind::Statue => {
                // random saying
                let sayings = [
                    "🗿 'Patience grows roots.'",
                    "🗿 'Joy is its own light.'",
                    "🗿 'The soil remembers kindness.'",
                    "🗿 'Listen—wind has words.'",
                ];
                let sidx = world.rng.usize(sayings.len());
                player.joy += 2;
                player.record(format!("{}", sayings[sidx]));
            }
            Kind::Mushroom => {
                if world.rng.boolp(0.5) {
                    player.energy += 6;
                    player.record("🍄 The mushroom heals you. Energy +6".to_string());
                } else {
                    player.energy -= 4;
                    player.record("🍄 The mushroom was odd... Energy -4".to_string());
                }
            }
            Kind::Treasure => {
                player.joy += 8;
                player.record("💎 You found treasure! Joy +8".to_string());
                world.entities[idx].alive = false; // picked up
            }
            Kind::Firefly => {
                if world.time_of_day == TimeOfDay::Night {
                    player.joy += 2;
                    player.record("✨ A firefly lights your way. Joy +2".to_string());
                }
            }
            Kind::River => {
                player.record("〰️ The river babbles; you feel calm. Joy +1".to_string());
                player.joy += 1;
            }
            Kind::FruitTree => {
                player.energy += 3;
                player.joy += 1;
                player.record("🍎 You pick fruit. Energy +3, Joy +1".to_string());
            }
            Kind::Beehive => {
                if world.rng.boolp(0.75) {
                    player.energy += 4; player.joy += 2;
                    player.record("🐝 Bees share honey. Energy +4, Joy +2".to_string());
                } else {
                    player.energy -= 6;
                    player.record("🐝 Bees sting! Energy -6".to_string());
                }
            }
            Kind::Spirit => {
                if player.joy >= 20 {
                    player.joy += 5; player.energy += 5;
                    player.record("👻 A spirit blesses you. Joy +5, Energy +5".to_string());
                } else {
                    player.record("👻 A whisper: 'Grow your joy...'. Nothing else.".to_string());
                }
            }
            Kind::Seedling => {
                player.record("🌱 You see your planted seed beginning to sprout.".to_string());
            }
        }
    }
}

// Plant seed at player
fn plant_seed(world: &mut World, player: &mut Player) {
    if player.seeds <= 0 {
        player.record("You have no seeds to plant.".to_string());
        return;
    }
    player.seeds -= 1;
    let e = Entity::new(player.x, player.y, Kind::Seedling, 0);
    world.entities.push(e);
    player.record("🌱 You plant a seed. It will bloom soon.".to_string());
}

// Harvest: collect treasure or fruit/tree
fn harvest(world: &mut World, player: &mut Player) {
    if let Some(idx) = world.collect_at(player.x, player.y) {
        let k = world.entities[idx].kind;
        match k {
            Kind::Treasure => {
                player.joy += 8;
                world.entities[idx].alive = false;
                player.record("💎 You harvest the treasure! Joy +8".to_string());
            }
            Kind::FruitTree => {
                player.energy += 4;
                player.record("🍎 You harvest a fruit. Energy +4".to_string());
            }
            Kind::Flower => {
                player.joy += 1;
                player.record("🌸 You pick a flower. Joy +1".to_string());
                world.entities[idx].alive = false;
            }
            Kind::Seedling => {
                player.record("🌱 It's still a small sprout.".to_string());
            }
            _ => {
                player.record("There's nothing useful to harvest here.".to_string());
            }
        }
    } else {
        player.record("There's nothing to harvest here.".to_string());
    }
}

// Rest to restore energy (sit under tree or just rest)
fn rest(player: &mut Player) {
    player.energy += 8;
    player.record("You rest for a moment. Energy +8".to_string());
}

fn prompt_input() -> Option<char> {
    print!("Action> ");
    io::stdout().flush().ok();
    let mut s = String::new();
    if let Ok(_) = io::stdin().read_line(&mut s) {
        return s.trim().chars().next();
    }
    None
}

fn main() {
    // Seed the RNG from the current time for variety
    let seed = {
        let t = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_secs();
        t ^ 0x9e3779b97f4a7c15
    };
    let mut world = World::new(seed);
    let mut player = Player::new();

    // initial journal message
    player.record("You enter an Enchanted Garden. The air is warm and full of promise.".to_string());

    loop {
        draw(&world, &player);

        // Check low energy
        if player.energy <= 0 {
            println!("\nYou lie down and the meadow closes its eyes. Game over.");
            break;
        }

        // Interaction automatically on standing tile
        interact_at(&mut world, &mut player);

        // Prompt & handle input
        if let Some(c) = prompt_input() {
            match c {
                'w' | 'W' => if player.y > 0 { player.y -= 1 },
                's' | 'S' => if player.y + 1 < HEIGHT { player.y += 1 },
                'a' | 'A' => if player.x > 0 { player.x -= 1 },
                'd' | 'D' => if player.x + 1 < WIDTH { player.x += 1 },
                'p' | 'P' => plant_seed(&mut world, &mut player),
                'h' | 'H' => harvest(&mut world, &mut player),
                'r' | 'R' => rest(&mut player),
                '.' => { /* wait */ player.record("You pause and listen to the garden.".to_string()); }
                'q' | 'Q' => {
                    println!("\nYou leave the garden. Goodbye.");
                    break;
                }
                _ => {
                    player.record("Unknown action. Try WASD/p/h/r/./q".to_string());
                }
            }
        }

        // One world tick: update world & age entities & maybe spawn
        world.step();

        // Simple decay/limits
        if player.energy > 200 { player.energy = 200; }
        if player.joy < -100 { player.joy = -100; }

        // small pause so messages are readable
        sleep(Duration::from_millis(60));
    }

    println!("\nFinal Joy: {}    Final Energy: {}\n", player.joy, player.energy);
    println!("Your Journal:");
    for line in player.journal {
        println!("  {}", line);
    }
}