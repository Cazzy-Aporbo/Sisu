import random
import time

class Kangaroo:
    def __init__(self, name):
        self.name = name
        self.position = 0
        self.energy = random.randint(50,100)
        self.mood = random.choice(['happy','sassy','singing','thoughtful'])

    def jump(self):
        distance = random.randint(1, self.energy//10 + 1)
        self.position += distance
        self.energy -= random.randint(5,15)
        if self.energy <= 0:
            self.energy = random.randint(20,50)
            print(f"{self.name} takes a weird energy nap...")

    def sing(self):
        song = random.choice([
            "🎵 Hop hop hooray!", 
            "🎶 Bounce to the moon!", 
            "🎵 Water is life!", 
            "🎶 Grab a T-shirt!", 
            "🎵 Kangaroo shuffle!"])
        print(f"{self.name} sings: {song}")

    def remind_hydration(self):
        if random.random() < 0.3:
            print(f"{self.name} reminds you: Drink water 💧")

    def offer_shirt(self):
        if random.random() < 0.2:
            size = random.choice(['S','M','L','XL'])
            print(f"{self.name} offers you a T-shirt! Size: {size} 👕")

    def __str__(self):
        trail = "🦘"*min(self.position,10)
        return f"{self.name} | Pos:{self.position} | Energy:{self.energy} | Mood:{self.mood} | {trail}"

kangaroos = [Kangaroo(name) for name in ["Boomer","Skip","Ziggy","Twist","Flip"]]

print("Welcome to the Full Chaos Kangaroo Simulator!")

while True:
    for k in kangaroos:
        k.jump()
        k.sing()
        k.remind_hydration()
        k.offer_shirt()
        print(k)
    print()
    time.sleep(0.5)