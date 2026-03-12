// CazzyEcosystem.rs
// Author: Cazzy
// Purpose: Master-level Rust mini-project: Predator-Prey Ecosystem Simulation
// This file demonstrates advanced Rust concepts while being exploratory and interactive.

use rand::prelude::*;
use std::fmt;

// Entity Definitions
#[derive(Debug)]
enum Species {
    Rabbit,
    Fox,
}

#[derive(Debug)]
struct Entity {
    species: Species,
    energy: i32,
    x: i32,
    y: i32,
}

impl Entity {
    // Move entity randomly in 2D grid
    fn move_random(&mut self, grid_size: i32) {
        let mut rng = thread_rng();
        self.x = (self.x + rng.gen_range(-1..=1)).clamp(0, grid_size - 1);
        self.y = (self.y + rng.gen_range(-1..=1)).clamp(0, grid_size - 1);
    }

    // Interact with another entity
    fn interact(&mut self, other: &mut Entity) {
        match (&self.species, &other.species) {
            (Species::Fox, Species::Rabbit) => {
                if self.x == other.x && self.y == other.y {
                    println!("🦊 Fox caught a 🐇 Rabbit at ({},{})!", self.x, self.y);
                    self.energy += 5;
                    other.energy = 0; // Rabbit dies
                }
            }
            (Species::Rabbit, Species::Fox) => { /* Handled above */ }
            _ => {}
        }
    }
}

// Simulation Grid
struct Grid {
    size: i32,
    entities: Vec<Entity>,
}

impl Grid {
    fn new(size: i32, num_rabbits: usize, num_foxes: usize) -> Self {
        let mut entities = Vec::new();
        let mut rng = thread_rng();

        for _ in 0..num_rabbits {
            entities.push(Entity {
                species: Species::Rabbit,
                energy: 10,
                x: rng.gen_range(0..size),
                y: rng.gen_range(0..size),
            });
        }

        for _ in 0..num_foxes {
            entities.push(Entity {
                species: Species::Fox,
                energy: 20,
                x: rng.gen_range(0..size),
                y: rng.gen_range(0..size),
            });
        }

        Grid { size, entities }
    }

    // Step simulation
    fn step(&mut self) {
        // Move all entities
        for e in &mut self.entities {
            e.move_random(self.size);
        }

        // Interactions
        for i in 0..self.entities.len() {
            for j in (i + 1)..self.entities.len() {
                let (left, right) = self.entities.split_at_mut(j);
                left[i].interact(&mut right[0]);
            }
        }

        // Update energy and remove dead
        self.entities.retain(|e| e.energy > 0);

        // Reproduction (rabbits)
        let mut new_entities = Vec::new();
        for e in &self.entities {
            match e.species {
                Species::Rabbit if e.energy >= 15 => {
                    new_entities.push(Entity {
                        species: Species::Rabbit,
                        energy: 10,
                        x: e.x,
                        y: e.y,
                    });
                    println!("🐇 Rabbit reproduces at ({},{})!", e.x, e.y);
                }
                _ => {}
            }
        }
        self.entities.extend(new_entities);
    }

    // Display grid state
    fn display(&self) {
        println!("--- Grid State ---");
        for e in &self.entities {
            match e.species {
                Species::Rabbit => print!("🐇 "),
                Species::Fox => print!("🦊 "),
            }
        }
        println!("\nTotal entities: {}", self.entities.len());
    }
}

// Main Simulation
fn main() {
    println!("Welcome to Cazzy's Predator-Prey Ecosystem Simulation!");
    let mut grid = Grid::new(10, 10, 3); // 10x10 grid, 10 rabbits, 3 foxes

    for step in 1..=15 {
        println!("\n🌿 Simulation Step {} 🌿", step);
        grid.step();
        grid.display();
    }

    println!("\nSimulation complete! Explore, modify, and expand this ecosystem. 🦊🐇");
}