import random
import time

class HappyPanda:
    def __init__(self, name):
        self.name = name
        self.energy = random.randint(50, 100)
        self.happiness = random.randint(50, 100)
        self.position = random.randint(0, 10)

    def hop(self):
        distance = random.randint(1, self.energy // 10 + 1)
        self.position += distance
        self.energy -= random.randint(5, 10)
        print(f"{self.name} hops {distance} spaces! 🐼💨")

    def dance(self):
        moves = ['twirl','bounce','shuffle','spin','wiggle']
        move = random.choice(moves)
        self.happiness += random.randint(1, 5)
        print(f"{self.name} does a {move} dance! 🎵 Happiness +{self.happiness}")

    def give_gift(self):
        if random.random() < 0.3:
            gift = random.choice(['bamboo', 'flower', 'tiny hat', 'smile'])
            print(f"{self.name} gives you a {gift}! 🎁")

    def sing(self):
        songs = ["🎶 Bamboo Boogie", "🎵 Happy Paw Parade", "🎶 Smile Shuffle"]
        print(f"{self.name} sings: {random.choice(songs)}")

    def __str__(self):
        trail = "🐾" * min(self.position, 10)
        return f"{self.name} | Pos:{self.position} | Energy:{self.energy} | Happiness:{self.happiness} | {trail}"

pandas = [HappyPanda(name) for name in ["Momo","Bunbun","Coco","Lulu"]]

print("Welcome to the Happy Panda Chaos Simulator!")

while True:
    for p in pandas:
        p.hop()
        p.dance()
        p.give_gift()
        p.sing()
        print(p)
    print()
    time.sleep(0.5)