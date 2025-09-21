// SISU-1.rs
// Author: Cazzy
// Purpose: Production-ready chaotic interstellar simulator
// Features: Real-time input, warp, asteroids, aliens, loot, scoring, chaos events

use std::io::{stdout, Write};
use std::{thread, time};
use termion::raw::IntoRawMode;
use termion::async_stdin;
use termion::cursor;
use termion::clear;
use rand::prelude::*;

#[derive(Clone)]
struct Ship {
    x: usize,
    y: usize,
    hull: i32,
    shields: i32,
    fuel: i32,
    score: i32,
}

#[derive(Clone)]
struct Object {
    x: usize,
    y: usize,
    symbol: char,
}

fn draw_screen(ship: &Ship, stars: &Vec<Object>, asteroids: &Vec<Object>, aliens: &Vec<Object>, loot: &Vec<Object>) {
    print!("{}", clear::All);
    println!("🚀 SISU-1 Dashboard 🚀  Hull:{} Shields:{} Fuel:{} Score:{}",
        ship.hull, ship.shields, ship.fuel, ship.score);

    // Draw mini-screen
    for y in 0..20 {
        for x in 0..40 {
            let mut printed = false;
            if ship.x == x && ship.y == y {
                print!("🛸");
                printed = true;
            }
            for star in stars {
                if star.x == x && star.y == y && !printed {
                    print!("*");
                    printed = true;
                }
            }
            for ast in asteroids {
                if ast.x == x && ast.y == y && !printed {
                    print!("💥");
                    printed = true;
                }
            }
            for alien in aliens {
                if alien.x == x && alien.y == y && !printed {
                    print!("👾");
                    printed = true;
                }
            }
            for item in loot {
                if item.x == x && item.y == y && !printed {
                    print!("💎");
                    printed = true;
                }
            }
            if !printed { print!(" "); }
        }
        println!();
    }
}

fn move_objects(objects: &mut Vec<Object>, width: usize, height: usize) {
    let mut rng = thread_rng();
    for obj in objects.iter_mut() {
        let dx = rng.gen_range(-1..=1);
        let dy = rng.gen_range(-1..=1);
        obj.x = ((obj.x as i32 + dx).clamp(0, (width-1) as i32)) as usize;
        obj.y = ((obj.y as i32 + dy).clamp(0, (height-1) as i32)) as usize;
    }
}

fn check_collisions(ship: &mut Ship, asteroids: &mut Vec<Object>, aliens: &mut Vec<Object>, loot: &mut Vec<Object>) {
    let mut rng = thread_rng();
    // Asteroids
    asteroids.retain(|a| {
        if a.x == ship.x && a.y == ship.y {
            ship.hull -= 10;
            println!("💥 Collision with asteroid! Hull -10");
            false
        } else { true }
    });
    // Aliens
    aliens.retain(|a| {
        if a.x == ship.x && a.y == ship.y {
            ship.shields -= 5;
            println!("👾 Alien encounter! Shields -5");
            false
        } else { true }
    });
    // Loot
    loot.retain(|l| {
        if l.x == ship.x && l.y == ship.y {
            let gained = rng.gen_range(5..=20);
            ship.score += gained;
            println!("💎 Loot collected! Score +{}", gained);
            false
        } else { true }
    });
}

fn main() {
    let mut stdout = stdout().into_raw_mode().unwrap();
    write!(stdout, "{}{}", clear::All, cursor::Hide).unwrap();
    stdout.flush().unwrap();

    let mut stdin = async_stdin().bytes();

    let mut ship = Ship { x: 20, y: 10, hull: 100, shields: 50, fuel: 100, score: 0 };

    let mut rng = thread_rng();
    let mut stars: Vec<Object> = (0..50).map(|_| Object { x: rng.gen_range(0..40), y: rng.gen_range(0..20), symbol: '*' }).collect();
    let mut asteroids: Vec<Object> = (0..10).map(|_| Object { x: rng.gen_range(0..40), y: rng.gen_range(0..20), symbol: '💥' }).collect();
    let mut aliens: Vec<Object> = (0..5).map(|_| Object { x: rng.gen_range(0..40), y: rng.gen_range(0..20), symbol: '👾' }).collect();
    let mut loot: Vec<Object> = (0..5).map(|_| Object { x: rng.gen_range(0..40), y: rng.gen_range(0..20), symbol: '💎' }).collect();

    loop {
        draw_screen(&ship, &stars, &asteroids, &aliens, &loot);
        stdout.flush().unwrap();

        // Random movement
        move_objects(&mut stars, 40, 20);
        move_objects(&mut asteroids, 40, 20);
        move_objects(&mut aliens, 40, 20);

        check_collisions(&mut ship, &mut asteroids, &mut aliens, &mut loot);

        // Random chaos events
        if rng.gen_range(0..100) < 5 {
            println!("🌌 Random Wormhole! Ship jumps unpredictably!");
            ship.x = rng.gen_range(0..40);
            ship.y = rng.gen_range(0..20);
        }

        // Input handling
        if let Some(Ok(b)) = stdin.next() {
            match b as char {
                'q' => break,
                'w' => if ship.y > 0 { ship.y -= 1 },
                's' => if ship.y < 19 { ship.y += 1 },
                'a' => if ship.x > 0 { ship.x -= 1 },
                'd' => if ship.x < 39 { ship.x += 1 },
                'f' => println!("💥 Laser fired!"),
                _ => {}
            }
        }

        if ship.hull <= 0 || ship.shields < 0 || ship.fuel <= 0 {
            println!("💀 Ship destroyed! Game over!");
            break;
        }

        thread::sleep(time::Duration::from_millis(200));
    }

    write!(stdout, "{}{}", cursor::Show, clear::All).unwrap();
    println!("Final Score: {}", ship.score);
}