use rand::Rng;
use chrono::prelude::*;
use serde::{Serialize, Deserialize};
use std::io::{self, Write};
use std::fs;
use std::path::Path;

const MAP_W: usize = 40;
const MAP_H: usize = 15;

#[derive(Serialize, Deserialize, Debug, Clone)]
struct ReadingEntry {
    date: String,
    titles: Vec<String>,
}

#[derive(Serialize, Deserialize, Debug)]
struct SaveData {
    entries: Vec<ReadingEntry>,
}

impl SaveData {
    fn load(path: &str) -> Self {
        if Path::new(path).exists() {
            if let Ok(s) = fs::read_to_string(path) {
                if let Ok(d) = serde_json::from_str(&s) {
                    return d;
                }
            }
        }
        SaveData { entries: vec![] }
    }

    fn save(&self, path: &str) {
        if let Ok(s) = serde_json::to_string_pretty(self) {
            let _ = fs::write(path, s);
        }
    }

    fn total_books(&self) -> usize {
        self.entries.iter().map(|e| e.titles.len()).sum()
    }

    fn add_title_for_today(&mut self, title: String, today: &str) -> bool {
        if let Some(e) = self.entries.iter_mut().find(|x| x.date == today) {
            if !e.titles.contains(&title) {
                e.titles.push(title);
                return true;
            }
            return false;
        } else {
            self.entries.push(ReadingEntry { date: today.to_string(), titles: vec![title] });
            return true;
        }
    }
}

#[derive(Clone)]
enum Tile {
    Floor,
    Shelf,
    Ghost,
    Door,
}

struct Player {
    x: usize,
    y: usize,
    light: i32,
}

impl Player {
    fn new() -> Self {
        Self { x: MAP_W/2, y: MAP_H/2, light: 100 }
    }

    fn move_by(&mut self, dx: isize, dy: isize) {
        let nx = (self.x as isize + dx).clamp(0, (MAP_W-1) as isize) as usize;
        let ny = (self.y as isize + dy).clamp(0, (MAP_H-1) as isize) as usize;
        self.x = nx; self.y = ny;
    }
}

fn make_map(rng: &mut impl Rng) -> Vec<Vec<Tile>> {
    let mut map = vec![vec![Tile::Floor; MAP_W]; MAP_H];
    for y in 1..MAP_H-1 {
        for x in 2..MAP_W-2 {
            if rng.gen_bool(0.08) {
                map[y][x] = Tile::Shelf;
            }
        }
    }
    for _ in 0..(MAP_W*MAP_H/50) {
        let gx = rng.gen_range(1..MAP_W-1);
        let gy = rng.gen_range(1..MAP_H-1);
        map[gy][gx] = Tile::Ghost;
    }
    map[0][MAP_W/2] = Tile::Door;
    map
}

fn draw(player: &Player, map: &Vec<Vec<Tile>>, data: &SaveData) {
    print!("\x1B[2J\x1B[H");
    println!("Haunted Library — Light: {}  |  Year Total: {}", player.light, data.total_books());
    println!("Controls: w/a/s/d move  r mark read at shelf  t view today  c calendar  q quit");
    println!();
    for y in 0..MAP_H {
        for x in 0..MAP_W {
            if x == player.x && y == player.y {
                print!("🕯️");
                continue;
            }
            match &map[y][x] {
                Tile::Floor => print!(" "),
                Tile::Shelf => print!("📚"),
                Tile::Ghost => print!("👻"),
                Tile::Door => print!("🚪"),
            }
        }
        println!();
    }
    println!();
}

fn read_line_trim() -> String {
    let mut s = String::new();
    let _ = io::stdin().read_line(&mut s);
    s.trim().to_string()
}

fn show_today(data: &SaveData, today: &str) {
    println!("\n=== Today: {} ===", today);
    if let Some(e) = data.entries.iter().find(|x| x.date == today) {
        for (i, t) in e.titles.iter().enumerate() {
            println!("{}. {}", i+1, t);
        }
        println!("Total today: {}", e.titles.len());
    } else {
        println!("You haven't logged any books today.");
    }
    println!("\nPress Enter to continue...");
    let _ = read_line_trim();
}

fn show_calendar(data: &SaveData) {
    println!("\n=== Reading Calendar (dates with reads) ===");
    let mut es = data.entries.clone();
    es.sort_by(|a,b| a.date.cmp(&b.date));
    for e in es {
        println!("{} — {} book(s)", e.date, e.titles.len());
        for t in e.titles.iter() {
            println!("   • {}", t);
        }
    }
    println!("\nYear total: {}", data.total_books());
    println!("\nPress Enter to continue...");
    let _ = read_line_trim();
}

fn main() {
    let save_path = "reading_progress.json";
    let mut data = SaveData::load(save_path);
    let mut rng = rand::thread_rng();
    let mut map = make_map(&mut rng);
    let mut player = Player::new();
    loop {
        draw(&player, &map, &data);
        if player.light <= 0 {
            println!("Your candle extinguished. You must read to rekindle it.");
            println!("Press Enter to quit.");
            let _ = read_line_trim();
            break;
        }
        print!("Command: ");
        let _ = io::stdout().flush();
        let input = read_line_trim();
        if input.is_empty() { continue; }
        let mut chars = input.chars();
        match chars.next().unwrap_or(' ') {
            'w' => player.move_by(0, -1),
            's' => player.move_by(0, 1),
            'a' => player.move_by(-1, 0),
            'd' => player.move_by(1, 0),
            'q' => {
                data.save(save_path);
                break;
            }
            'r' => {
                if let Tile::Shelf = map[player.y][player.x] {
                    println!("You're at a shelf. Enter book title to log:");
                    let title = read_line_trim();
                    if title.is_empty() {
                        println!("No title entered. Press Enter to continue...");
                        let _ = read_line_trim();
                        continue;
                    }
                    let today = Local::now().format("%Y-%m-%d").to_string();
                    let added = data.add_title_for_today(title.clone(), &today);
                    if added {
                        println!("Logged \"{}\" for {}.", title, today);
                        player.light += 10;
                        if player.light > 120 { player.light = 120; }
                    } else {
                        println!("Title already logged today.");
                    }
                    data.save(save_path);
                    println!("Press Enter to continue...");
                    let _ = read_line_trim();
                } else {
                    println!("You must stand on a shelf (📚) to log a book. Press Enter...");
                    let _ = read_line_trim();
                }
            }
            't' => {
                let today = Local::now().format("%Y-%m-%d").to_string();
                show_today(&data, &today);
            }
            'c' => {
                show_calendar(&data);
            }
            _ => {}
        }
        if let Tile::Ghost = map[player.y][player.x] {
            let bite = rng.gen_range(5..15);
            println!("A ghost chills your candle! Light -{}.", bite);
            player.light -= bite;
            map[player.y][player.x] = Tile::Floor;
            println!("The ghost drifts away. Press Enter to continue...");
            let _ = read_line_trim();
        }
        player.light -= 1;
        if rng.gen_bool(0.02) {
            map = make_map(&mut rng);
        }
    }
    println!("Final year total: {}", data.total_books());
}