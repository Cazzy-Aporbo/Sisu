#!/usr/bin/env python3
"""
Stochastic Calculator
A mathematical exploration tool that introduces controlled randomness,
quantum mechanical principles, and chaos theory into numerical computations.
Author: Cazandra Aporbo
"""

import random
import math
import cmath
import numpy as np
from typing import Tuple, Dict, List, Optional, Union, Any
from dataclasses import dataclass
from collections import deque
from functools import lru_cache
import hashlib
import struct
import time
import sys
import os

try:
    from scipy import special
    from scipy import stats
    from scipy.constants import physical_constants
    SCIPY_AVAILABLE = True
except ImportError:
    SCIPY_AVAILABLE = False


@dataclass
class QuantumState:
    """Represents a quantum-like state with amplitude and phase."""
    amplitude: float
    phase: float
    coherence: float
    entanglement: float
    
    def collapse(self) -> float:
        """Collapse the quantum state to a classical value."""
        return self.amplitude * math.cos(self.phase) * self.coherence


class ChaoticSystem:
    """Implements various chaotic mathematical systems."""
    
    def __init__(self, seed: Optional[int] = None):
        self.rng = random.Random(seed)
        self.history = deque(maxlen=100)
        self.lyapunov_sum = 0.0
        self.iterations = 0
        
    def lorenz_attractor(self, x: float, y: float, z: float, 
                        sigma: float = 10.0, rho: float = 28.0, beta: float = 8/3) -> Tuple[float, float, float]:
        """Calculate next step in Lorenz attractor system."""
        dt = 0.01
        dx = sigma * (y - x) * dt
        dy = (x * (rho - z) - y) * dt
        dz = (x * y - beta * z) * dt
        return x + dx, y + dy, z + dz
    
    def henon_map(self, x: float, y: float, a: float = 1.4, b: float = 0.3) -> Tuple[float, float]:
        """Apply Henon map transformation."""
        x_new = 1 - a * x * x + y
        y_new = b * x
        return x_new, y_new
    
    def logistic_map(self, x: float, r: float = 3.9) -> float:
        """Apply logistic map (exhibits chaos for r > 3.57)."""
        return r * x * (1 - x)
    
    def feigenbaum_constant(self, iterations: int = 10) -> float:
        """Approximate Feigenbaum constant through period-doubling."""
        delta = 4.669201609
        r = 2.0
        for i in range(iterations):
            r = r + (r - 2.0) / delta
        return r


class PrimeFieldOperations:
    """Operations in finite fields defined by prime numbers."""
    
    def __init__(self):
        self.prime_cache = self._sieve_of_eratosthenes(10000)
        
    def _sieve_of_eratosthenes(self, limit: int) -> List[int]:
        """Generate primes using optimized sieve."""
        if limit < 2:
            return []
        
        sieve = [True] * (limit + 1)
        sieve[0] = sieve[1] = False
        
        for i in range(2, int(limit**0.5) + 1):
            if sieve[i]:
                for j in range(i*i, limit + 1, i):
                    sieve[j] = False
                    
        return [i for i, is_prime in enumerate(sieve) if is_prime]
    
    def closest_prime(self, n: float) -> int:
        """Find the closest prime to a given number."""
        n = abs(int(n))
        if n < 2:
            return 2
            
        for prime in self.prime_cache:
            if prime >= n:
                if prime == n:
                    return prime
                prev_idx = self.prime_cache.index(prime) - 1
                if prev_idx >= 0:
                    prev_prime = self.prime_cache[prev_idx]
                    if abs(n - prev_prime) < abs(n - prime):
                        return prev_prime
                return prime
                
        return self.prime_cache[-1]
    
    def prime_factorization(self, n: int) -> Dict[int, int]:
        """Return prime factorization as dict of prime: exponent."""
        n = abs(n)
        if n <= 1:
            return {}
            
        factors = {}
        for prime in self.prime_cache:
            if prime * prime > n:
                break
            while n % prime == 0:
                factors[prime] = factors.get(prime, 0) + 1
                n //= prime
                
        if n > 1:
            factors[n] = 1
            
        return factors
    
    def modular_exponentiation(self, base: int, exp: int, mod: int) -> int:
        """Compute (base^exp) mod mod efficiently."""
        if mod == 1:
            return 0
            
        result = 1
        base = base % mod
        
        while exp > 0:
            if exp % 2 == 1:
                result = (result * base) % mod
            exp = exp >> 1
            base = (base * base) % mod
            
        return result


class WaveFunctionCalculator:
    """Quantum mechanical wave function operations."""
    
    def __init__(self):
        self.planck = 6.62607015e-34  # Planck constant
        self.hbar = self.planck / (2 * math.pi)
        
    def particle_in_box(self, n: int, L: float, x: float) -> complex:
        """Calculate wave function for particle in 1D box."""
        if n < 1:
            n = 1
        k = n * math.pi / L
        amplitude = math.sqrt(2 / L)
        return amplitude * cmath.exp(1j * k * x)
    
    def gaussian_wave_packet(self, x: float, x0: float, sigma: float, k0: float) -> complex:
        """Calculate Gaussian wave packet."""
        norm = (2 * math.pi * sigma**2) ** (-0.25)
        gaussian = cmath.exp(-(x - x0)**2 / (4 * sigma**2))
        plane_wave = cmath.exp(1j * k0 * x)
        return norm * gaussian * plane_wave
    
    def quantum_tunneling_probability(self, E: float, V0: float, width: float, mass: float = 9.109e-31) -> float:
        """Calculate tunneling probability through rectangular barrier."""
        if E >= V0:
            return 1.0
            
        kappa = math.sqrt(2 * mass * (V0 - E)) / self.hbar
        T = 1 / (1 + (V0**2 * math.sinh(kappa * width)**2) / (4 * E * (V0 - E)))
        return T


class StochasticResonance:
    """Implements stochastic resonance phenomena."""
    
    def __init__(self, noise_level: float = 0.1):
        self.noise_level = noise_level
        self.signal_history = deque(maxlen=1000)
        
    def bistable_potential(self, x: float, a: float = 1.0, b: float = 1.0) -> float:
        """Double-well potential function."""
        return -a * x**2 / 2 + b * x**4 / 4
    
    def add_colored_noise(self, signal: float, color: str = 'white') -> float:
        """Add different types of noise to signal."""
        if color == 'white':
            return signal + random.gauss(0, self.noise_level)
        elif color == 'pink':
            # 1/f noise approximation
            return signal + self.noise_level * sum(random.gauss(0, 1/f) for f in range(1, 10))
        elif color == 'brown':
            # Brownian noise (integrated white noise)
            if self.signal_history:
                prev = self.signal_history[-1]
                return prev + random.gauss(0, self.noise_level)
            return signal + random.gauss(0, self.noise_level)
        else:
            return signal
    
    def detect_resonance(self, signal: float, noise: float, threshold: float = 0.0) -> bool:
        """Detect if stochastic resonance improves signal detection."""
        noisy_signal = signal + noise
        self.signal_history.append(noisy_signal)
        
        if len(self.signal_history) < 10:
            return False
            
        snr_without = abs(signal) / (abs(noise) + 1e-10)
        snr_with = abs(noisy_signal) / (np.std(list(self.signal_history)) + 1e-10)
        
        return snr_with > snr_without


class FractalGenerator:
    """Generate fractal-based transformations."""
    
    def mandelbrot_iteration(self, c: complex, max_iter: int = 100) -> int:
        """Calculate Mandelbrot set membership."""
        z = 0
        for n in range(max_iter):
            if abs(z) > 2:
                return n
            z = z*z + c
        return max_iter
    
    def julia_set(self, z: complex, c: complex, max_iter: int = 100) -> int:
        """Calculate Julia set membership."""
        for n in range(max_iter):
            if abs(z) > 2:
                return n
            z = z*z + c
        return max_iter
    
    def sierpinski_transform(self, x: float, y: float, iteration: int) -> Tuple[float, float]:
        """Apply Sierpinski triangle transformation."""
        for _ in range(iteration):
            r = random.randint(0, 2)
            if r == 0:
                x, y = x / 2, y / 2
            elif r == 1:
                x, y = (x + 1) / 2, y / 2
            else:
                x, y = x / 2, (y + 1) / 2
        return x, y


class CryptoHash:
    """Cryptographic hash-based transformations."""
    
    @staticmethod
    def numeric_hash(value: float, algorithm: str = 'sha256') -> int:
        """Convert number to hash-based integer."""
        bytes_val = struct.pack('d', value)
        
        if algorithm == 'sha256':
            h = hashlib.sha256(bytes_val).hexdigest()
        elif algorithm == 'blake2b':
            h = hashlib.blake2b(bytes_val).hexdigest()
        else:
            h = hashlib.md5(bytes_val).hexdigest()
            
        return int(h, 16)
    
    @staticmethod
    def avalanche_effect(value: float, epsilon: float = 1e-10) -> float:
        """Demonstrate avalanche effect in hashing."""
        h1 = CryptoHash.numeric_hash(value)
        h2 = CryptoHash.numeric_hash(value + epsilon)
        
        bits_changed = bin(h1 ^ h2).count('1')
        total_bits = 256
        
        return bits_changed / total_bits


class QuantumCalculator:
    """Main calculator integrating all quantum-inspired operations."""
    
    def __init__(self):
        self.chaos = ChaoticSystem()
        self.primes = PrimeFieldOperations()
        self.wave = WaveFunctionCalculator()
        self.resonance = StochasticResonance()
        self.fractal = FractalGenerator()
        self.crypto = CryptoHash()
        
        self.emotional_states = {
            'serene': lambda x: x * 1.0,
            'turbulent': lambda x: x * random.uniform(0.5, 2.0),
            'oscillating': lambda x: x * math.sin(time.time()),
            'exponential': lambda x: x * math.exp(random.uniform(-1, 1)),
            'logarithmic': lambda x: x * math.log(abs(x) + 1),
            'harmonic': lambda x: x / sum(1/i for i in range(1, 10)),
            'fibonacci': lambda x: x * (1.618033988749895),  # Golden ratio
            'entropic': lambda x: x * random.uniform(-2, 2)
        }
        
        self.calculation_history = deque(maxlen=1000)
        self.entropy_pool = 0.0
        
    def safe_eval(self, expr: str) -> float:
        """Safely evaluate mathematical expressions."""
        allowed_names = {
            'sin': math.sin, 'cos': math.cos, 'tan': math.tan,
            'exp': math.exp, 'log': math.log, 'sqrt': math.sqrt,
            'pi': math.pi, 'e': math.e, 'tau': math.tau,
            'abs': abs, 'round': round, 'int': int, 'float': float
        }
        
        try:
            code = compile(expr, '<string>', 'eval')
            for name in code.co_names:
                if name not in allowed_names:
                    raise NameError(f"Use of {name} not allowed")
            return eval(code, {"__builtins__": {}}, allowed_names)
        except:
            return random.uniform(-100, 100)
    
    def calculate(self, expr: str) -> Dict[str, Any]:
        """Perform quantum-inspired calculation."""
        
        # Base calculation
        base_value = self.safe_eval(expr)
        
        # Chaotic transformation
        x, y, z = base_value, base_value * 0.5, base_value * 0.25
        for _ in range(10):
            x, y, z = self.chaos.lorenz_attractor(x, y, z)
        chaotic_value = x
        
        # Prime field operation
        closest_prime = self.primes.closest_prime(abs(base_value))
        prime_factors = self.primes.prime_factorization(abs(int(base_value)) if base_value != 0 else 1)
        prime_transform = sum(p * e for p, e in prime_factors.items()) if prime_factors else closest_prime
        
        # Quantum state
        quantum = QuantumState(
            amplitude=abs(base_value),
            phase=math.atan2(base_value, 1),
            coherence=random.uniform(0.7, 1.0),
            entanglement=random.uniform(0, 1)
        )
        quantum_value = quantum.collapse()
        
        # Wave function
        wave_value = self.wave.particle_in_box(
            n=max(1, abs(int(base_value)) % 10),
            L=10.0,
            x=base_value % 10
        )
        
        # Stochastic resonance
        noise = random.gauss(0, 0.1)
        resonant_value = self.resonance.add_colored_noise(base_value, 'pink')
        
        # Fractal dimension
        fractal_c = complex(base_value * 0.1, base_value * 0.05)
        mandelbrot_iter = self.fractal.mandelbrot_iteration(fractal_c)
        
        # Cryptographic transform
        hash_value = self.crypto.numeric_hash(base_value) % 1000
        avalanche = self.crypto.avalanche_effect(base_value)
        
        # Emotional modulation
        emotion = random.choice(list(self.emotional_states.keys()))
        emotional_value = self.emotional_states[emotion](base_value)
        
        # Entropy accumulation
        self.entropy_pool += abs(chaotic_value - base_value)
        self.entropy_pool = self.entropy_pool % 1000
        
        # Historical influence
        if self.calculation_history:
            historical_avg = np.mean([h['base'] for h in list(self.calculation_history)[-10:]])
            historical_influence = (base_value + historical_avg) / 2
        else:
            historical_influence = base_value
        
        # Combine all influences
        if SCIPY_AVAILABLE:
            # Use special functions if available
            bessel_mod = special.jv(1, base_value / 10)
            gamma_mod = special.gamma(min(abs(base_value) / 10, 50))
            final_value = (quantum_value + chaotic_value + resonant_value) / 3
            final_value *= (1 + bessel_mod * 0.1)
            final_value *= (1 + math.log(gamma_mod + 1) * 0.01)
        else:
            final_value = (quantum_value + chaotic_value + resonant_value + emotional_value) / 4
        
        result = {
            'input': expr,
            'base': round(base_value, 6),
            'chaotic': round(chaotic_value, 6),
            'quantum': round(quantum_value, 6),
            'wave_real': round(wave_value.real, 6),
            'wave_imag': round(wave_value.imag, 6),
            'resonant': round(resonant_value, 6),
            'prime': closest_prime,
            'prime_factors': prime_factors,
            'mandelbrot': mandelbrot_iter,
            'hash_mod': hash_value,
            'avalanche': round(avalanche, 4),
            'emotion': emotion,
            'emotional': round(emotional_value, 6),
            'entropy': round(self.entropy_pool, 3),
            'historical': round(historical_influence, 6),
            'final': round(final_value, 6)
        }
        
        self.calculation_history.append(result)
        return result
    
    def format_output(self, result: Dict[str, Any]) -> str:
        """Format calculation results for display."""
        lines = [
            f"Expression: {result['input']}",
            f"Classical: {result['base']}",
            f"Chaotic (Lorenz): {result['chaotic']}",
            f"Quantum Collapse: {result['quantum']}",
            f"Wave Function: {result['wave_real']} + {result['wave_imag']}i",
            f"Stochastic Resonance: {result['resonant']}",
            f"Prime Nearest: {result['prime']}",
            f"Prime Factors: {result['prime_factors'] if result['prime_factors'] else 'None'}",
            f"Mandelbrot Iterations: {result['mandelbrot']}",
            f"Hash Modulo: {result['hash_mod']}",
            f"Avalanche Effect: {result['avalanche'] * 100:.2f}%",
            f"Emotional State: {result['emotion']} -> {result['emotional']}",
            f"Entropy Pool: {result['entropy']}",
            f"Historical Influence: {result['historical']}",
            f"Final Synthesis: {result['final']}"
        ]
        return '\n'.join(lines)


def run_interactive_mode():
    """Run the calculator in interactive mode."""
    
    calc = QuantumCalculator()
    
    print("Quantum-Inspired Stochastic Calculator")
    print("Enter mathematical expressions or 'quit' to exit")
    print("Supports: basic arithmetic, sin, cos, tan, exp, log, sqrt, pi, e")
    print("-" * 60)
    
    while True:
        try:
            expr = input("\nExpression: ").strip()
            
            if expr.lower() in ['quit', 'exit', 'q']:
                print("Shutting down quantum coherence...")
                break
            
            if expr.lower() == 'history':
                if calc.calculation_history:
                    print("\nRecent calculations:")
                    for h in list(calc.calculation_history)[-5:]:
                        print(f"  {h['input']} -> {h['final']}")
                else:
                    print("No calculation history yet")
                continue
            
            if expr.lower() == 'entropy':
                print(f"Current entropy pool: {calc.entropy_pool:.3f}")
                continue
            
            result = calc.calculate(expr)
            print("\n" + calc.format_output(result))
            
        except KeyboardInterrupt:
            print("\nQuantum decoherence detected. Exiting...")
            break
        except Exception as e:
            print(f"Calculation collapsed: {e}")
            continue


def run_batch_mode(expressions: List[str]):
    """Process multiple expressions in batch mode."""
    
    calc = QuantumCalculator()
    results = []
    
    for expr in expressions:
        result = calc.calculate(expr)
        results.append(result)
        print(f"\n{expr} -> Final: {result['final']}")
    
    print("\nBatch Statistics:")
    finals = [r['final'] for r in results]
    print(f"  Mean: {np.mean(finals):.6f}")
    print(f"  Std Dev: {np.std(finals):.6f}")
    print(f"  Entropy Generated: {calc.entropy_pool:.3f}")
    
    return results


if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Batch mode with command line arguments
        expressions = sys.argv[1:]
        run_batch_mode(expressions)
    else:
        # Interactive mode
        run_interactive_mode()
