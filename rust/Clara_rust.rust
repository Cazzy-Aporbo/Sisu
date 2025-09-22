// clara_rust.rs
use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

fn analyze_line(line: &str, lineno: usize) -> Vec<String> {
    let mut feedback = Vec::new();
    let lower = line.to_lowercase();

    if lower.contains("worried") || lower.contains("anxious") || lower.contains("tired") {
        feedback.push("Acknowledge the patient’s feelings.".to_string());
    }

    if lower.contains("mri") || lower.contains("ct") || lower.contains("hba1c") {
        feedback.push("Explain medical jargon simply.".to_string());
    }

    if lower.contains("family") || lower.contains("home") {
        feedback.push("Ask about lifestyle or social factors.".to_string());
    }

    // fallback: sprinkle general reminders
    if feedback.is_empty() && !line.trim().is_empty() {
        let craft_msgs = [
            "Pause: did the patient understand this sentence?",
            "Could you clarify this part to avoid confusion?",
            "Check empathy and tone here."
        ];
        feedback.push(craft_msgs[lineno % craft_msgs.len()].to_string());
    }

    feedback
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: {} transcript.txt", args[0]);
        return;
    }

    let filename = &args[1];
    if let Ok(lines) = read_lines(filename) {
        println!("🩺 Clara is reviewing {}...\n", filename);
        for (i, line) in lines.enumerate() {
            if let Ok(text) = line {
                let feedback = analyze_line(&text, i);
                if !feedback.is_empty() {
                    println!("Line {:3}: {}", i + 1, text);
                    for fb in feedback {
                        println!("   → {}", fb);
                    }
                    println!();
                }
            }
        }
    } else {
        eprintln!("Failed to read file: {}", filename);
    }

    println!("✅ Clara review complete.");
}

// helper function to read lines from a file
fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}