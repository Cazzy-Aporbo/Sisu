#!/usr/bin/env python3
"""
sisu_engine.py — A creative "Sisu Engine" for generating grit-fueled responses.

Theme:
- Not a productivity tool but a ritual of resilience.
- Every run takes a struggle/goal and transforms it into:
    * A battle cry
    * A micro-action
    * A metaphor from Finnish nature

Run:
    python sisu_engine.py "I'm tired but need to finish this project"
"""

import argparse
import random
import datetime


BATTLE_CRIES = [
    "Stand. Endure. Break through.",
    "The storm does not dictate the sea.",
    "Iron hardens only under fire.",
    "Your breath is proof: you are not finished yet.",
    "Carry the impossible until it becomes ordinary.",
]

MICRO_ACTIONS = [
    "Drink a glass of water, then take one small step.",
    "Write a single sentence, let momentum carry you.",
    "Stand up, stretch, return sharper.",
    "Cut your task in half, then conquer the smaller half.",
    "Whisper your goal out loud. Let the room hear your resolve.",
]

METAPHORS = [
    "Like pine trees in winter — you bend, but you do not break.",
    "Rivers carve stone not by power, but by persistence.",
    "Even in endless night, the northern lights blaze without permission.",
    "The granite holds its silence, but endures for millennia.",
    "Snow may bury the path, but your footsteps make a new one.",
]


def sisu_response(situation: str) -> dict:
    """Generate a sisu-themed response bundle for a given situation/goal."""
    return {
        "situation": situation,
        "timestamp": datetime.datetime.now().isoformat(timespec="seconds"),
        "battle_cry": random.choice(BATTLE_CRIES),
        "micro_action": random.choice(MICRO_ACTIONS),
        "metaphor": random.choice(METAPHORS),
    }


def main():
    parser = argparse.ArgumentParser(
        description="Sisu Engine — forge resilience from struggle."
    )
    parser.add_argument(
        "situation", type=str, help="Your struggle, challenge, or goal."
    )
    args = parser.parse_args()

    out = sisu_response(args.situation)
    print("⚡ Sisu Engine ⚡")
    print(f"Situation: {out['situation']}")
    print(f"Battle Cry: {out['battle_cry']}")
    print(f"Micro Action: {out['micro_action']}")
    print(f"Metaphor: {out['metaphor']}")


if __name__ == "__main__":
    main()