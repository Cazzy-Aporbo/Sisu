import random
import time

class Kangaroo:
    def __init__(self, name):
        self.name = name
        self.position = 0
        self.energy = random.randint(50,100)
    
    def jump(self):
        distance = random.randint(1, self.energy//10 + 1)
        self.position += distance
        self.energy -= random.randint(5,15)
        if self.energy <= 0:
            self.energy = random.randint(20,50)
            print(f"{self.name} takes a weird energy nap...")

    def __str__(self):
        return f"{self.name} | Pos:{self.position} | Energy:{self.energy} | " + "🦘"*min(self.position,10)

kangaroos = [Kangaroo(name) for name in ["Boomer","Skip","Ziggy","Twist","Flip"]]

print("Welcome to the Jumping Kangaroo Chaos Simulator!")

while True:
    for k in kangaroos:
        k.jump()
        print(k)
    print("-"*40)
    time.sleep(0.4)