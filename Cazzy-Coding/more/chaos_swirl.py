import random
import math
import time
import string

def chaos_swirl():
    iterations = random.randint(2,6)
    for _ in range(iterations):
        # Random fractal-like text
        text = ''.join(random.choices(string.ascii_letters + string.punctuation + string.digits, k=random.randint(5,25)))
        # Nested random math
        a, b = random.uniform(-1000,1000), random.uniform(-1000,1000)
        c = math.sin(a**2 - b**2) * math.cos(a*b) + random.random()
        # Mood cluster explosion
        moods = ['elated','anxious','curious','melancholy','euphoric','confused','serene']
        mood_pattern = ''.join([random.choice(moods)[0] for _ in range(random.randint(3,10))])
        # Prime chaos
        primes = [i for i in range(2, random.randint(10,60)) if all(i%j!=0 for j in range(2,int(i**0.5)+1))]
        random.shuffle(primes)
        # Color fractal
        colors = [random.choice(['red','green','blue','yellow','purple','cyan','magenta','orange','pink']) for _ in range(random.randint(2,8))]
        # Sequence mutation
        seq = [math.tanh(n)*random.random()*random.choice([-1,1]) for n in [random.randint(-200,200) for _ in range(random.randint(4,10))]]
        # Self-referential chaos
        meta = f"{text[::-1]}_{''.join(random.choices(string.ascii_letters, k=random.randint(3,7)))}"

        print(f"[{meta}] | z={c:.4f} | Mood:{mood_pattern} | Colors:{colors} | Primes:{primes} | Seq:{seq}")
        time.sleep(0.15)

while True:
    chaos_swirl()