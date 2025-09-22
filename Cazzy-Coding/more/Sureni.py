#!/usr/bin/env python3
"""
sureni.py — The She-Checker of Sisu
-----------------------------------
Every time you write code, Sureni stands beside you
and asks the deep, hard questions every data scientist,
statistician, and engineer must face.

Usage:
    python sureni.py your_script.py
"""

import sys
import re

# Core questions grouped by theme
QUESTIONS = {
    "ethics": [
        "Whose voices are missing from this data?",
        "If this fails in production, who gets hurt?",
        "Am I respecting privacy in how this is stored or logged?",
    ],
    "statistics": [
        "What assumptions am I making about distributions?",
        "Am I confusing correlation with causation?",
        "Where is the uncertainty in this model?",
    ],
    "engineering": [
        "Will this scale if the dataset is 100x larger?",
        "Do I understand the time and space complexity here?",
        "What’s the worst-case input that breaks this?",
    ],
    "craft": [
        "Is this line readable to another human in 6 months?",
        "Am I reinventing the wheel when a library exists?",
        "Did I write a test that covers this logic?",
    ]
}

def sureni_check_line(line: str, lineno: int):
    # Very simple heuristics to attach questions
    prompts = []
    if re.search(r"train|fit|model", line):
        prompts += QUESTIONS["statistics"]
        prompts.append("What is my evaluation metric and why?")
    if re.search(r"SELECT|query|read_csv", line, re.I):
        prompts.append("Am I checking data quality before using it?")
        prompts.append("What biases may be baked into this dataset?")
    if re.search(r"for |while ", line):
        prompts.append("What happens if this loop runs forever?")
        prompts.append("How will this scale?")
    if re.search(r"def |class ", line):
        prompts.append("Have I written tests for this function/class?")
        prompts.append("What are the edge cases?")
    if re.search(r"import ", line):
        prompts.append("Do I trust this dependency? Does it introduce risk?")

    # General wisdom sprinkling
    if not prompts and line.strip():
        prompts.append(QUESTIONS["craft"][lineno % len(QUESTIONS["craft"])])

    return prompts

def main():
    if len(sys.argv) < 2:
        print("Usage: python sureni.py your_script.py")
        sys.exit(1)

    target_file = sys.argv[1]
    try:
        with open(target_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"File not found: {target_file}")
        sys.exit(1)

    print(f"🔍 Sureni is checking {target_file} ...\n")

    for i, line in enumerate(lines, 1):
        qlist = sureni_check_line(line, i)
        if qlist:
            print(f"Line {i:3d}: {line.strip()}")
            for q in qlist:
                print(f"   → {q}")
            print()

    print("✅ Sureni check complete. Keep the hinge moving, coder.")

if __name__ == "__main__":
    main()