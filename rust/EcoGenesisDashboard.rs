// EcoGenesisDashboard.rs
// Author: Cazzy
// Purpose: Visual, emergent ecosystem simulation with energy & memory indicators

use rand::prelude::*;
use std::sync::{Arc, Mutex};
use std::time::Duration;
use futures::executor::block_on;
use futures::future::join_all;

#[derive(Debug, Clone)]
enum Species {
    Rabbit,
    Fox,
    Wolf,
}

#[derive(Debug, Clone)]
struct Agent {
    species: Species,
    energy: i32,
    x: usize,
    y: usize,
    memory: Vec<(usize, usize)>,
}

impl Agent {
    fn move_random(&mut self, grid_size: usize) {
        let mut rng = thread_rng();
        let mut dx = rng.gen_range(-1..=1);
        let mut dy = rng.gen_range(-1..=1);

        for &(mx, my) in &self.memory {
            if (self.x as i32 + dx) as usize == mx && (self.y as i32 + dy) as usize == my {
                dx = -dx;
                dy = -dy;
            }
        }

        self.x = ((self.x as i32 + dx).clamp(0, grid_size as i32 - 1)) as usize;
        self.y = ((self.y as i32 + dy).clamp(0, grid_size as i32 - 1)) as usize;
    }

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
                    other.energy = 0;
                    self.memory.push((other.x, other.y));
                    return Some(format!(
                        "{} hunted at ({},{})",
                        match self.species {
                            Species::Fox => "🦊 Fox",
                            Species::Wolf => "🐺 Wolf",
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

    fn energy_bar(&self) -> String {
        // Display a 3-char bar based on energy
        let filled = (self.energy / 5).clamp(0, 3);
        let empty = 3 - filled;
        format!("{}{}", "█".repeat(filled as usize), "░".repeat(empty as usize))
    }
}

struct Grid {
    size: usize,
    agents: Arc<Mutex<Vec<Agent>>>,
}

impl Grid {
    fn new(size: usize, rabbits: usize, foxes: usize, wolves: usize) -> Self {
        let mut rng = thread_rng();
        let mut agents_vec = Vec::new();

        for _ in 0..rabbits {
            agents_vec.push(Agent { species: Species::Rabbit, energy: 10, x: rng.gen_range(0..size), y: rng.gen_range(0..size), memory: Vec::new() });
        }
        for _ in 0..foxes {
            agents_vec.push(Agent { species: Species::Fox, energy: 20, x: rng.gen_range(0..size), y: rng.gen_range(0..size), memory: Vec::new() });
        }
        for _ in 0..wolves {
            agents_vec.push(Agent { species: Species::Wolf, energy: 30, x: rng.gen_range(0..size), y: rng.gen_range(0..size), memory: Vec::new() });
        }

        Grid { size, agents: Arc::new(Mutex::new(agents_vec)) }
    }

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

        let mut agents_guard = agents_clone.lock().unwrap();
        *agents_guard = moved_agents;

        // Interactions
        let mut logs: Vec<String> = Vec::new();
        for i in 0..agents_guard.len() {
            for j in (i+1)..agents_guard.len() {
                if let Some(log) = agents_guard[i].interact(&mut agents_guard[j]) {
                    logs.push(log);
                }
            }
        }

        // Remove dead agents
        agents_guard.retain(|a| a.energy > 0);

        // Display grid with memory highlights and energy
        println!("\n🌿 EcoGenesis Dashboard Step {} 🌿", step_number);
        for y in 0..self.size {
            for x in 0..self.size {
                let mut found = false;
                for agent in agents_guard.iter() {
                    if agent.x == x && agent.y == y {
                        match agent.species {
                            Species::Rabbit => print!("🐇"),
                            Species::Fox => print!("🦊"),
                            Species::Wolf => print!("🐺"),
                        }
                        print!("{}", agent.energy_bar()); // energy bar after emoji
                        found = true;
                        break;
                    }
                }
                if !found {
                    // Check if any memory marks this cell as dangerous
                    let mut danger = false;
                    for agent in agents_guard.iter() {
                        if agent.memory.contains(&(x, y)) {
                            danger = true;
                            break;
                        }
                    }
                    if danger {
                        print!("⚠️  "); // memory indicator
                    } else {
                        print!(".   ");
                    }
                }
            }
            println!();
        }

        for log in logs {
            println!("{}", log);
        }

        println!("Total agents: {}", agents_guard.len());
    }
}

fn main() {
    println!("Welcome to EcoGenesis Dashboard Simulator!");
    
    let grid = Grid::new(10, 10, 5, 2);

    block_on(async {
        for step in 1..=15 {
            grid.step(step).await;
            async_std::task::sleep(Duration::from_millis(400)).await;
        }
    });

    println!("Simulation complete! Agents adapted, remembered dangerous spots, and interacted dynamically.");
}