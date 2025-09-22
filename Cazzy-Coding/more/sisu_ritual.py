#!/usr/bin/env python3
"""
sisu_ritual.py — Sisu Ritual Kit (single program)

Features:
- Generates an animated, breathing SVG sigil (SMIL-based).
- Optionally synthesizes a drone WAV file (pure stdlib).
- Runs a console "chant mode" synced to the breathing pattern.
- Saves a JSON bundle with metadata.

Usage:
    python sisu_ritual.py "I must finish my draft"
    python sisu_ritual.py "My situation" --no-audio
    python sisu_ritual.py "My situation" --svg-only --outdir ./artifacts
    python sisu_ritual.py "My situation" --duration 30

All generated files are saved in the output directory (default: ./sisu_output).
"""

from __future__ import annotations
import argparse
import datetime
import math
import os
import json
import struct
import wave
import time
from hashlib import sha256
from random import Random, choice
from typing import Dict

OUTPUT_DIR_DEFAULT = "./sisu_output"

# ----- Creative pools -----
BATTLE_TEMPLATES = [
    "Stand, {name}. Breathe. Make the world yield.",
    "{name}, carry the small fire forward until it becomes a blaze.",
    "One step. One stubborn breath. {name} — do it anyway.",
    "When the shore is hidden, {name}, be the lighthouse.",
    "Keep the hinge moving, {name}. Persistence breaks the door."
]
MICRO_ACTIONS = [
    "Set a 12-minute timer. Produce one imperfect thing inside it.",
    "Remove one item from your work pile. Do only that for 5 minutes.",
    "Read one paragraph, then write one sentence inspired by it.",
    "Stand and walk to the window. Name three things you can control.",
    "Write the worst possible version of your goal in one sentence; then cross out one word."
]
POEMS = [
    "Granite remembers storms;\nyour footsteps make new maps.\nSisu keeps time.",
    "Night holds the long cold,\nbut your small pulse replies —\na steadfast ember.",
    "Ice learns the rhythm of thaw;\nso will your practice, slowly,\nlike rivers learning stone."
]
BREATH_PATTERNS = [
    {"inhale": 4, "hold": 2, "exhale": 6, "cycles": 3},
    {"inhale": 3, "hold": 3, "exhale": 5, "cycles": 4},
    {"inhale": 5, "hold": 0, "exhale": 5, "cycles": 3}
]
SOUND_SUGGESTIONS = [
    "deep cello loop (focus)",
    "wind through pines (calm clarity)",
    "single droning horn (centering)",
    "soft mechanical metronome (cadence)"
]
COLOR_PALETTES = [
    ["#0B3D91", "#F2C94C", "#E76F51"],  # deep blue, gold, terracotta
    ["#2E8B57", "#FFFFFF", "#6B4C3B"],  # forest green, white, bark brown
    ["#1F1B24", "#8B0000", "#FFD700"],  # charcoal, deep red, gold
]


# ----- Helpers -----
def hash_to_seed(s: str) -> int:
    h = sha256(s.encode("utf-8")).hexdigest()
    return int(h[:16], 16)


def ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


# ----- Bundle generation -----
def generate_bundle(situation: str, seed: int | None = None) -> Dict:
    if seed is None:
        seed = hash_to_seed(situation + "|" + datetime.datetime.utcnow().isoformat())
    rnd = Random(seed)
    name = situation.strip().split("\n")[0][:40]
    battle = choice(BATTLE_TEMPLATES).format(name=name)
    micro = choice(MICRO_ACTIONS)
    poem = choice(POEMS)
    breath = BREATH_PATTERNS[seed % len(BREATH_PATTERNS)]
    sound = SOUND_SUGGESTIONS[seed % len(SOUND_SUGGESTIONS)]
    palette = COLOR_PALETTES[seed % len(COLOR_PALETTES)]
    plan = [
        {"step": 1, "action": "Focus for 5 minutes on the smallest subtask."},
        {"step": 2, "action": "Complete a single imperfect draft of that subtask (≈10 minutes)."},
        {"step": 3, "action": "Share one line or paragraph for feedback; accept one small change."},
    ]
    ritual_minutes = 3 + (seed % 12)
    return {
        "situation": situation,
        "timestamp": datetime.datetime.utcnow().isoformat(timespec="seconds") + "Z",
        "seed": seed,
        "battle_cry": battle,
        "micro_action": micro,
        "micro_plan": plan,
        "poem": poem,
        "breathing": breath,
        "sound_suggestion": sound,
        "palette": palette,
        "ritual_minutes": ritual_minutes
    }


# ----- Animated sigil generator (SMIL SVG) -----
def generate_animated_sigil(bundle: Dict, filepath: str) -> str:
    """Create an animated SVG that pulses with the breathing pattern in bundle['breathing']."""
    w, h = 800, 800
    cx, cy = w // 2, h // 2
    seed = bundle["seed"]
    palette = bundle["palette"]
    breath = bundle["breathing"]
    total_cycle = breath["inhale"] + breath["hold"] + breath["exhale"]
    anim_duration = total_cycle  # seconds per cycle, loops indefinitely

    base_r = 80 + (seed % 90)
    rings = 3 + (seed % 3)
    rays = 6 + (seed % 5)

    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">'
    ]
    svg_parts.append(f'<rect width="100%" height="100%" fill="{palette[0]}" />')

    # rings with staggered phase offsets
    for i in range(rings):
        r0 = base_r + i * 40
        stroke_w = 2 + i
        phase_offset = (i * 0.15) * anim_duration
        svg_parts.append(
            f'<circle cx="{cx}" cy="{cy}" r="{r0}" fill="none" stroke="{palette[1]}" stroke-width="{stroke_w}" opacity="0.9">'
        )
        svg_parts.append(
            f'<animate attributeName="stroke-opacity" values="0.4;1;0.4" dur="{anim_duration}s" begin="{phase_offset}s" repeatCount="indefinite" />'
        )
        svg_parts.append(
            f'<animateTransform attributeName="transform" attributeType="XML" type="scale" from="1" to="1.06" dur="{anim_duration}s" begin="{phase_offset}s" repeatCount="indefinite" additive="sum" />'
        )
        svg_parts.append('</circle>')

    # radial rays
    for i in range(rays):
        ang = (2 * math.pi * i) / rays
        x2 = cx + int(math.cos(ang) * (base_r + 220))
        y2 = cy + int(math.sin(ang) * (base_r + 220))
        svg_parts.append(
            f'<line x1="{cx}" y1="{cy}" x2="{x2}" y2="{y2}" stroke="{palette[2]}" stroke-width="2" stroke-linecap="round" opacity="0.9">'
        )
        svg_parts.append(f'<animate attributeName="stroke-opacity" values="0.2;0.95;0.2" dur="{anim_duration}s" repeatCount="indefinite" />')
        svg_parts.append('</line>')

    # center orb pulses with breath
    center_r = int(base_r * 0.7)
    svg_parts.append('<g id="center">')
    svg_parts.append(f'<circle cx="{cx}" cy="{cy}" r="{center_r}" fill="{palette[1]}" opacity="0.95">')
    svg_parts.append(f'<animate attributeName="r" values="{int(center_r*0.9)};{int(center_r*1.15)};{int(center_r*0.9)}" dur="{anim_duration}s" repeatCount="indefinite" />')
    svg_parts.append(f'<animate attributeName="opacity" values="0.7;1;0.7" dur="{anim_duration}s" repeatCount="indefinite" />')
    svg_parts.append('</circle>')
    svg_parts.append('</g>')

    now = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%MZ")
    svg_parts.append(f'<text x="20" y="{h - 20}" font-family="sans-serif" font-size="14" fill="{palette[1]}">Sisu Sigil — {now}</text>')
    svg_parts.append('</svg>')

    ensure_dir(os.path.dirname(filepath) or ".")
    with open(filepath, "w", encoding="utf-8") as f:
        f.write("\n".join(svg_parts))
    return filepath


# ----- Drone WAV synthesis (stdlib only) -----
def synth_drone_wav(bundle: Dict, filepath: str, duration_seconds: int = 120) -> str:
    """
    Synthesize a simple drone + harmonic overtones WAV using only the standard library.
    Be mindful of duration: large durations will take proportionally longer to synthesize.
    """
    sample_rate = 44100
    amplitude = 16000  # 16-bit amplitude
    breath = bundle["breathing"]
    base_freq = 110 + (bundle["seed"] % 110)  # 110..219 Hz
    total_cycle = breath["inhale"] + breath["hold"] + breath["exhale"]
    lfo_rate = 1.0 / max(0.1, total_cycle)  # slow LFO for breathing amplitude
    num_frames = int(duration_seconds * sample_rate)

    ensure_dir(os.path.dirname(filepath) or ".")
    with wave.open(filepath, "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        for i in range(num_frames):
            t = i / sample_rate
            # LFO between ~0.5 and 1.0
            lfo = 0.75 + 0.25 * math.sin(2 * math.pi * lfo_rate * t)
            # core drone + slightly detuned harmonic
            sample = amplitude * lfo * (
                0.6 * math.sin(2 * math.pi * base_freq * t) +
                0.4 * math.sin(2 * math.pi * (base_freq * 2.01) * t)
            )
            # gentle fade-in/out (1.0s)
            if t < 1.0:
                sample *= (t / 1.0)
            if t > duration_seconds - 1.0:
                sample *= max(0.0, (duration_seconds - t) / 1.0)
            s = max(-32767, min(32767, int(sample)))
            wf.writeframes(struct.pack('<h', s))
    return filepath


# ----- Chant mode (console) -----
def chant_mode(bundle: Dict, live: bool = True) -> None:
    breath = bundle["breathing"]
    total_cycle = breath["inhale"] + breath["hold"] + breath["exhale"]
    cycles = breath.get("cycles", 3)
    battle = bundle["battle_cry"]
    # break into short phrases
    parts = [p.strip() for p in battle.replace("—", "-").split(",")]
    if len(parts) == 1:
        words = parts[0].split()
        parts = [" ".join(words[i:i + 3]) for i in range(0, len(words), 3)]

    print("\n--- Chant Mode — breathe with the sigil ---")
    try:
        for c in range(cycles):
            print(f"\nCycle {c + 1}/{cycles} — inhale {breath['inhale']}s, hold {breath['hold']}s, exhale {breath['exhale']}s")
            # Inhale: print parts paced across inhale time
            for p in parts:
                print(f"> {p}")
                time.sleep(max(0.2, breath['inhale'] / max(1, len(parts))))
            # Hold pause
            time.sleep(breath['hold'])
            # Exhale affirmation
            print(f"--- {battle} ---")
            time.sleep(breath['exhale'])
        print("\nChant complete. Carry the small fire forward.")
    except KeyboardInterrupt:
        print("\nChant interrupted. Keep the hinge moving.")


# ----- CLI & main flow -----
def build_parser():
    p = argparse.ArgumentParser(prog="sisu_ritual", description="Sisu Ritual Kit — sigil, chant, drone.")
    p.add_argument("situation", type=str, help="Your struggle, goal, or situation (wrap in quotes).")
    p.add_argument("--outdir", type=str, default=OUTPUT_DIR_DEFAULT, help="Output directory for files.")
    p.add_argument("--no-audio", action="store_true", help="Do not synthesize audio.")
    p.add_argument("--chant-only", action="store_true", help="Only run chant mode (no files generated).")
    p.add_argument("--svg-only", action="store_true", help="Only generate SVG and JSON (no audio, no chant).")
    p.add_argument("--duration", type=int, default=30, help="Drone duration in seconds (default 30).")
    return p


def main(argv=None):
    parser = build_parser()
    args = parser.parse_args(argv)

    outdir = args.outdir
    ensure_dir(outdir)

    if args.chant_only:
        bundle = generate_bundle(args.situation)
        chant_mode(bundle)
        return

    bundle = generate_bundle(args.situation)
    seed = bundle["seed"]
    svg_path = os.path.join(outdir, f"sisu_ritual_{seed}.svg")
    json_path = os.path.join(outdir, f"sisu_bundle_{seed}.json")

    # SVG
    svg_file = generate_animated_sigil(bundle, svg_path)
    print("Animated sigil written to:", svg_file)

    # JSON bundle
    with open(json_path, "w", encoding="utf-8") as jf:
        json.dump(bundle, jf, indent=2)
    print("Bundle JSON written to:", json_path)

    # Audio
    wav_file = None
    if not args.no_audio and not args.svg_only:
        wav_path = os.path.join(outdir, f"sisu_drone_{seed}.wav")
        print(f"Synthesizing drone audio ({args.duration}s) — this may take a few seconds...")
        try:
            wav_file = synth_drone_wav(bundle, wav_path, duration_seconds=max(2, args.duration))
            print("Drone audio written to:", wav_file)
        except KeyboardInterrupt:
            print("Audio synthesis interrupted. Partial file may exist.")

    # Chant mode (run unless svg-only)
    if not args.svg_only:
        chant_mode(bundle)

    print("\nAll done. Files saved in:", os.path.abspath(outdir))
    if wav_file:
        print("Play the WAV alongside the sigil in a browser or audio player for the ritual.")


if __name__ == "__main__":
    main()