// CazzyAsyncScheduler.rs
// Author: Cazzy
// Purpose: Master-level Rust mini-project demonstrating async concurrency

use std::time::Duration;
use futures::executor::block_on;
use futures::future::join_all;

struct Task {
    name: String,
    duration_ms: u64,
}

impl Task {
    async fn run(&self) -> String {
        println!("🚀 Starting task: {}", self.name);
        async_std::task::sleep(Duration::from_millis(self.duration_ms)).await;
        format!("✅ Finished task: {}", self.name)
    }
}

fn main() {
    println!("Welcome to Cazzy's Async Task Scheduler!");
    let tasks = vec![
        Task { name: "Fetch Data".to_string(), duration_ms: 500 },
        Task { name: "Process Data".to_string(), duration_ms: 800 },
        Task { name: "Save Results".to_string(), duration_ms: 300 },
    ];

    let futures_vec = tasks.iter().map(|t| t.run());
    let results = block_on(join_all(futures_vec));

    for res in results {
        println!("{}", res);
    }

    println!("All tasks complete! Explore by adding dependencies, priorities, or random delays.");
}