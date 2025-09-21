// SISU-1.rs
// Author: Cazzy
// Purpose: Ultimate Interstellar Adventure Terminal Simulator
// Fully interactive, dynamic ASCII space dashboard

use rand::prelude::*;
use std::io::{stdin, stdout, Write};
use std::{thread, time::Duration};

const WIDTH: usize = 50;
const HEIGHT: usize = 20;

struct Ship {
    x: usize,
    y: usize,
    fuel: i32,
    shields: i32,
    hull: i32,
}

struct Asteroid {
    x: usize,
    y: usize,
}

struct Loot {
    x: usize,
    y: usize,
    collected: bool,
}

struct Alien {
    x: usize,
    y: usize,
    friendly: bool,
}

fn clear_screen() {
    print!("\x1B[2J\x1B[H");
}

fn draw(stars: &Vec<(usize, usize)>, ship: &Ship, asteroids: &Vec<Asteroid>, loot: &Vec<Loot>, aliens: &Vec<Alien>) {
    clear_screen();
    // top HUD
    println!(
        "🚀 SISU-1 | Fuel: {}% | Shields: {}% | Hull: {}% | Score: {}",
        ship.fuel, ship.shields, ship.hull, loot.iter().filter(|l| l.collected).count() * 10
    );

    for y in 0..HEIGHT {
        for x in 0..WIDTH {
            let mut symbol = " ";

            // stars
            for &(sx, sy) in stars {
                if sx == x && sy == y {
                    symbol = "*";
                    break;
                }
            }

            // loot
            for l in loot {
                if !l.collected && l.x == x && l.y == y {
                    symbol = "💎";
                    break;
                }
            }

            // asteroids
            for a in asteroids {
                if a.x == x && a.y == y {
                    symbol = "💥";
                    break;
                }
            }

            // aliens
            for al in aliens {
                if al.x == x && al.y == y {
                    symbol = if al.friendly { "👽" } else { "🛸" };
                    break;
                }
            }

            // ship
            if ship.x == x && ship.y == y {
                symbol = "🚀";
            }

            print!("{}", symbol);
        }
        println!();
    }

    println!("\nControls: WASD to move | F: Fuel Boost | Q: Quit");
}

fn main() {
    let mut rng = thread_rng();
    let mut stars = Vec::new();
    let mut asteroids = Vec::new();
    let mut loot = Vec::new();
    let mut aliens = Vec::new();

    // generate stars
    for _ in 0..150 {
        stars.push((rng.gen_range(0..WIDTH), rng.gen_range(0..HEIGHT)));
    }

    // generate asteroids
    for _ in 0..10 {
        asteroids.push(Asteroid {
            x: rng.gen_range(0..WIDTH),
            y: rng.gen_range(0..HEIGHT),
        });
    }

    // generate loot
    for _ in 0..5 {
        loot.push(Loot {
            x: rng.gen_range(0..WIDTH),
            y: rng.gen_range(0..HEIGHT),
            collected: false,
        });
    }

    // generate aliens
    for _ in 0..5 {
        aliens.push(Alien {
            x: rng.gen_range(0..WIDTH),
            y: rng.gen_range(0..HEIGHT),
            friendly: rng.gen_bool(0.5),
        });
    }

    let mut ship = Ship {
        x: WIDTH / 2,
        y: HEIGHT / 2,
        fuel: 100,
        shields: 100,
        hull: 100,
    };

    loop {
        draw(&stars, &ship, &asteroids, &loot, &aliens);

        // check collisions with asteroids
        for a in &asteroids {
            if a.x == ship.x && a.y == ship.y {
                ship.shields -= 20;
                ship.hull -= 10;
                println!("💥 Crash! Shields and hull damaged!");
            }
        }

        // check loot collection
        for l in loot.iter_mut() {
            if !l.collected && l.x == ship.x && l.y == ship.y {
                l.collected = true;
                println!("💎 Collected treasure! +10 points");
            }
        }

        // check alien encounters
        for al in &aliens {
            if al.x == ship.x && al.y == ship.y {
                if al.friendly {
                    ship.fuel = (ship.fuel + 10).min(100);
                    println!("👽 Friendly alien refueled your ship! +10 fuel");
                } else {
                    ship.hull -= 15;
                    println!("🛸 Hostile alien attacked! Hull -15");
                }
            }
        }

        if ship.hull <= 0 {
            println!("💀 Your ship has been destroyed! Game Over!");
            break;
        }

        // read input
        print!("Enter command: ");
        stdout().flush().unwrap();
        let mut input = String::new();
        stdin().read_line(&mut input).unwrap();
        let input = input.trim().to_lowercase();

        match input.as_str() {
            "w" if ship.y > 0 => ship.y -= 1,
            "s" if ship.y < HEIGHT - 1 => ship.y += 1,
            "a" if ship.x > 0 => ship.x -= 1,
            "d" if ship.x < WIDTH - 1 => ship.x += 1,
            "f" => {
                if ship.fuel > 0 {
                    ship.fuel = (ship.fuel - 5).max(0);
                    println!("⚡ Boost activated!");
                }
            }
            "q" => break,
            _ => println!("Unknown command!"),
        }

        // move asteroids randomly
        for a in &mut asteroids {
            a.x = (a.x + rng.gen_range(-1..=1)).clamp(0, WIDTH - 1);
            a.y = (a.y + rng.gen_range(-1..=1)).clamp(0, HEIGHT - 1);
        }

        // move aliens randomly
        for al in &mut aliens {
            al.x = (al.x + rng.gen_range(-1..=1)).clamp(0, WIDTH - 1);
            al.y = (al.y + rng.gen_range(-1..=1)).clamp(0, HEIGHT - 1);
        }

        // slight delay for frame effect
        thread::sleep(Duration::from_millis(200));
    }

    println!("Game over! Final score: {}", loot.iter().filter(|l| l.collected).count() * 10);
}