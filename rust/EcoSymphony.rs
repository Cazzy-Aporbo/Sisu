// EcoSymphony.rs
use rand::prelude::*;
use std::{thread, time::Duration};

#[derive(Debug, Clone)]
enum Species { Rabbit, Fox, Wolf }

#[derive(Debug, Clone)]
struct Agent {
    species: Species,
    energy: i32,
    angle: f64, // circular position
    radius: f64,
    trail: Vec<(f64, f64)>, // past positions
}

impl Agent {
    fn move_orbit(&mut self) {
        let mut rng = thread_rng();
        let delta = rng.gen_range(-0.1..0.1);
        self.angle += delta;
        self.radius += rng.gen_range(-0.1..0.1);
        if self.radius < 1.0 { self.radius = 1.0; }
        if self.radius > 10.0 { self.radius = 10.0; }
        self.trail.push((self.angle, self.radius));
        if self.trail.len() > 5 { self.trail.remove(0); }
    }

    fn emoji(&self) -> &str {
        match self.species {
            Species::Rabbit => "🐇",
            Species::Fox => "🦊",
            Species::Wolf => "🐺",
        }
    }

    fn glow(&self) -> String {
        let intensity = (self.energy / 5).clamp(1, 5);
        match intensity {
            1 => "\x1b[2m", // dim
            2 => "\x1b[0m", // normal
            3 => "\x1b[1m", // bright
            4 => "\x1b[1;33m", // yellow
            5 => "\x1b[1;31m", // red
            _ => "\x1b[0m",
        }.to_string()
    }
}

fn main() {
    let mut rng = thread_rng();
    let mut agents: Vec<Agent> = (0..12).map(|_| {
        Agent {
            species: match rng.gen_range(0..3) {
                0 => Species::Rabbit,
                1 => Species::Fox,
                _ => Species::Wolf,
            },
            energy: rng.gen_range(5..25),
            angle: rng.gen_range(0.0..6.28),
            radius: rng.gen_range(1.0..10.0),
            trail: Vec::new(),
        }
    }).collect();

    for step in 0..20 {
        println!("\x1B[2J\x1B[H"); // clear
        println!("🎵 EcoSymphony Step {} 🎵", step);

        // render radial dashboard
        for agent in agents.iter_mut() {
            agent.move_orbit();
            let x = (agent.radius * agent.angle.cos()) as i32 + 20;
            let y = (agent.radius * agent.angle.sin()) as i32 + 10;

            print!("{}{}{} at ({},{}) ", agent.glow(), agent.emoji(), "\x1b[0m", x, y);
        }

        println!("\n\nTrails:");
        for agent in agents.iter() {
            for &(a, r) in agent.trail.iter() {
                let tx = (r * a.cos()) as i32 + 20;
                let ty = (r * a.sin()) as i32 + 10;
                print!("."); // trail marker
            }
        }

        thread::sleep(Duration::from_millis(400));
    }
}