pub fn analyze_line(line: &str, lineno: usize) -> Vec<String> {
    let mut feedback = Vec::new();
    let lower = line.to_lowercase();

    // empathy cues
    if lower.contains("worried") || lower.contains("anxious") || lower.contains("tired") {
        feedback.push("Acknowledge patient feelings.".to_string());
    }

    // clarity cues
    if lower.contains("mri") || lower.contains("ct") || lower.contains("hba1c") {
        feedback.push("Explain medical jargon simply.".to_string());
    }

    // thoroughness cues
    if lower.contains("family") || lower.contains("home") {
        feedback.push("Ask about lifestyle or social factors.".to_string());
    }

    // fallback general reminders
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