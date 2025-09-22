import random
import time

class Creature:
    def __init__(self, name, species):
        self.name = name
        self.species = species
        self.energy = random.randint(50,100)
        self.happiness = random.randint(40,100)
        self.position = random.randint(0,10)
        self.wallet = 0  # tiny money-making ability
    
    def move(self):
        distance = random.randint(1, self.energy//10 + 1)
        self.position += distance
        self.energy -= random.randint(3,10)
        print(f"{self.name} the {self.species} moves {distance} steps! 🐾")

    def act(self):
        action_type = random.choice(['happy','sad','chaotic','trade'])
        if action_type == 'happy':
            self.happiness += random.randint(1,5)
            print(f"{self.name} smiles brightly! 😄 Happiness +{self.happiness}")
        elif action_type == 'sad':
            self.happiness -= random.randint(1,5)
            print(f"{self.name} sulks... 😞 Happiness {self.happiness}")
        elif action_type == 'chaotic':
            jump = random.randint(-2,5)
            self.position += jump
            self.energy -= random.randint(1,5)
            print(f"{self.name} goes chaotic and moves {jump} steps! ⚡")
        elif action_type == 'trade':
            earn = random.randint(1,10)
            self.wallet += earn
            print(f"{self.name} trades an item and earns {earn} coins! 💰 Total: {self.wallet}")
        
        # tiny novel mutation: 1% chance to swap species
        if random.random() < 0.01:
            old_species = self.species
            self.species = random.choice(['Happy Panda','Sad Panda','Jumping Kangaroo'])
            print(f"{self.name} transforms from {old_species} into {self.species}! 🌀")

    def __str__(self):
        trail = "🐾" * min(self.position,10)
        return f"{self.name} | {self.species} | Pos:{self.position} | Energy:{self.energy} | Happiness:{self.happiness} | Wallet:{self.wallet} | {trail}"

# initialize creatures
creatures = [Creature(name, species) for name, species in
             [("Momo","Happy Panda"),("Bunbun","Sad Panda"),("Flip","Jumping Kangaroo"),
              ("Lulu","Happy Panda"),("Ziggy","Jumping Kangaroo")]]

print("Welcome to the Multi-Species Chaos Simulator!")

while True:
    for c in creatures:
        c.move()
        c.act()
        print(c)
    print()
    time.sleep(0.5)