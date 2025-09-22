use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use vosk::{Model, Recognizer};
use std::sync::{Arc, Mutex};
mod analysis;

fn main() -> anyhow::Result<()> {
    // Load Vosk STT model
    let model = Model::new("model")?;
    let recognizer = Arc::new(Mutex::new(Recognizer::new(&model, 16000.0)?));

    // Set up microphone input
    let host = cpal::default_host();
    let device = host.default_input_device().expect("No input device available");
    let config = device.default_input_config()?;

    // Stream audio to recognizer
    let recognizer_clone = recognizer.clone();
    let stream = device.build_input_stream(
        &config.into(),
        move |data: &[f32], _: &cpal::InputCallbackInfo| {
            let mut rec = recognizer_clone.lock().unwrap();
            rec.accept_waveform_f32(data);
            if let Some(result) = rec.result() {
                for line in result.text.lines() {
                    let feedback = analysis::analyze_line(line, 0);
                    for fb in feedback {
                        println!("💬 '{line}' → {fb}");
                    }
                }
            }
        },
        move |err| eprintln!("Stream error: {:?}", err),
    )?;
    stream.play()?;

    println!("🎧 Clara is live. Press Ctrl+C to stop.");
    loop {
        std::thread::sleep(std::time::Duration::from_secs(1));
    }
}