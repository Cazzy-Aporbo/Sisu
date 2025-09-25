use rand::Rng;
use chrono::prelude::*;
use serde::{Serialize, Deserialize};
use std::io::{self, Write};
use std::fs;
use std::path::Path;

const MAP_W: usize = 48;
const MAP_H: usize = 18;

#[derive(Serialize, Deserialize, Debug, Clone)]
struct DreamEntry {
    date: String,
    fragments: Vec<String>,
    lucid: bool,
}

#[derive(Serialize, Deserialize, Debug)]
struct SaveData {
    entries: Vec<DreamEntry>,
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

    fn total_fragments(&self) -> usize {
        self.entries.iter().map(|e| e.fragments.len()).sum()
    }

    fn add_fragment_for_today(&mut self, frag: String, today: &str) -> bool {
        if let Some(e) = self.entries.iter_mut().find(|x| x.date == today) {
            if !e.fragments.contains(&frag) {
                e.fragments.push(frag);
                return true;
            }
            return false;
        } else {
            self.entries.push(DreamEntry { date: today.to_string(), fragments: vec![frag], lucid: false });
            return true;
        }
    }

    fn mark_lucid_today(&mut self, today: &str) {
        if let Some(e) = self.entries.iter_mut().find(|x| x.date == today) {
            e.lucid = true;
        } else {
            self.entries.push(DreamEntry { date: today.to_string(), fragments: vec![], lucid: true });
        }
    }
}

#[derive(Clone)]
enum Tile {
    Void,
    Cloud,
    Fragment,
    Nightmare,
    Portal,
}

struct Player {
    x: usize,
    y: usize,
    lucidity: i32,
}

impl Player {
    fn new() -> Self {
        Self { x: MAP_W/2, y: MAP_H/2, lucidity: 50 }
    }

    fn move_by(&mut self, dx: isize, dy: isize) {
        let nx = (self.x as isize + dx).clamp(0, (MAP_W-1) as isize) as usize;
        let ny = (self.y as isize + dy).clamp(0, (MAP_H-1) as isize) as usize;
        self.x = nx; self.y = ny;
    }
}

fn make_map(rng: &mut impl Rng) -> Vec<Vec<Tile>> {
    let mut map = vec![vec![Tile::Void; MAP_W]; MAP_H];
    for y in 1..MAP_H-1 {
        for x in 1..MAP_W-1 {
            let p = rng.gen_range(0..100);
            map[y][x] = match p {
                0..=60 => Tile::Cloud,
                61..=75 => Tile::Fragment,
                76..=88 => Tile::Nightmare,
                _ => Tile::Cloud,
            };
        }
    }
    let px = rng.gen_range(2..MAP_W-2);
    let py = rng.gen_range(1..MAP_H-2);
    map[py][px] = Tile::Portal;
    map
}

fn draw(player: &Player, map: &Vec<Vec<Tile>>, data: &SaveData) {
    print!("\x1B[2J\x1B[H");
    println!("Dreamland — Lucidity: {}  |  Fragments total: {}", player.lucidity, data.total_fragments());
    println!("Controls: w/a/s/d move  r record fragment at portal  l mark lucid at portal  t today  c calendar  q quit");
    println!();
    for y in 0..MAP_H {
        for x in 0..MAP_W {
            if x == player.x && y == player.y {
                print!("💫");
                continue;
            }
            match &map[y][x] {
                Tile::Void => print!(" "),
                Tile::Cloud => print!("☁️"),
                Tile::Fragment => print!("🧩"),
                Tile::Nightmare => print!("🌑"),
                Tile::Portal => print!("🚪"),
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
        for (i, t) in e.fragments.iter().enumerate() {
            println!("{}. {}", i+1, t);
        }
        println!("Lucid: {}", if e.lucid { "yes" } else { "no" });
        println!("Total fragments today: {}", e.fragments.len());
    } else {
        println!("No fragments recorded today.");
    }
    println!("\nPress Enter to continue...");
    let _ = read_line_trim();
}

fn show_calendar(data: &SaveData) {
    println!("\n=== Dream Calendar ===");
    let mut es = data.entries.clone();
    es.sort_by(|a,b| a.date.cmp(&b.date));
    for e in es {
        println!("{} — {} fragment(s) — lucid: {}", e.date, e.fragments.len(), if e.lucid { "yes" } else { "no" });
        for t in e.fragments.iter() {
            println!("   • {}", t);
        }
    }
    println!("\nFragments total: {}", data.total_fragments());
    println!("\nPress Enter to continue...");
    let _ = read_line_trim();
}

fn main() {
    let save_path = "dreams.json";
    let mut data = SaveData::load(save_path);
    let mut rng = rand::thread_rng();
    let mut map = make_map(&mut rng);
    let mut player = Player::new();
    loop {
        draw(&player, &map, &data);
        if player.lucidity <= 0 {
            println!("Lucidity faded. Wake gently and return later.");
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
                if let Tile::Portal = map[player.y][player.x] {
                    println!("At a portal. Describe a dream fragment:");
                    let frag = read_line_trim();
                    if frag.is_empty() {
                        println!("Nothing recorded. Press Enter...");
                        let _ = read_line_trim();
                        continue;
                    }
                    let today = Local::now().format("%Y-%m-%d").to_string();
                    let added = data.add_fragment_for_today(frag.clone(), &today);
                    if added {
                        println!("Recorded fragment for {}.", today);
                        player.lucidity += 12;
                        if player.lucidity > 120 { player.lucidity = 120; }
                    } else {
                        println!("Fragment already recorded today.");
                    }
                    data.save(save_path);
                    println!("Press Enter to continue...");
                    let _ = read_line_trim();
                } else {
                    println!("You must stand on a portal (🚪) to record. Press Enter...");
                    let _ = read_line_trim();
                }
            }
            'l' => {
                if let Tile::Portal = map[player.y][player.x] {
                    let today = Local::now().format("%Y-%m-%d").to_string();
                    data.mark_lucid_today(&today);
                    data.save(save_path);
                    println!("Marked today as lucid. Lucidity +20.");
                    player.lucidity += 20;
                    if player.lucidity > 150 { player.lucidity = 150; }
                    println!("Press Enter to continue...");
                    let _ = read_line_trim();
                } else {
                    println!("Stand on a portal to mark lucidity. Press Enter...");
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
        if let Tile::Fragment = map[player.y][player.x] {
            let gain = rng.gen_range(3..8);
            println!("You collect a drifting fragment. +{} lucidity.", gain);
            player.lucidity += gain;
            map[player.y][player.x] = Tile::Cloud;
            println!("Press Enter to continue...");
            let _ = read_line_trim();
        } else if let Tile::Nightmare = map[player.y][player.x] {
            let loss = rng.gen_range(6..18);
            println!("A nightmare tugs at you. -{} lucidity.", loss);
            player.lucidity -= loss;
            map[player.y][player.x] = Tile::Cloud;
            println!("Press Enter to continue...");
            let _ = read_line_trim();
        }
        player.lucidity -= 1;
        if rng.gen_bool(0.025) {
            map = make_map(&mut rng);
        }
    }
    println!("Dream fragments collected this year: {}", data.total_fragments());
}