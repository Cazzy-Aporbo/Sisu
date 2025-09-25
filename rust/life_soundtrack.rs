//! LifeSoundtrack 4.0 Prototype
//! A synesthetic, AI-ready, multi-layer MIDI diary
//! 
//! Features:
//! - Multi-input moods and activities
//! - AI motif generation (placeholder)
//! - Mock song feature integration
//! - Color palette visualization in terminal
//! - Persistent JSON state

use rimd::{SMF, Track, TrackEvent, MidiMessage, SMFWriter};
use serde::{Serialize, Deserialize};
use chrono::Local;
use rand::Rng;
use std::fs::{OpenOptions, File};
use std::io::{self, Write};
use std::path::Path;

// Data structure for a single day’s entry
#[derive(Serialize, Deserialize, Debug)]
struct Entry {
    date: String,
    moods: Vec<String>,
    acts: Vec<String>,
    palette: Vec<String>,
    motifs: Vec<String>,
    songs: Vec<String>,
}

// Persistent life diary
#[derive(Serialize, Deserialize, Debug)]
struct LifeBook {
    pages: Vec<Entry>,
}

impl LifeBook {
    // Load existing diary or create new
    fn load(path: &str) -> Self {
        if Path::new(path).exists() {
            std::fs::read_to_string(path)
                .ok()
                .and_then(|s| serde_json::from_str(&s).ok())
                .unwrap_or(LifeBook { pages: vec![] })
        } else {
            LifeBook { pages: vec![] }
        }
    }

    // Save diary to JSON
    fn save(&self, path: &str) {
        if let Ok(s) = serde_json::to_string_pretty(self) {
            let _ = std::fs::write(path, s);
        }
    }

    // Add a new entry
    fn add(&mut self, e: Entry) {
        self.pages.push(e);
    }
}

// Map moods to musical scales
fn mood_to_scale(m: &str) -> Vec<u8> {
    match m.to_lowercase().as_str() {
        "happy" => vec![60,64,67,72],
        "sad" => vec![57,60,64,67],
        "calm" => vec![55,59,62,67],
        "angry" => vec![62,65,69,74],
        _ => vec![60,63,67,70],
    }
}

// Map moods to colors
fn mood_to_color(m: &str) -> String {
    match m.to_lowercase().as_str() {
        "happy" => "#FFD700".to_string(),
        "sad" => "#1E90FF".to_string(),
        "calm" => "#00CED1".to_string(),
        "angry" => "#FF4500".to_string(),
        _ => "#808080".to_string(),
    }
}

// Generate an AI motif (placeholder)
fn ai_motif(text: &str) -> String {
    format!("motif_{}", text.replace(" ", "_"))
}

// Mock function for extracting song features
fn extract_song_features(_s: &str) -> (Vec<u8>, u32) {
    (vec![60,64,67,72], 120) // C major, 120 bpm
}

// Generate a MIDI track from mood, activity, motif, and song features
fn generate_track(mood: &str, activity: &str, motif: &str, _song_features: (Vec<u8>, u32)) -> Track {
    let mut rng = rand::thread_rng();
    let scale = mood_to_scale(mood);
    let mut track = Track::new();
    let mut time = 0u32;

    for _ in 0..4 {
        let note = scale[rng.gen_range(0..scale.len())];
        track.push(TrackEvent::new(time, MidiMessage::note_on(0,note,90)));
        time += 240;
        track.push(TrackEvent::new(time, MidiMessage::note_off(0,note,90)));
        time += 10;
    }

    track.push(TrackEvent::new_text(0, &format!("Mood: {}, Activity: {}, Motif: {}", mood, activity, motif)));
    track
}

// Read a line of input from the terminal
fn read_line(prompt: &str) -> String {
    print!("{}", prompt);
    let _ = io::stdout().flush();
    let mut s = String::new();
    let _ = io::stdin().read_line(&mut s);
    s.trim().to_string()
}

// Display color palette in terminal
fn visualize_palette(palette: &Vec<String>) {
    println!("Today's color palette:");
    for color in palette {
        println!("{}", color);
    }
}

// Main function
fn main() {
    let json_path = "lifebook.json";
    let midi_path = "lifesound.mid";

    // Load or create diary
    let mut book = LifeBook::load(json_path);

    // Collect user input
    let date = Local::now().format("%Y-%m-%d").to_string();
    let moods: Vec<String> = read_line("Enter moods today (comma separated): ").split(',').map(|s| s.trim().to_string()).collect();
    let acts: Vec<String> = read_line("Enter activities today (comma separated): ").split(',').map(|s| s.trim().to_string()).collect();
    let songs: Vec<String> = read_line("Reference songs (optional, comma separated): ").split(',').map(|s| s.trim().to_string()).collect();

    // Compute color palette and AI motifs
    let palette: Vec<String> = moods.iter().map(|m| mood_to_color(m)).collect();
    let motifs: Vec<String> = moods.iter().map(|m| ai_motif(m)).collect();

    // Add entry to diary and save
    book.add(Entry {
        date: date.clone(),
        moods: moods.clone(),
        acts: acts.clone(),
        palette: palette.clone(),
        motifs: motifs.clone(),
        songs: songs.clone(),
    });
    book.save(json_path);

    // Load or create MIDI file
    let mut smf = if Path::new(midi_path).exists() {
        SMF::parse(&std::fs::read(midi_path).unwrap()).unwrap()
    } else {
        SMF::new()
    };

    // Generate tracks for each mood/activity
    for i in 0..moods.len() {
        let mood = &moods[i];
        let act = acts.get(i).unwrap_or(&"general".to_string());
        let motif = &motifs[i];
        let song_feat = extract_song_features(songs.get(i).unwrap_or(&"".to_string()));
        let track = generate_track(mood, act, motif, song_feat);
        smf.add_track(track);
    }

    // Write MIDI file
    let mut writer = SMFWriter::new();
    smf.write(&mut writer).unwrap();
    let mut file = OpenOptions::new().write(true).create(true).truncate(true).open(midi_path).unwrap();
    file.write_all(&writer.data).unwrap();

    // Display results
    println!("LifeSoundtrack saved: {}", midi_path);
    visualize_palette(&palette);
}