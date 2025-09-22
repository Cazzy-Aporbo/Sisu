import math
import time

def is_prime_verbose(n):
    """
    Determine if n is prime with full proof steps.
    Returns (is_prime, steps)
    """
    steps = []
    if n < 2:
        steps.append(f"{n} is less than 2 → not prime.")
        return False, steps
    
    steps.append(f"Checking divisors from 2 up to √{n} ≈ {int(math.isqrt(n))}")
    for i in range(2, int(math.isqrt(n)) + 1):
        if n % i == 0:
            steps.append(f"{i} divides {n} exactly → not prime")
            return False, steps
        else:
            steps.append(f"{i} does not divide {n}")
    steps.append(f"No divisors found → {n} is prime")
    return True, steps

def prime_lab_proof(limit, delay=0.0):
    """
    Step-by-step prime discovery and proof.
    """
    previous_prime = None
    for n in range(2, limit + 1):
        prime, steps = is_prime_verbose(n)
        print(f"\n=== Evaluating {n} ===")
        for s in steps:
            print(s)
        if prime:
            gap = n - previous_prime if previous_prime else None
            if gap:
                print(f"Result: {n} is prime | Gap since last prime: {gap}")
            else:
                print(f"Result: {n} is prime (first discovered prime)")
            previous_prime = n
        else:
            print(f"Result: {n} is not prime")
        if delay > 0:
            time.sleep(delay)

def entropy_demo(limit):
    """
    Demonstrates the irregularity of prime gaps.
    """
    primes = []
    for n in range(2, limit + 1):
        prime, _ = is_prime_verbose(n)
        if prime:
            primes.append(n)
    gaps = [primes[i+1] - primes[i] for i in range(len(primes)-1)]
    print("\nPrime gaps (showing first 20 gaps):")
    for i, g in enumerate(gaps[:20]):
        print(f"Gap {i+1}: {g}")
    print("\nNotice the irregularity of gaps — primes do not follow a simple predictable pattern.")

# --- Main ---
if __name__ == "__main__":
    N = 30  # small for clarity
    print(f"--- PrimeLab: Step-by-Step Discovery up to {N} ---")
    prime_lab_proof(N, delay=0)
    entropy_demo(N)