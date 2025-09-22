#!/usr/bin/env python3
"""
EchoForge Advanced — transform text/code/data into evolving echoes
"""

import os
import json
import math
import random
import datetime
import wave
import struct
import numpy as np

OUTPUT_DIR = "./echoforge_output"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# --- Session Memory ---
SESSION_FILE = os.path.join(OUTPUT_DIR, "session.json")
if os.path.exists(SESSION_FILE):
    with open(SESSION_FILE, "r", encoding="utf-8") as f:
        session = json.load(f)
else:
    session = []

# --- Helper Functions ---
def hash_text(s):
    return sum(ord(c) for c in s)

def generate_reflection(text):
    # Simple AI-like reframe using keywords
    words = text.split()
    if len(words) < 3:
        return f"Your idea: '{text}' — could unfold further."
    keyword = random.choice(words)
    return f"Consider '{keyword}' from another perspective; it resonates with deeper patterns."

def generate_visual(text, filename):
    # Create animated SVG with shapes based on text
    width, height = 800, 800
    chars = [ord(c) for c in text if c.isalpha()]
    if not chars:
        chars = [65, 66, 67]
    color_seed = sum(chars) % 360
    num_shapes = max(3, len(chars)//2)
    svg_parts = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}">']
    svg_parts.append('<rect width="100%" height="100%" fill="#111111"/>')

    for i in range(num_shapes):
        r = 50 + (chars[i % len(chars)] % 100)
        cx = (i*150 + chars[i % len(chars)]) % width
        cy = (i*120 + chars[i % len(chars)]) % height
        hue = (color_seed + i*30) % 360
        svg_parts.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="hsl({hue},70%,50%)">')
        svg_parts.append(f'<animate attributeName="r" values="{r};{r*1.3};{r}" dur="3s" repeatCount="indefinite"/>')
        svg_parts.append('</circle>')
    now = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
    svg_parts.append(f'<text x="20" y="{height-20}" fill="#ffffff" font-family="sans-serif" font-size="14">EchoForge {now}</text>')
    svg_parts.append('</svg>')

    with open(filename, "w", encoding="utf-8") as f:
        f.write("\n".join(svg_parts))
    return filename

def generate_audio(text, filename, duration=10):
    # Procedural audio from text
    sample_rate = 44100
    t = np.linspace(0, duration, int(sample_rate*duration))
    base_freq = 220 + (hash_text(text) % 200)
    waveform = np.sin(2*np.pi*base_freq*t)
    # add harmonics
    for i in range(2,5):
        waveform += 0.3*np.sin(2*np.pi*(base_freq*i)*t + i)
    waveform /= np.max(np.abs(waveform))  # normalize
    waveform = (waveform * 32767).astype(np.int16)

    with wave.open(filename, "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(waveform.tobytes())
    return filename

# --- Main Loop ---
print("🎇 EchoForge Advanced — type your idea/code/text (Ctrl+C to quit)")

try:
    while True:
        text = input("\nEnter text: ").strip()
        if not text:
            continue

        # Generate echo components
        echo_id = len(session)+1
        svg_file = os.path.join(OUTPUT_DIR, f"echo_{echo_id}.svg")
        wav_file = os.path.join(OUTPUT_DIR, f"echo_{echo_id}.wav")
        visual_path = generate_visual(text, svg_file)
        audio_path = generate_audio(text, wav_file)
        reflection = generate_reflection(text)

        echo = {
            "id": echo_id,
            "input": text,
            "visual": visual_path,
            "audio": audio_path,
            "reflection": reflection,
            "timestamp": datetime.datetime.utcnow().isoformat() + "Z"
        }
        session.append(echo)

        # Output
        print(f"\n✨ Echo #{echo_id} created!")
        print(f" - Visual SVG: {visual_path}")
        print(f" - Audio WAV: {audio_path}")
        print(f" - Reflection: {reflection}")

except KeyboardInterrupt:
    with open(SESSION_FILE, "w", encoding="utf-8") as f:
        json.dump(session, f, indent=2)
    print("\n💾 Session saved. All echoes are stored in", OUTPUT_DIR)
    print("Goodbye!")