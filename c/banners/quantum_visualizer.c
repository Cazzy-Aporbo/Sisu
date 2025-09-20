#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <SDL2/SDL.h>
#include <complex.h>

#define WIDTH 1200
#define HEIGHT 800
#define CENTER_X (WIDTH / 2)
#define CENTER_Y (HEIGHT / 2)
#define MAX_QUBITS 8
#define MAX_STATES 256 // 2^8

// Structure for quantum state representation
typedef struct {
    double complex amplitude;
    double probability;
    int basis_state;
    int entanglement[MAX_QUBITS];
    int entangled_count;
} QuantumState;

// Structure for quantum gate operations
typedef struct {
    double complex matrix[2][2];
    char name[20];
    int target_qubit;
    int control_qubit; // For controlled gates
} QuantumGate;

// Structure for higher-dimensional projection
typedef struct {
    double projection_matrix[4][4]; // For projecting to 3D/4D
    double rotation_angles[6]; // For rotating in higher dimensions
    double scale_factors[4]; // Scaling for each dimension
} HigherDProjection;

// Global variables
SDL_Window* window = NULL;
SDL_Renderer* renderer = NULL;
int running = 1;
QuantumState states[MAX_STATES];
QuantumGate gates[10];
HigherDProjection projection;
double global_time = 0;
int num_qubits = 4;
int visualization_mode = 0;
double computation_progress = 0;
int computation_step = 0;

// Function declarations
void init_sdl();
void cleanup();
void init_quantum_system();
void update_quantum_system(double dt);
void render_quantum_system();
void handle_input();
void draw_ui();
void draw_string(const char* text, int x, int y, SDL_Color color);
void apply_quantum_gate(QuantumGate gate);
void simulate_quantum_computation();
void project_to_3d(double x, double y, double z, double w, double* out_x, double* out_y, double* out_z);
void project_to_2d(double x, double y, double z, int* out_x, int* out_y);
void color_from_state(QuantumState state, Uint8* r, Uint8* g, Uint8* b);
void create_quantum_entanglement(int state1, int state2);
void apply_higher_dim_rotation();
void draw_bloch_sphere();

int main(int argc, char* argv[]) {
    printf("Quantum Information Visualizer\n");
    printf("==============================\n");
    printf("Visualizing quantum states beyond human perception...\n");
    
    init_sdl();
    init_quantum_system();
    
    Uint32 last_time = SDL_GetTicks();
    
    // Main loop
    while (running) {
        Uint32 current_time = SDL_GetTicks();
        double dt = (current_time - last_time) / 1000.0;
        last_time = current_time;
        
        global_time += dt;
        computation_progress += dt * 0.1;
        if (computation_progress >= 1.0) {
            computation_progress = 0.0;
            computation_step = (computation_step + 1) % 10;
            simulate_quantum_computation();
        }
        
        handle_input();
        update_quantum_system(dt);
        
        // Clear screen with a dark background
        SDL_SetRenderDrawColor(renderer, 5, 5, 15, 255);
        SDL_RenderClear(renderer);
        
        // Render the quantum system
        render_quantum_system();
        
        // Draw UI
        draw_ui();
        
        // Present renderer
        SDL_RenderPresent(renderer);
        
        // Cap frame rate
        SDL_Delay(16); // ~60 FPS
    }
    
    cleanup();
    return 0;
}

void init_sdl() {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("SDL could not initialize! SDL_Error: %s\n", SDL_GetError());
        exit(1);
    }
    
    window = SDL_CreateWindow("Quantum Information Visualizer", 
                             SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 
                             WIDTH, HEIGHT, SDL_WINDOW_SHOWN);
    if (window == NULL) {
        printf("Window could not be created! SDL_Error: %s\n", SDL_GetError());
        exit(1);
    }
    
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (renderer == NULL) {
        printf("Renderer could not be created! SDL_Error: %s\n", SDL_GetError());
        exit(1);
    }
    
    // Seed random number generator
    srand(time(NULL));
}

void cleanup() {
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

void init_quantum_system() {
    // Initialize quantum states (all possible combinations of qubits)
    int num_states = 1 << num_qubits; // 2^num_qubits
    
    for (int i = 0; i < num_states; i++) {
        states[i].amplitude = (i == 0) ? 1.0 + 0.0*I : 0.0 + 0.0*I; // Start in |0...0⟩ state
        states[i].probability = cabs(states[i].amplitude) * cabs(states[i].amplitude);
        states[i].basis_state = i;
        states[i].entangled_count = 0;
    }
    
    // Initialize quantum gates
    // Hadamard gate
    gates[0].matrix[0][0] = 1.0/sqrt(2) + 0.0*I;
    gates[0].matrix[0][1] = 1.0/sqrt(2) + 0.0*I;
    gates[0].matrix[1][0] = 1.0/sqrt(2) + 0.0*I;
    gates[0].matrix[1][1] = -1.0/sqrt(2) + 0.0*I;
    strcpy(gates[0].name, "H");
    gates[0].target_qubit = 0;
    gates[0].control_qubit = -1;
    
    // Pauli-X gate (quantum NOT)
    gates[1].matrix[0][0] = 0.0 + 0.0*I;
    gates[1].matrix[0][1] = 1.0 + 0.0*I;
    gates[1].matrix[1][0] = 1.0 + 0.0*I;
    gates[1].matrix[1][1] = 0.0 + 0.0*I;
    strcpy(gates[1].name, "X");
    gates[1].target_qubit = 0;
    gates[1].control_qubit = -1;
    
    // Pauli-Y gate
    gates[2].matrix[0][0] = 0.0 + 0.0*I;
    gates[2].matrix[0][1] = 0.0 - 1.0*I;
    gates[2].matrix[1][0] = 0.0 + 1.0*I;
    gates[2].matrix[1][1] = 0.0 + 0.0*I;
    strcpy(gates[2].name, "Y");
    gates[2].target_qubit = 0;
    gates[2].control_qubit = -1;
    
    // Pauli-Z gate
    gates[3].matrix[0][0] = 1.0 + 0.0*I;
    gates[3].matrix[0][1] = 0.0 + 0.0*I;
    gates[3].matrix[1][0] = 0.0 + 0.0*I;
    gates[3].matrix[1][1] = -1.0 + 0.0*I;
    strcpy(gates[3].name, "Z");
    gates[3].target_qubit = 0;
    gates[3].control_qubit = -1;
    
    // CNOT gate (controlled-NOT)
    gates[4].matrix[0][0] = 1.0 + 0.0*I;
    gates[4].matrix[0][1] = 0.0 + 0.0*I;
    gates[4].matrix[1][0] = 0.0 + 0.0*I;
    gates[4].matrix[1][1] = 1.0 + 0.0*I;
    strcpy(gates[4].name, "CNOT");
    gates[4].target_qubit = 1;
    gates[4].control_qubit = 0;
    
    // Initialize higher-dimensional projection
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            projection.projection_matrix[i][j] = (i == j) ? 1.0 : 0.0;
        }
    }
    
    for (int i = 0; i < 6; i++) {
        projection.rotation_angles[i] = 0.0;
    }
    
    for (int i = 0; i < 4; i++) {
        projection.scale_factors[i] = 1.0;
    }
}

void update_quantum_system(double dt) {
    // Update rotation angles for higher-dimensional projection
    for (int i = 0; i < 6; i++) {
        projection.rotation_angles[i] += dt * 0.1 * (i + 1);
        if (projection.rotation_angles[i] > 2 * M_PI) {
            projection.rotation_angles[i] -= 2 * M_PI;
        }
    }
    
    // Update scale factors for a pulsating effect
    for (int i = 0; i < 4; i++) {
        projection.scale_factors[i] = 1.0 + 0.1 * sin(global_time * (i + 1));
    }
    
    // Update probabilities based on amplitudes
    int num_states = 1 << num_qubits;
    for (int i = 0; i < num_states; i++) {
        states[i].probability = cabs(states[i].amplitude) * cabs(states[i].amplitude);
    }
}

void render_quantum_system() {
    int num_states = 1 << num_qubits;
    
    if (visualization_mode == 0) {
        // State vector visualization
        for (int i = 0; i < num_states; i++) {
            if (states[i].probability > 0.001) {
                // Calculate position in a higher-dimensional space
                double x = 0, y = 0, z = 0, w = 0;
                
                // Map state index to coordinates
                for (int j = 0; j < num_qubits; j++) {
                    if (i & (1 << j)) {
                        x += cos(2 * M_PI * j / num_qubits);
                        y += sin(2 * M_PI * j / num_qubits);
                        z += cos(4 * M_PI * j / num_qubits);
                        w += sin(4 * M_PI * j / num_qubits);
                    }
                }
                
                // Apply higher-dimensional rotation
                apply_higher_dim_rotation();
                
                // Project to 3D
                double proj_x, proj_y, proj_z;
                project_to_3d(x, y, z, w, &proj_x, &proj_y, &proj_z);
                
                // Project to 2D for rendering
                int screen_x, screen_y;
                project_to_2d(proj_x, proj_y, proj_z, &screen_x, &screen_y);
                
                // Calculate size based on probability
                int size = 5 + (int)(20 * states[i].probability);
                
                // Get color based on state properties
                Uint8 r, g, b;
                color_from_state(states[i], &r, &g, &b);
                
                // Draw the state
                SDL_SetRenderDrawColor(renderer, r, g, b, 255);
                SDL_Rect rect = {screen_x - size/2, screen_y - size/2, size, size};
                SDL_RenderFillRect(renderer, &rect);
                
                // Draw connections to entangled states
                for (int j = 0; j < states[i].entangled_count; j++) {
                    int entangled_idx = states[i].entanglement[j];
                    if (entangled_idx < num_states) {
                        // Calculate position of entangled state
                        double ex = 0, ey = 0, ez = 0, ew = 0;
                        
                        for (int k = 0; k < num_qubits; k++) {
                            if (entangled_idx & (1 << k)) {
                                ex += cos(2 * M_PI * k / num_qubits);
                                ey += sin(2 * M_PI * k / num_qubits);
                                ez += cos(4 * M_PI * k / num_qubits);
                                ew += sin(4 * M_PI * k / num_qubits);
                            }
                        }
                        
                        // Apply higher-dimensional rotation
                        apply_higher_dim_rotation();
                        
                        // Project to 3D
                        double eproj_x, eproj_y, eproj_z;
                        project_to_3d(ex, ey, ez, ew, &eproj_x, &eproj_y, &eproj_z);
                        
                        // Project to 2D for rendering
                        int escreen_x, escreen_y;
                        project_to_2d(eproj_x, eproj_y, eproj_z, &escreen_x, &escreen_y);
                        
                        // Draw line between entangled states
                        SDL_SetRenderDrawColor(renderer, r, g, b, 100);
                        SDL_RenderDrawLine(renderer, screen_x, screen_y, escreen_x, escreen_y);
                    }
                }
            }
        }
    } else if (visualization_mode == 1) {
        // Bloch sphere visualization for first qubit
        draw_bloch_sphere();
    }
}

void handle_input() {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT) {
            running = 0;
        } else if (event.type == SDL_KEYDOWN) {
            switch (event.key.keysym.sym) {
                case SDLK_ESCAPE:
                    running = 0;
                    break;
                case SDLK_1:
                    visualization_mode = 0;
                    break;
                case SDLK_2:
                    visualization_mode = 1;
                    break;
                case SDLK_UP:
                    num_qubits = (num_qubits < MAX_QUBITS) ? num_qubits + 1 : num_qubits;
                    init_quantum_system();
                    break;
                case SDLK_DOWN:
                    num_qubits = (num_qubits > 1) ? num_qubits - 1 : num_qubits;
                    init_quantum_system();
                    break;
                case SDLK_SPACE:
                    computation_step = (computation_step + 1) % 10;
                    simulate_quantum_computation();
                    break;
            }
        }
    }
}

void draw_ui() {
    SDL_Color white = {255, 255, 255, 255};
    SDL_Color cyan = {0, 255, 255, 255};
    SDL_Color yellow = {255, 255, 0, 255};
    
    const char* mode_names[] = {
        "Higher-Dimensional State Visualization",
        "Bloch Sphere Visualization"
    };
    
    char mode_text[100];
    snprintf(mode_text, 100, "Mode: %s", mode_names[visualization_mode]);
    draw_string(mode_text, 20, 20, yellow);
    
    char qubit_text[50];
    snprintf(qubit_text, 50, "Qubits: %d", num_qubits);
    draw_string(qubit_text, 20, 50, cyan);
    
    char step_text[50];
    snprintf(step_text, 50, "Computation Step: %d", computation_step);
    draw_string(step_text, 20, 80, white);
    
    draw_string("Controls:", 20, HEIGHT - 120, white);
    draw_string("1-2: Change visualization mode", 20, HEIGHT - 100, white);
    draw_string("UP/DOWN: Adjust number of qubits", 20, HEIGHT - 80, white);
    draw_string("SPACE: Advance computation step", 20, HEIGHT - 60, white);
    draw_string("ESC: Quit", 20, HEIGHT - 40, white);
}

// Simplified text drawing function
void draw_string(const char* text, int x, int y, SDL_Color color) {
    // In a real implementation, you would use SDL_ttf or texture-based rendering
    // For this example, we'll just print to console and draw a simple marker
    printf("UI: %s\n", text);
    
    SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
    SDL_Rect rect = {x, y, 10, 2};
    SDL_RenderFillRect(renderer, &rect);
}

void apply_quantum_gate(QuantumGate gate) {
    // This is a simplified implementation
    // In a real quantum simulator, we would apply the gate to the state vector
    
    int num_states = 1 << num_qubits;
    
    // For demonstration, we'll just create some interesting patterns
    for (int i = 0; i < num_states; i++) {
        // Create interference patterns
        double phase = 2 * M_PI * (i & (1 << gate.target_qubit)) / num_states;
        states[i].amplitude *= cexp(I * phase * global_time);
        
        // Normalize
        double norm = 0.0;
        for (int j = 0; j < num_states; j++) {
            norm += cabs(states[j].amplitude) * cabs(states[j].amplitude);
        }
        
        if (norm > 0) {
            states[i].amplitude /= sqrt(norm);
        }
    }
    
    // Create some entanglement
    if (gate.control_qubit >= 0) {
        for (int i = 0; i < num_states; i++) {
            if (i & (1 << gate.control_qubit)) {
                int target_state = i ^ (1 << gate.target_qubit);
                create_quantum_entanglement(i, target_state);
            }
        }
    }
}

void simulate_quantum_computation() {
    // Simulate a simple quantum computation
    switch (computation_step) {
        case 0:
            // Initial state - all zeros
            break;
        case 1:
            // Apply Hadamard to first qubit
            apply_quantum_gate(gates[0]);
            break;
        case 2:
            // Apply CNOT between first and second qubit
            apply_quantum_gate(gates[4]);
            break;
        case 3:
            // Apply Hadamard to second qubit
            gates[0].target_qubit = 1;
            apply_quantum_gate(gates[0]);
            gates[0].target_qubit = 0;
            break;
        case 4:
            // Apply Pauli-X to third qubit
            gates[1].target_qubit = 2;
            apply_quantum_gate(gates[1]);
            gates[1].target_qubit = 0;
            break;
        case 5:
            // Apply CNOT between second and third qubit
            gates[4].target_qubit = 2;
            gates[4].control_qubit = 1;
            apply_quantum_gate(gates[4]);
            gates[4].target_qubit = 1;
            gates[4].control_qubit = 0;
            break;
        case 6:
            // Apply Hadamard to third qubit
            gates[0].target_qubit = 2;
            apply_quantum_gate(gates[0]);
            gates[0].target_qubit = 0;
            break;
        case 7:
            // Apply Pauli-Z to first qubit
            apply_quantum_gate(gates[3]);
            break;
        case 8:
            // Apply CNOT between first and fourth qubit
            gates[4].target_qubit = 3;
            gates[4].control_qubit = 0;
            apply_quantum_gate(gates[4]);
            gates[4].target_qubit = 1;
            gates[4].control_qubit = 0;
            break;
        case 9:
            // Apply Hadamard to fourth qubit
            gates[0].target_qubit = 3;
            apply_quantum_gate(gates[0]);
            gates[0].target_qubit = 0;
            break;
    }
}

void project_to_3d(double x, double y, double z, double w, double* out_x, double* out_y, double* out_z) {
    // Simple projection from 4D to 3D
    *out_x = x + 0.5 * w;
    *out_y = y + 0.5 * w;
    *out_z = z + 0.5 * w;
}

void project_to_2d(double x, double y, double z, int* out_x, int* out_y) {
    // Perspective projection from 3D to 2D
    double distance = 5.0;
    double scale = 200.0;
    
    double factor = distance / (distance - z);
    *out_x = CENTER_X + (int)(x * factor * scale);
    *out_y = CENTER_Y + (int)(y * factor * scale);
}

void color_from_state(QuantumState state, Uint8* r, Uint8* g, Uint8* b) {
    // Map complex amplitude to color
    double phase = carg(state.amplitude); // Phase angle
    double magnitude = cabs(state.amplitude);
    
    // Convert phase to hue
    double hue = (phase + M_PI) / (2 * M_PI); // Map from [-π, π] to [0, 1]
    
    // Convert HSL to RGB
    double c = magnitude * 2.0;
    double x = c * (1 - fabs(fmod(hue * 6, 2) - 1));
    double m = 0.5 - c/2;
    
    double r_f, g_f, b_f;
    
    if (hue < 1.0/6.0) {
        r_f = c; g_f = x; b_f = 0;
    } else if (hue < 2.0/6.0) {
        r_f = x; g_f = c; b_f = 0;
    } else if (hue < 3.0/6.0) {
        r_f = 0; g_f = c; b_f = x;
    } else if (hue < 4.0/6.0) {
        r_f = 0; g_f = x; b_f = c;
    } else if (hue < 5.0/6.0) {
        r_f = x; g_f = 0; b_f = c;
    } else {
        r_f = c; g_f = 0; b_f = x;
    }
    
    *r = (Uint8)((r_f + m) * 255);
    *g = (Uint8)((g_f + m) * 255);
    *b = (Uint8)((b_f + m) * 255);
}

void create_quantum_entanglement(int state1, int state2) {
    if (states[state1].entangled_count < MAX_QUBITS &&
        states[state2].entangled_count < MAX_QUBITS) {
        
        states[state1].entanglement[states[state1].entangled_count++] = state2;
        states[state2].entanglement[states[state2].entangled_count++] = state1;
    }
}

void apply_higher_dim_rotation() {
    // This function would apply rotations in higher dimensions
    // For this demo, we'll just update the projection matrix based on time
    
    // Simple rotation in the XW plane
    double angle = projection.rotation_angles[0];
    projection.projection_matrix[0][0] = cos(angle);
    projection.projection_matrix[0][3] = -sin(angle);
    projection.projection_matrix[3][0] = sin(angle);
    projection.projection_matrix[3][3] = cos(angle);
    
    // Simple rotation in the YZ plane
    angle = projection.rotation_angles[1];
    projection.projection_matrix[1][1] = cos(angle);
    projection.projection_matrix[1][2] = -sin(angle);
    projection.projection_matrix[2][1] = sin(angle);
    projection.projection_matrix[2][2] = cos(angle);
}

void draw_bloch_sphere() {
    // Draw a Bloch sphere representation for the first qubit
    
    int sphere_radius = 150;
    int sphere_x = CENTER_X;
    int sphere_y = CENTER_Y;
    
    // Draw sphere outline
    SDL_SetRenderDrawColor(renderer, 100, 100, 100, 255);
    for (int i = 0; i < 360; i += 5) {
        double angle = i * M_PI / 180.0;
        int x = sphere_x + cos(angle) * sphere_radius;
        int y = sphere_y + sin(angle) * sphere_radius;
        SDL_RenderDrawPoint(renderer, x, y);
    }
    
    // Draw axes
    SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255); // X axis (red)
    SDL_RenderDrawLine(renderer, sphere_x - sphere_radius, sphere_y, sphere_x + sphere_radius, sphere_y);
    
    SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255); // Y axis (green)
    SDL_RenderDrawLine(renderer, sphere_x, sphere_y - sphere_radius, sphere_x, sphere_y + sphere_radius);
    
    SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255); // Z axis (blue)
    SDL_RenderDrawLine(renderer, sphere_x, sphere_y, sphere_x, sphere_y - sphere_radius);
    
    // Calculate the state vector for the first qubit
    double alpha_real = 0.0, alpha_imag = 0.0;
    double beta_real = 0.0, beta_imag = 0.0;
    
    int num_states = 1 << num_qubits;
    for (int i = 0; i < num_states; i++) {
        if ((i & 1) == 0) {
            // First qubit is |0⟩
            alpha_real += creal(states[i].amplitude);
            alpha_imag += cimag(states[i].amplitude);
        } else {
            // First qubit is |1⟩
            beta_real += creal(states[i].amplitude);
            beta_imag += cimag(states[i].amplitude);
        }
    }
    
    // Normalize
    double norm = sqrt(alpha_real*alpha_real + alpha_imag*alpha_imag + 
                      beta_real*beta_real + beta_imag*beta_imag);
    if (norm > 0) {
        alpha_real /= norm;
        alpha_imag /= norm;
        beta_real /= norm;
        beta_imag /= norm;
    }
    
    // Calculate Bloch vector coordinates
    double x = 2 * (alpha_real * beta_real + alpha_imag * beta_imag);
    double y = 2 * (alpha_imag * beta_real - alpha_real * beta_imag);
    double z = alpha_real*alpha_real + alpha_imag*alpha_imag - 
              beta_real*beta_real - beta_imag*beta_imag;
    
    // Project to sphere surface
    int point_x = sphere_x + (int)(x * sphere_radius);
    int point_y = sphere_y - (int)(y * sphere_radius); // Negative because screen Y is down
    
    // Draw the state point
    SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255); // Yellow
    SDL_Rect rect = {point_x - 5, point_y - 5, 10, 10};
    SDL_RenderFillRect(renderer, &rect);
    
    // Draw a line from center to state point
    SDL_RenderDrawLine(renderer, sphere_x, sphere_y, point_x, point_y);
}