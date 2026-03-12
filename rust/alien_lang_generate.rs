use rand::seq::SliceRandom;
use rand::Rng;
use std::fs::File;
use std::io::{Write, BufWriter};

#[derive(Debug)]
struct Word {
    alien: String,
    meaning: String,
    part_of_speech: String,
}

fn generate_phoneme_word() -> String {
    let consonants = ["k","t","p","s","m","n","r","l","v","z"];
    let vowels = ["a","e","i","o","u"];
    let mut rng = rand::thread_rng();
    let mut word = String::new();
    let len = rng.gen_range(2..6);
    for i in 0..len {
        if i % 2 == 0 {
            word.push_str(consonants.choose(&mut rng).unwrap());
        } else {
            word.push_str(vowels.choose(&mut rng).unwrap());
        }
    }
    word
}

fn generate_word() -> Word {
    let meanings = ["sun","moon","water","fire","sky","star","life","death","love","time"];
    let parts_of_speech = ["noun","verb","adjective","adverb"];
    let mut rng = rand::thread_rng();
    Word {
        alien: generate_phoneme_word(),
        meaning: meanings.choose(&mut rng).unwrap().to_string(),
        part_of_speech: parts_of_speech.choose(&mut rng).unwrap().to_string(),
    }
}

fn generate_sentence(words: &[Word]) -> String {
    let mut rng = rand::thread_rng();
    let sentence_len = rng.gen_range(3..7);
    let chosen: Vec<&Word> = (0..sentence_len).map(|_| words.choose(&mut rng).unwrap()).collect();
    chosen.iter().map(|w| w.alien.clone()).collect::<Vec<_>>().join(" ") + "."
}

fn main() {
    let mut words = Vec::new();
    for _ in 0..100 {
        words.push(generate_word());
    }

    let file = File::create("alien_corpus.csv").unwrap();
    let mut writer = BufWriter::new(file);
    writeln!(writer,"alien_word,meaning,part_of_speech").unwrap();
    for w in &words {
        writeln!(writer, "{},{},{}", w.alien, w.meaning, w.part_of_speech).unwrap();
    }

    println!("Example sentences:");
    for _ in 0..5 {
        println!("{}", generate_sentence(&words));
    }
}