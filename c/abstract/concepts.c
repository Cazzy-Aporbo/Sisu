/*
 * concepts.c — Exploring higher-order patterns in C
 *
 * Complex numbers with semantic payloads, function introspection,
 * and deterministic chaos. Weird things you can do in C when you
 * stop treating it as "just systems programming."
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// A complex number that carries a meaning string alongside its value.
// Why? Because sometimes data needs metadata, even at the struct level.
typedef struct {
    double real;
    double imaginary;
    char *meaning;  // Semantic payload beyond numerical representation
} OntologicalNumber;

// A transformation you can't shortcut — you have to run it to see the result.
// This is the C equivalent of "just step through it in the debugger."
void irreducible_computation(OntologicalNumber *n) {
    // This function's behavior cannot be predicted through static analysis
    // The output emerges only through execution in a specific context
    n->real = (n->real * n->imaginary) / (n->real + n->imaginary + 0.0001);
    n->imaginary = sqrt(fabs(n->real - n->imaginary));
    
    // The transformation of meaning represents computational emergence
    if (n->meaning != NULL) {
        char new_meaning[strlen(n->meaning) + 1];
        for (int i = 0; n->meaning[i] != '\0'; i++) {
            new_meaning[i] = n->meaning[i] + (i % 3) - 1;  // Semantic drift
        }
        new_meaning[strlen(n->meaning)] = '\0';
        // Note: In a real implementation, we would properly manage this memory
    }
}

// Higher-order function in C: pass a function pointer, watch what it does.
void introspective_function(void (*f)(OntologicalNumber*), OntologicalNumber *n) {
    printf("Beginning introspection on function at address %p\n", f);
    printf("Input: real=%.3f, imaginary=%.3f, meaning=%s\n", 
           n->real, n->imaginary, n->meaning);
    
    // Execute the function while maintaining awareness of the process
    f(n);
    
    printf("Post-execution state: real=%.3f, imaginary=%.3f\n", 
           n->real, n->imaginary);
    printf("Introspection complete. Computation has altered reality.\n");
}

// Extract a human-readable interpretation from a complex number's state.
char *extract_semantics(OntologicalNumber n) {
    // Allocate space for our semantic interpretation
    char *interpretation = malloc(256 * sizeof(char));
    
    // The meaning emerges from the relationship between components
    double magnitude = sqrt(n.real * n.real + n.imaginary * n.imaginary);
    double angle = atan2(n.imaginary, n.real);
    
    // Generate interpretation based on computational state
    snprintf(interpretation, 256, 
             "Magnitude: %.3f (presence), Angle: %.3f (perspective), Meaning: %s",
             magnitude, angle, n.meaning ? n.meaning : "undefined");
    
    return interpretation;
}

// Function pointer evolution — returns a modified version of its input.
// Placeholder for actual code generation (which C can do via JIT, but not here).
typedef void (*ComputationalOrganism)(OntologicalNumber*);

ComputationalOrganism evolve_computation(ComputationalOrganism parent) {
    // Create a new function that slightly varies the parent's behavior
    // This represents computational evolution
    void (*child)(OntologicalNumber*) = NULL;
    
    // In a more advanced implementation, we would actually generate
    // new machine code or use function composition
    // For this demonstration, we return a modified version
    return child ? child : parent;  // Placeholder for actual evolution
}

// Deterministic chaos: fixed seed + iterated arithmetic = unpredictable-looking output.
// Same seed always gives the same result. Chaos theory in 10 lines.
void nondeterministic_determinism(OntologicalNumber *n, unsigned int seed) {
    // Use deterministic operations that produce complex, hard-to-predict results
    srand(seed);  // Fixed seed makes it deterministic
    
    // Complex transformation that appears random but isn't
    for (int i = 0; i < 100; i++) {
        n->real = (n->real + rand() % 10 - 5) / (1.0 + fabs(n->imaginary));
        n->imaginary = (n->imaginary + rand() % 10 - 5) / (1.0 + fabs(n->real));
    }
}

int main() {
    printf("concepts.c — running\n\n");
    
    // Initialize an ontological number with semantic payload
    OntologicalNumber num = {3.0, 4.0, "initial state"};
    
    printf("Initial semantic interpretation:\n");
    char *semantics = extract_semantics(num);
    printf("%s\n\n", semantics);
    free(semantics);
    
    // Demonstrate irreducible computation
    printf("Applying irreducible computation...\n");
    introspective_function(irreducible_computation, &num);
    printf("\n");
    
    // Extract new semantics
    printf("Post-computation semantic interpretation:\n");
    semantics = extract_semantics(num);
    printf("%s\n\n", semantics);
    free(semantics);
    
    // Demonstrate non-deterministic determinism
    printf("Applying non-deterministic determinism (seed: 42)...\n");
    nondeterministic_determinism(&num, 42);
    printf("Result: real=%.3f, imaginary=%.3f\n\n", num.real, num.imaginary);
    
    printf("done.\n");
    
    return 0;
}