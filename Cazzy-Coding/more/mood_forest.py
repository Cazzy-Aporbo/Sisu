import random
import math
import time

moods = ['happy', 'sad', 'curious', 'angry', 'excited', 'tired']
symbols = ['🌳', '🍂', '🌸', '🍁', '🌱']

class MoodTree:
    def __init__(self, mood):
        self.mood = mood
        self.height = random.randint(1, 5)
        self.symbol = random.choice(symbols)

    def grow(self):
        change = random.choice([-1, 0, 1])
        self.height = max(1, self.height + change)
        self.symbol = random.choice(symbols)
        self.mood = random.choice(moods)

    def display(self):
        return self.symbol * self.height + f"({self.mood})"

forest_size = random.randint(5, 10)
forest = [MoodTree(random.choice(moods)) for _ in range(forest_size)]

print("Quantum Mood Forest Simulation")
for step in range(10):
    print(f"\nStep {step+1}")
    for tree in forest:
        tree.grow()
        print(tree.display())
    time.sleep(0.5)