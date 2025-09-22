# clara_realtime.py (concept snippet)
import speech_recognition as sr
import re
import json
from datetime import datetime

PROMPTS = {
    "empathy": ["Acknowledge patient feelings.", "Check if patient feels heard."],
    "clarity": ["Explain jargon simply.", "Use an everyday analogy."],
    "thoroughness": ["Ask about lifestyle/social factors.", "Did patient understand instructions?"]
}

def analyze_line(line):
    feedback = []
    if any(word in line.lower() for word in ["worried", "anxious", "tired"]):
        feedback.append(PROMPTS["empathy"][0])
    if re.search(r"\bMRI\b|\bCT\b|\bHbA1c\b", line):
        feedback.append(PROMPTS["clarity"][0])
    if "family" in line.lower() or "home" in line.lower():
        feedback.append(PROMPTS["thoroughness"][0])
    return feedback

def listen_and_review():
    recognizer = sr.Recognizer()
    mic = sr.Microphone()
    log = []
    print("🎧 Clara is listening... (Ctrl+C to stop)")
    try:
        while True:
            with mic as source:
                audio = recognizer.listen(source, phrase_time_limit=5)
            try:
                text = recognizer.recognize_google(audio)
                feedback = analyze_line(text)
                if feedback:
                    print(f"💬 '{text}' → Suggestions: {feedback}")
                log.append({"time": str(datetime.now()), "text": text, "feedback": feedback})
            except sr.UnknownValueError:
                continue
    except KeyboardInterrupt:
        with open("clara_session.json", "w") as f:
            json.dump(log, f, indent=2)
        print("Session ended. Feedback logged to clara_session.json")