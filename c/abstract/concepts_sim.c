/*
 * QUANTUM SIMULATION: A program that explores quantum mechanics concepts
 * through computational metaphors, demonstrating superposition, entanglement,
 * and the observer effect in a classical computing environment.
 *
 * This implementation simulates:
 * 1. Quantum bits (qubits) that can exist in superposition
 * 2. Quantum entanglement between particles
 * 3. The observer effect where measurement collapses superpositions
 * 4. Quantum gates that manipulate qubit states
 * 5. Quantum randomness and probability amplitudes
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <complex.h>

/*
 * CONCEPT: QUANTUM SUPERPOSITION
 * A qubit can be in a state |0⟩, |1⟩, or any linear combination (superposition)
 * of these states. We represent this using complex probability amplitudes.
 */
typedef struct {
    double complex alpha;  // Probability amplitude for |0⟩
    double complex beta;   // Probability amplitude for |1⟩
    int collapsed;         // Whether the state has been measured
    int value;             // Classical value after measurement
} Qubit;

/*
 * CONCEPT: QUANTUM ENTANGLEMENT
 * Multiple qubits can be entangled, meaning their states are correlated
 * regardless of distance. Measuring one instantly affects the others.
 */
typedef struct {
    Qubit *qubits;        // Array of entangled qubits
    int num_qubits;       // Number of qubits in the system
    int *entanglement_map;// Description of entanglement correlations
} EntangledSystem;

/*
 * CONCEPT: QUANTUM GATES
 * Operations that modify qubit states while preserving quantum properties.
 * These gates form the building blocks of quantum algorithms.
 */

// Hadamard gate: Creates superposition from classical states
void hadamard_gate(Qubit *q) {
    if (q->collapsed) {
        printf("Cannot apply quantum gate to collapsed qubit!\n");
        return;
    }
    
    // H|0⟩ = (|0⟩ + |1⟩)/√2
    // H|1⟩ = (|0⟩ - |1⟩)/√2
    double complex new_alpha = (q->alpha + q->beta) / sqrt(2);
    double complex new_beta = (q->alpha - q->beta) / sqrt(2);
    
    q->alpha = new_alpha;
    q->beta = new_beta;
}

// Pauli-X gate: Quantum equivalent of NOT gate
void pauli_x_gate(Qubit *q) {
    if (q->collapsed) {
        printf("Cannot apply quantum gate to collapsed qubit!\n");
        return;
    }
    
    // X|0⟩ = |1⟩, X|1⟩ = |0⟩
    double complex temp = q->alpha;
    q->alpha = q->beta;
    q->beta = temp;
}

// CNOT gate: Entangles two qubits (controlled-NOT)
void cnot_gate(Qubit *control, Qubit *target) {
    if (control->collapsed || target->collapsed) {
        printf("Cannot apply quantum gate to collapsed qubits!\n");
        return;
    }
    
    // CNOT flips target if control is |1⟩
    // In simulation, we need to handle the probability amplitudes
    // This is a simplified implementation for demonstration
    double complex temp_alpha = target->alpha;
    double complex temp_beta = target->beta;
    
    // The actual effect depends on the control qubit's state
    // For demonstration, we'll simulate the entanglement
    target->alpha = (control->alpha * temp_alpha + control->beta * temp_beta) / sqrt(2);
    target->beta = (control->alpha * temp_beta + control->beta * temp_alpha) / sqrt(2);
}

/*
 * CONCEPT: WAVE FUNCTION COLLAPSE
 * When a qubit is measured, its superposition collapses to a definite
 * state (0 or 1) with probabilities determined by the probability amplitudes.
 */
int measure_qubit(Qubit *q) {
    if (q->collapsed) {
        return q->value;  // Already measured
    }
    
    // Calculate probabilities
    double prob0 = creal(q->alpha * conj(q->alpha));
    double prob1 = creal(q->beta * conj(q->beta));
    
    // Normalize probabilities (should sum to 1 in valid states)
    double total = prob0 + prob1;
    if (total > 0) {
        prob0 /= total;
        prob1 /= total;
    }
    
    // "Collapse" the wave function based on probability
    double random_value = (double)rand() / RAND_MAX;
    if (random_value < prob0) {
        q->value = 0;
        q->alpha = 1.0 + 0.0*I;
        q->beta = 0.0 + 0.0*I;
    } else {
        q->value = 1;
        q->alpha = 0.0 + 0.0*I;
        q->beta = 1.0 + 0.0*I;
    }
    
    q->collapsed = 1;
    return q->value;
}

/*
 * CONCEPT: QUANTUM ENTANGLEMENT CREATION
 * Creating entangled particles (like Bell states) that show
 * perfect correlation when measured.
 */
void create_bell_state(EntangledSystem *system) {
    if (system->num_qubits < 2) {
        printf("Need at least 2 qubits for entanglement!\n");
        return;
    }
    
    // Initialize qubits to |0⟩
    for (int i = 0; i < system->num_qubits; i++) {
        system->qubits[i].alpha = 1.0 + 0.0*I;
        system->qubits[i].beta = 0.0 + 0.0*I;
        system->qubits[i].collapsed = 0;
    }
    
    // Apply Hadamard to first qubit
    hadamard_gate(&system->qubits[0]);
    
    // Apply CNOT between first and second qubit
    cnot_gate(&system->qubits[0], &system->qubits[1]);
    
    // For more qubits, create more complex entanglement
    if (system->num_qubits > 2) {
        for (int i = 2; i < system->num_qubits; i++) {
            cnot_gate(&system->qubits[0], &system->qubits[i]);
        }
    }
    
    printf("Created entangled quantum system with %d qubits\n", system->num_qubits);
}

/*
 * CONCEPT: QUANTUM OBSERVER EFFECT
 * The act of measurement affects the quantum system being observed.
 * We simulate how measuring one part of an entangled system affects others.
 */
void demonstrate_observer_effect(EntangledSystem *system) {
    printf("\n=== DEMONSTRATING OBSERVER EFFECT ===\n");
    
    // Create an entangled pair
    create_bell_state(system);
    
    printf("Before measurement: Qubits are in superposition\n");
    printf("Probability amplitudes:\n");
    for (int i = 0; i < system->num_qubits; i++) {
        printf("Qubit %d: |0⟩: %.2f, |1⟩: %.2f\n", 
               i, creal(system->qubits[i].alpha * conj(system->qubits[i].alpha)),
               creal(system->qubits[i].beta * conj(system->qubits[i].beta)));
    }
    
    // Measure one qubit - this should instantly affect the others
    printf("\nMeasuring qubit 0...\n");
    int result = measure_qubit(&system->qubits[0]);
    printf("Qubit 0 collapsed to: %d\n", result);
    
    printf("\nAfter measurement:\n");
    for (int i = 0; i < system->num_qubits; i++) {
        if (system->qubits[i].collapsed) {
            printf("Qubit %d collapsed to: %d\n", i, system->qubits[i].value);
        } else {
            // Other qubits should be affected due to entanglement
            printf("Qubit %d now has probabilities: |0⟩: %.2f, |1⟩: %.2f\n", 
                   i, creal(system->qubits[i].alpha * conj(system->qubits[i].alpha)),
                   creal(system->qubits[i].beta * conj(system->qubits[i].beta)));
        }
    }
    
    // Demonstrate perfect correlation in Bell states
    if (system->num_qubits >= 2) {
        printf("\nQuantum entanglement correlation:\n");
        printf("Qubit 0 and Qubit 1 should have the same value when measured.\n");
        if (!system->qubits[1].collapsed) {
            int result1 = measure_qubit(&system->qubits[1]);
            printf("Qubit 1 collapsed to: %d\n", result1);
            printf("Correlation: %s\n", result == result1 ? "Perfect" : "Broken");
        }
    }
}

/*
 * CONCEPT: QUANTUM PARALLELISM
 * Quantum computers can evaluate multiple possibilities simultaneously.
 * We simulate this by processing all possible states in superposition.
 */
void demonstrate_quantum_parallelism() {
    printf("\n=== DEMONSTRATING QUANTUM PARALLELISM ===\n");
    
    // Create a qubit in superposition
    Qubit q;
    q.alpha = 1.0 + 0.0*I;
    q.beta = 0.0 + 0.0*I;
    q.collapsed = 0;
    
    // Apply Hadamard to put it in superposition
    hadamard_gate(&q);
    
    printf("Qubit in superposition: simultaneously representing 0 and 1\n");
    printf("We can now perform operations on both values at once.\n");
    
    // Apply a function to both states simultaneously
    // For example, f(x) = x + 1 mod 2 (quantum version of NOT)
    pauli_x_gate(&q);
    
    printf("After applying quantum operation to both states simultaneously:\n");
    printf("Probability amplitudes: |0⟩: %.2f, |1⟩: %.2f\n",
           creal(q.alpha * conj(q.alpha)), creal(q.beta * conj(q.beta)));
    
    // Measure to see the result
    int result = measure_qubit(&q);
    printf("Measurement result: %d\n", result);
    printf("This demonstrates evaluating multiple inputs at once.\n");
}

/*
 * CONCEPT: QUANTUM TELEPORTATION PROTOCOL
 * A quantum communication protocol that transfers a quantum state
 * using entanglement and classical communication.
 */
void demonstrate_quantum_teleportation() {
    printf("\n=== DEMONSTRATING QUANTUM TELEPORTATION ===\n");
    
    // Create three qubits: one to teleport, and an entangled pair
    Qubit qubits[3];
    for (int i = 0; i < 3; i++) {
        qubits[i].alpha = 1.0 + 0.0*I;
        qubits[i].beta = 0.0 + 0.0*I;
        qubits[i].collapsed = 0;
    }
    
    // Put the first qubit into an arbitrary state to teleport
    qubits[0].alpha = 0.6 + 0.0*I;  // |0⟩ with amplitude 0.6
    qubits[0].beta = 0.8 + 0.0*I;   // |1⟩ with amplitude 0.8
    printf("Initial state to teleport: |0⟩: %.2f, |1⟩: %.2f\n",
           creal(qubits[0].alpha * conj(qubits[0].alpha)),
           creal(qubits[0].beta * conj(qubits[0].beta)));
    
    // Create entanglement between qubits 1 and 2
    EntangledSystem epr_pair;
    epr_pair.qubits = &qubits[1];
    epr_pair.num_qubits = 2;
    create_bell_state(&epr_pair);
    
    // Perform Bell measurement on qubits 0 and 1
    cnot_gate(&qubits[0], &qubits[1]);
    hadamard_gate(&qubits[0]);
    
    int measure0 = measure_qubit(&qubits[0]);
    int measure1 = measure_qubit(&qubits[1]);
    
    printf("Bell measurement results: %d, %d\n", measure0, measure1);
    
    // Based on measurement results, apply corrections to qubit 2
    if (measure1) pauli_x_gate(&qubits[2]);
    if (measure0) pauli_x_gate(&qubits[2]);  // Simplified correction
    
    printf("Teleported state: |0⟩: %.2f, |1⟩: %.2f\n",
           creal(qubits[2].alpha * conj(qubits[2].alpha)),
           creal(qubits[2].beta * conj(qubits[2].beta)));
    printf("Quantum teleportation complete!\n");
}

int main() {
    printf("=== QUANTUM SIMULATION IN C ===\n\n");
    
    // Initialize random number generator for quantum measurements
    srand(time(NULL));
    
    // Demonstrate basic quantum concepts
    demonstrate_quantum_parallelism();
    
    // Create an entangled system with 3 qubits
    EntangledSystem system;
    Qubit qubits[3];
    system.qubits = qubits;
    system.num_qubits = 3;
    
    demonstrate_observer_effect(&system);
    
    // Demonstrate quantum teleportation
    demonstrate_quantum_teleportation();
    
    printf("\n=== QUANTUM SIMULATION COMPLETE ===\n");
    printf("This simulation demonstrates key quantum computing concepts:\n");
    printf("1. Superposition: Qubits can represent multiple states at once\n");
    printf("2. Entanglement: Particles can be correlated across distance\n");
    printf("3. Observer effect: Measurement collapses quantum states\n");
    printf("4. Quantum gates: Operations that manipulate quantum states\n");
    printf("5. Quantum parallelism: Processing multiple states simultaneously\n");
    
    return 0;
}