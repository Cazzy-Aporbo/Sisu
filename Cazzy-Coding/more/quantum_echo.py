import random
import math
import time
import string

def quantum_echo():
    depth = random.randint(1,5)
    for _ in range(depth):
        phrase = ''.join(random.choices(string.ascii_letters + string.punctuation, k=random.randint(3,15)))
        x = random.uniform(-500,500)
        y = random.uniform(-500,500)
        z = math.sin(x**2 + y**2) * random.random()
        mood = random.choice(['elated','anxious','curious','melancholy','euphoric'])
        primes = [i for i in range(2, random.randint(5,30)) if all(i%j!=0 for j in range(2,int(i**0.5)+1))]
        colors = random.choices(['red','green','blue','yellow','purple','cyan','magenta'], k=random.randint(2,6))
        sequence = [math.tanh(n)*random.random() for n in [random.randint(-100,100) for _ in range(random.randint(3,8))]]
        print(f"[{phrase}] | Mood:{mood*random.randint(1,3)} | z={z:.4f} | Colors:{colors} | Primes:{primes} | Seq:{sequence}")
        time.sleep(0.2)

while True:
    quantum_echo()