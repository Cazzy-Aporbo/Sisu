import random
import math

def quantum_calculate(expr):
    try:
        base = eval(expr)
    except:
        base = random.randint(-100,100)
    
    # Twist it
    twist = base * random.uniform(0.5,1.5)
    noise = math.sin(twist*random.random()) * random.randint(-10,10)
    
    # Add prime chaos
    primes = [i for i in range(2, random.randint(5,50)) if all(i%j!=0 for j in range(2,int(i**0.5)+1))]
    prime_sum = sum(primes)
    
    # Mood overlay
    mood = random.choice(['elated','anxious','curious','melancholy','euphoric','confused'])
    
    return f"Input:{expr} | Base:{base:.2f} | Twist:{twist:.2f} | Noise:{noise:.2f} | PrimeSum:{prime_sum} | Mood:{mood}"

while True:
    expr = input("Enter number or expression: ")
    print(quantum_calculate(expr))