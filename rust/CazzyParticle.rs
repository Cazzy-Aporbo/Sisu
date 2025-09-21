// CazzyParticles.rs
// Author: Cazzy
// Purpose: Advanced particle simulation demonstrating Rust ownership, traits, and random dynamics

use rand::prelude::*;

struct Particle {
    x: f64,
    y: f64,
    vx: f64,
    vy: f64,
}

impl Particle {
    fn update(&mut self) {
        self.x += self.vx;
        self.y += self.vy;
    }

    fn interact(&mut self, other: &mut Particle) {
        let dx = self.x - other.x;
        let dy = self.y - other.y;
        let dist = (dx*dx + dy*dy).sqrt();
        if dist < 1.0 {
            // Simple elastic collision
            std::mem::swap(&mut self.vx, &mut other.vx);
            std::mem::swap(&mut self.vy, &mut other.vy);
        }
    }

    fn display(&self) {
        println!("Particle at ({:.2},{:.2}) moving ({:.2},{:.2})", self.x, self.y, self.vx, self.vy);
    }
}

fn main() {
    println!("Welcome to Cazzy's Particle Simulation!");

    let mut rng = thread_rng();
    let mut particles: Vec<Particle> = (0..5).map(|_| Particle {
        x: rng.gen_range(0.0..10.0),
        y: rng.gen_range(0.0..10.0),
        vx: rng.gen_range(-0.5..0.5),
        vy: rng.gen_range(-0.5..0.5),
    }).collect();

    for step in 0..10 {
        println!("\nStep {}", step);
        for i in 0..particles.len() {
            for j in (i+1)..particles.len() {
                let (left, right) = particles.split_at_mut(j);
                left[i].interact(&mut right[0]);
            }
        }

        for p in &mut particles {
            p.update();
            p.display();
        }
    }

    println!("Simulation complete! Expand with more particles, forces, or visualization!");
}