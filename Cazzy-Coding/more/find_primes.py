import math
import time

def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(math.isqrt(n)) + 1):
        if n % i == 0:
            return False
    return True

def prime_lab(limit, delay=0.05):
    """
    Simulate the discovery of primes along a timeline.
    """
    previous_prime = None
    for n in range(2, limit + 1):
        if is_prime(n):
            gap = n - previous_prime if previous_prime else None
            print(f"Discovered prime: {n}", end='')
            if gap:
                print(f" | Gap since last prime: {gap}")
            else:
                print()
            previous_prime = n
        if delay > 0:
            time.sleep(delay)

def entropy_demo(limit):
    """
    Show unpredictability: highlight gaps and irregularity in prime distribution.
    """
    gaps = []
    previous_prime = None
    for n in range(2, limit + 1):
        if is_prime(n):
            if previous_prime:
                gaps.append(n - previous_prime)
            previous_prime = n
    print("\nPrime Gaps:")
    for i, g in enumerate(gaps[:20]):
        print(f"Gap {i+1}: {g}")
    print("Notice the irregularity and unpredictability of prime gaps.")

if __name__ == "__main__":
    N = 200
    print(f"--- PrimeLab Simulation up to {N} ---\n")
    prime_lab(N, delay=0)
    entropy_demo(N)