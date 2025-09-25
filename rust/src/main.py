use rimd::{SMF, Track, TrackEvent, MidiMessage, SMFWriter};
use chrono::Local;
use rand::Rng;
use serde::{Serialize, Deserialize};
use std::fs::{OpenOptions, File};
use std::io::{self, Write};
use std::path::Path;

#[derive(Serialize, Deserialize, Debug, Clone)]
struct DailyEntry {
    date: String,
    moods: Vec<String>,
    activities: Vec<String>,
    colors: Vec<String>,
}

#[derive(Serialize, Deserialize, Debug)]
struct LifeState {
    entries: Vec<DailyEntry>,
}

impl LifeState {
    fn load(path: &str) -> Self {
        if Path::new(path).exists() {
            if let Ok(s) = std::fs::read_to_string(path) {
                if let Ok(d) = serde_json::from_str(&s) { return d; }
            }
        }
        LifeState { entries: vec![] }
    }

    fn save(&self, path: &str) {
        if let Ok(s) = serde_json::to_string_pretty(self) {
            let _ = std::fs::write(path, s);
        }
    }

    fn add_entry(&mut self, entry: DailyEntry) {
        self.entries.push(entry);
    }
}

fn mood_to_scale(mood: &str) -> Vec<u8> {
    match mood.to_lowercase().as_str() {
        "happy" => vec![60, 64, 67, 72],
        "sad" => vec![57, 60, 64, 67],
        "calm" => vec![55, 59, 62, 67],
        "angry" => vec![62, 65, 69, 74],
        _ => vec![60, 63, 67, 70],
    }
}

fn mood_to_color(mood: &str) -> String {
    match mood.to_lowercase().as_str() {
        "happy" => "#FFD700".to_string(),
        "sad" => "#1E90FF".to_string(),
        "calm" => "#00CED1".to_string(),
        "angry" => "#FF4500".to_string(),
        _ => "#808080".to_string(),
    }
}

fn generate_track(mood: &str, activity: &str) -> Track {
    let mut rng = rand::thread_rng();
    let scale = mood_to_scale(mood);
    let mut track = Track::new();
    let mut time = 0u32;

    for _ in 0..4 {
        let note = scale[rng.gen_range(0..scale.len())];
        let on = MidiMessage::note_on(0, note, 90);
        let off = MidiMessage::note_off(0, note, 90);
        track.push(TrackEvent::new(time, on));
        time += 240;
        track.push(TrackEvent::new(time, off));
        time += 10;
    }

    let text = format!("Mood: {}, Activity: {}", mood, activity);
    track.push(TrackEvent::new_text(0, &text));
    track
}

fn read_line(prompt: &str) -> String {
    print!("{}", prompt);
    let _ = io::stdout().flush();
    let mut s = String::new();
    let _ = io::stdin().read_line(&mut s);
    s.trim().to_string()
}

fn main() {
    let save_path = "life_state.json";
    let midi_path = "life_song.mid";
    let mut state = LifeState::load(save_path);

    let date = Local::now().format("%Y-%m-%d").to_string();
    let moods_input = read_line("Enter your moods today (comma separated): ");
    let activities_input = read_line("Enter activities today (comma separated): ");

    let moods: Vec<String> = moods_input.split(',').map(|s| s.trim().to_string()).collect();
    let activities: Vec<String> = activities_input.split(',').map(|s| s.trim().to_string()).collect();
    let colors: Vec<String> = moods.iter().map(|m| mood_to_color(m)).collect();

    state.add_entry(DailyEntry { date: date.clone(), moods: moods.clone(), activities: activities.clone(), colors: colors.clone() });
    state.save(save_path);

    let mut smf = if Path::new(midi_path).exists() {
        let data = std::fs::read(midi_path).unwrap();
        SMF::parse(&data).unwrap()
    } else {
        SMF::new()
    };

    for (i, mood) in moods.iter().enumerate() {
        let activity = activities.get(i).unwrap_or(&"general".to_string());
        let track = generate_track(mood, activity);
        smf.add_track(track);
    }

    let mut writer = SMFWriter::new();
    smf.write(&mut writer).unwrap();
    let mut file = OpenOptions::new().write(true).create(true).truncate(true).open(midi_path).unwrap();
    file.write_all(&writer.data).unwrap();

    println!("✅ Multi-layer MIDI track for {} saved to {}", date, midi_path);
    println!("Color palette for today: {:?}", colors);
}