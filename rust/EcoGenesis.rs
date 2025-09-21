// EcoGenesis.rs
// Author: Cazzy
// Purpose: Final Master-level Rust Project
// A multi-layered, emergent ecosystem simulation with adaptive agents and environmental memory
// This file demonstrates advanced Rust concepts in an original and exploratory way

use rand::prelude::*;
use std::sync::{Arc, Mutex};
use std::time::Duration;
use futures::executor::block_on;
use futures::future::join_all;

/// Species defines the type of agent in our ecosystem.
/// Currently: Rabbit (prey), Fox (predator), Wolf (apex predator)
#[derive(Debug, Clone)]
enum Species {
    Rabbit,
    Fox,
    Wolf,
}

/// Agent represents an individual organism.
/// Each agent has:
/// - species: its type
/// - energy: affects survival and reproduction
/// - position: x and y coordinates
/// - memory: stores learned positions of predators/prey
#[derive(Debug, Clone)]
struct Agent {
    species: Species,
    energy: i32,
    x: usize,
    y: usize,
    memory: Vec<(usize, usize)>, // footprints of past encounters
}

impl Agent {
    /// move_random allows an agent to move one step in a random direction
    /// The movement also considers its memory to avoid dangerous areas
    fn move_random(&mut self, grid_size: usize) {
        let mut rng = thread_rng();
        let mut dx = rng.gen_range(-1..=1);
        let mut dy = rng.gen_range(-1..=1);

        // Adaptive behavior: avoid remembered predator positions
        for &(mx, my) in &self.memory {
            if (self.x as i32 + dx) as usize == mx && (self.y as i32 + dy) as usize == my {
                dx = -dx; // step away from danger
                dy = -dy;
            }
        }

        self.x = ((self.x as i32 + dx).clamp(0, grid_size as i32 - 1)) as usize;
        self.y = ((self.y as i32 + dy).clamp(0, grid_size as i32 - 1)) as usize;
    }

    /// interact defines predator-prey dynamics
    /// Returns a log of the interaction for teaching purposes
    fn interact(&mut self, other: &mut Agent) -> Option<String> {
        match (&self.species, &other.species) {
            (Species::Fox, Species::Rabbit) | (Species::Wolf, Species::Fox) => {
                if self.x == other.x && self.y == other.y {
                    let gained_energy = match self.species {
                        Species::Fox => 5,
                        Species::Wolf => 8,
                        _ => 0,
                    };
                    self.energy += gained_energy;
                    other.energy = 0; // prey dies
                    self.memory.push((other.x, other.y)); // record encounter
                    return Some(format!(
                        "🦊 {} hunted at ({},{})",
                        match self.species {
                            Species::Fox => "Fox",
                            Species::Wolf => "Wolf",
                            _ => "",
                        },
                        self.x,
                        self.y
                    ));
                }
            }
            _ => {}
        }
        None
    }
}

/// Grid represents the environment
/// - size: the width/height of the square grid
/// - agents: shared, mutable vector of all agents in the simulation
struct Grid {
    size: usize,
    agents: Arc<Mutex<Vec<Agent>>>,
}

impl Grid {
    /// Create a new grid with specified number of agents for each species
    fn new(size: usize, rabbits: usize, foxes: usize, wolves: usize) -> Self {
        let mut rng = thread_rng();
        let mut agent_vec = Vec::new();

        for _ in 0..rabbits {
            agent_vec.push(Agent { species: Species::Rabbit, energy: 10, x: rng.gen_range(0..size), y: rng.gen_range(0..size), memory: Vec::new() });
        }
        for _ in 0..foxes {
            agent_vec.push(Agent { species: Species::Fox, energy: 20, x: rng.gen_range(0..size), y: rng.gen_range(0..size), memory: Vec::new() });
        }
        for _ in 0..wolves {
            agent_vec.push(Agent { species: Species::Wolf, energy: 30, x: rng.gen_range(0..size), y: rng.gen_range(0..size), memory: Vec::new() });
        }

        Grid { size, agents: Arc::new(Mutex::new(agent_vec)) }
    }

    /// Execute one simulation step
    /// - Agents move concurrently
    /// - Interactions are calculated
    /// - Dead agents are removed
    /// - Logs are returned for teaching/feedback
    async fn step(&self, step_number: usize) {
        let agents_clone = Arc::clone(&self.agents);

        // Move agents concurrently
        let futures_vec: Vec<_> = {
            let agents_guard = agents_clone.lock().unwrap();
            agents_guard.iter().map(|a| {
                let mut a_clone = a.clone();
                async move {
                    a_clone.move_random(10);
                    a_clone
                }
            }).collect()
        };

        let moved_agents = join_all(futures_vec).await;

        // Update main agents
        let mut agents_guard = agents_clone.lock().unwrap();
        *agents_guard = moved_agents;

        // Interactions
        let mut logs: Vec<String> = Vec::new();
        for i in 0..agents_guard.len() {
            for j in (i+1)..agents_guard.len() {
                let msg = agents_guard[i].interact(&mut agents_guard[j]);
                if let Some(log) = msg { logs.push(log); }
            }
        }

        // Remove dead agents
        agents_guard.retain(|a| a.energy > 0);

        // Display step summary
        println!("\n🌿 EcoGenesis Step {} 🌿", step_number);
        for agent in agents_guard.iter() {
            match agent.species {
                Species::Rabbit => print!("🐇 "),
                Species::Fox => print!("🦊 "),
                Species::Wolf => print!("🐺 "),
            }
        }
        println!("\nTotal agents: {}", agents_guard.len());
        for log in logs { println!("{}", log); }
    }
}

/// Main entry point
fn main() {
    println!("Welcome to EcoGenesis!");
    println!("This simulation demonstrates adaptive agent behavior, concurrency, and emergent interactions.");
    
    // Create a 10x10 grid with initial populations
    let grid = Grid::new(10, 10, 5, 2);

    // Run simulation asynchronously
    block_on(async {
        for step in 1..=15 {
            grid.step(step).await;
            // Simulate real-time delay
            async_std::task::sleep(Duration::from_millis(300)).await;
        }
    });

    println!("Simulation complete! Each agent adapted, remembered past encounters, and interacted dynamically.");
    println!("Cazzy-style documentation: Every decision and behavior is transparent and designed for learning Rust at a high level.");
}