#!/usr/bin/env python3
"""
clara.py — Conversational Co-Pilot for Doctors
----------------------------------------------
Clara listens to a transcript (or live input) of a doctor-patient
conversation and suggests improvements in empathy, clarity,
and thoroughness.

Usage:
    python clara.py transcript.txt
"""

import sys
import re

PROMPTS = {
    "empathy": [
        "Did you acknowledge the patient’s feelings explicitly?",
        "Did you check if the patient feels heard?",
        "Could you slow down here to let the patient process?"
    ],
    "clarity": [
        "This term may be medical jargon — how can it be explained simply?",
        "Is there an analogy or everyday example you could use?",
        "Does the patient know what this test actually involves?"
    ],
    "thoroughness": [
        "Did you ask about lifestyle or social factors that could affect this?",
        "Did you check for patient understanding before moving on?",
        "Is there a follow-up question that could reveal more context?"
    ]
}

def clara_check_line(line: str, lineno: int):
    line_lower = line.lower()
    feedback = []

    if any(word in line_lower for word in ["pain", "anxious", "worried", "tired"]):
        feedback.append(PROMPTS["empathy"][lineno % len(PROMPTS["empathy"])])

    if re.search(r"\bMRI\b|\bCT\b|\bangiogram\b|\bhba1c\b", line):
        feedback.append(PROMPTS["clarity"][lineno % len(PROMPTS["clarity"])])

    if "take this medication" in line_lower or "prescribe" in line_lower:
        feedback.append("Did you check if the patient understands how to take this medication?")

    if "family" in line_lower or "home" in line_lower:
        feedback.append(PROMPTS["thoroughness"][lineno % len(PROMPTS["thoroughness"])])

    # fallback — sprinkle general reminders
    if not feedback and line.strip():
        feedback.append("Pause and ask: did the patient really understand this sentence?")

    return feedback


def main():
    if len(sys.argv) < 2:
        print("Usage: python clara.py transcript.txt")
        sys.exit(1)

    file = sys.argv[1]
    try:
        with open(file, "r", encoding="utf-8") as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"File not found: {file}")
        sys.exit(1)

    print(f"🩺 Clara is reviewing {file} ...\n")

    for i, line in enumerate(lines, 1):
        feedback = clara_check_line(line, i)
        if feedback:
            print(f"Line {i:3d}: {line.strip()}")
            for fb in feedback:
                print(f"   → {fb}")
            print()

    print("✅ Clara review complete. Build conversations that heal.")

if __name__ == "__main__":
    main()