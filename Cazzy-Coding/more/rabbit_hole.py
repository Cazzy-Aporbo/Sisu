import random
import math
import time
import string

def random_rabbit_hole():
    choice = random.randint(0, 5)
    if choice == 0:
        text = ''.join(random.choices(string.ascii_letters + string.punctuation, k=random.randint(5,20)))
        print(f"Echo Chamber: {text}")
    elif choice == 1:
        x = random.uniform(-1000, 1000)
        y = random.uniform(-1000, 1000)
        z = math.sin(x**2 + y**2)
        print(f"Quantum Bounce: {x:.2f}, {y:.2f}, z={z:.4f}")
    elif choice == 2:
        mood = random.choice(['elated','anxious','curious','melancholy','euphoric'])
        num = random.randint(1,10)
        print(f"Mood Swarm x{num}: " + ', '.join([mood]*num))
    elif choice == 3:
        colors = ['red','green','blue','purple','yellow','cyan','magenta']
        pattern = ''.join(random.choices(colors, k=random.randint(3,7)))
        print(f"Color Fractals: {pattern}")
    elif choice == 4:
        primes = [i for i in range(2, random.randint(10,50)) if all(i%j!=0 for j in range(2,int(i**0.5)+1))]
        random.shuffle(primes)
        print(f"Prime Shuffle: {primes}")
    else:
        seq = [random.randint(-100,100) for _ in range(random.randint(3,8))]
        transformed = [math.tanh(n)*random.random() for n in seq]
        print(f"Hyper Weird Seq: {transformed}")

while True:
    random_rabbit_hole()
    time.sleep(0.3)