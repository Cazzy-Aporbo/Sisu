/*
 * QUANTUM CONSCIOUSNESS EXPLORER
 * 
 * An experimental C program that creates an interactive experience exploring
 * the intersection of quantum mechanics, consciousness, and higher dimensions.
 * 
 * This program uses SDL2 for visualization and creates a meditative,
 * educational journey through concepts that challenge conventional perception.
 */

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
#define MAX_DIMENSIONS 11
#define MAX_PARTICLES 500
#define MAX_ENTANGLED 5

// Structure for quantum particles
typedef struct {
    double x, y;               // Position
    double complex amplitude;  // Quantum amplitude (complex number)
    double probability;        // Measurement probability
    int state;                 // Quantum state (0 or 1 when measured)
    int entangled[MAX_ENTANGLED]; // Entangled particles
    int entangled_count;
    int dimension;             // Which dimension this particle primarily exists in
} QuantumParticle;

// Structure for dimensional frequencies
typedef struct {
    double frequency;
    double amplitude;
    double phase;
    int dimension;
} DimensionalFrequency;

// Global variables
SDL_Window* window = NULL;
SDL_Renderer* renderer = NULL;
int running = 1;
QuantumParticle particles[MAX_PARTICLES];
DimensionalFrequency dimensions[MAX_DIMENSIONS];
double time_flow = 0;
double observer_effect = 0.5;
int focused_dimension = 3;
double quantum_coherence = 1.0;
int meditation_mode = 0;
int measurement_effect = 0;

// Function declarations
void init_sdl();
void cleanup();
void init_quantum_system();
void update_quantum_system(double dt);
void render_quantum_system();
void handle_input();
void draw_ui();
void draw_string(const char* text, int x, int y, SDL_Color color);
void color_from_dimension(int dim, Uint8* r, Uint8* g, Uint8* b);
void initiate_quantum_measurement(int particle_index);
void create_quantum_entanglement(int particle1, int particle2);
double dimensional_transform(double x, double y, int dimension);
void apply_observer_effect();
void meditation_effect();
void draw_mandala_pattern();

int main(int argc, char* argv[]) {
    printf("Initializing Quantum Consciousness Explorer...\n");
    printf("This program explores the intersection of quantum physics and consciousness.\n");
    printf("Use keys 1-9 to focus on different dimensions, M to toggle meditation mode,\n");
    printf("SPACE to create quantum measurements, and ESC to quit.\n");
    
    init_sdl();
    init_quantum_system();
    
    Uint32 last_time = SDL_GetTicks();
    
    // Main loop
    while (running) {
        Uint32 current_time = SDL_GetTicks();
        double dt = (current_time - last_time) / 1000.0;
        last_time = current_time;
        
        time_flow += dt;
        
        handle_input();
        update_quantum_system(dt);
        
        // Clear screen with a dark background representing the quantum vacuum
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
    
    window = SDL_CreateWindow("Quantum Consciousness Explorer", 
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
    // Initialize dimensional frequencies
    for (int i = 0; i < MAX_DIMENSIONS; i++) {
        dimensions[i].frequency = 0.1 + (i * 0.15);
        dimensions[i].amplitude = 0.3 + (i * 0.05);
        dimensions[i].phase = (2 * M_PI * rand()) / RAND_MAX;
        dimensions[i].dimension = i + 1;
    }
    
    // Initialize quantum particles
    for (int i = 0; i < MAX_PARTICLES; i++) {
        particles[i].x = (double)rand() / RAND_MAX * WIDTH;
        particles[i].y = (double)rand() / RAND_MAX * HEIGHT;
        particles[i].amplitude = (2.0 * rand() / RAND_MAX - 1.0) + 
                                (2.0 * rand() / RAND_MAX - 1.0) * I;
        particles[i].probability = cabs(particles[i].amplitude);
        particles[i].state = 0;
        particles[i].entangled_count = 0;
        particles[i].dimension = rand() % MAX_DIMENSIONS + 1;
        
        // Create some entangled particles
        if (i % 10 == 0 && i + 1 < MAX_PARTICLES) {
            create_quantum_entanglement(i, i + 1);
        }
    }
}

void update_quantum_system(double dt) {
    // Update dimensional frequencies
    for (int i = 0; i < MAX_DIMENSIONS; i++) {
        dimensions[i].phase += dimensions[i].frequency * dt;
        if (dimensions[i].phase > 2 * M_PI) {
            dimensions[i].phase -= 2 * M_PI;
        }
    }
    
    // Update particle positions based on quantum probabilities
    for (int i = 0; i < MAX_PARTICLES; i++) {
        // Calculate influence from focused dimension
        double dim_influence = (particles[i].dimension == focused_dimension) ? 1.0 : 0.3;
        
        // Update probability based on dimensional frequencies
        double prob_change = 0;
        for (int j = 0; j < MAX_DIMENSIONS; j++) {
            prob_change += dimensions[j].amplitude * 
                          sin(dimensions[j].frequency * time_flow + dimensions[j].phase) *
                          (j + 1) / MAX_DIMENSIONS;
        }
        
        particles[i].probability += prob_change * dt * dim_influence;
        
        // Keep probability in valid range
        if (particles[i].probability < 0) particles[i].probability = 0;
        if (particles[i].probability > 1) particles[i].probability = 1;
        
        // Update position based on probability and dimensional interference
        double move_x = (2.0 * rand() / RAND_MAX - 1.0) * 2.0 * particles[i].probability;
        double move_y = (2.0 * rand() / RAND_MAX - 1.0) * 2.0 * particles[i].probability;
        
        particles[i].x += move_x * dim_influence;
        particles[i].y += move_y * dim_influence;
        
        // Wrap around screen edges
        if (particles[i].x < 0) particles[i].x += WIDTH;
        if (particles[i].x > WIDTH) particles[i].x -= WIDTH;
        if (particles[i].y < 0) particles[i].y += HEIGHT;
        if (particles[i].y > HEIGHT) particles[i].y -= HEIGHT;
        
        // Update amplitude based on probability
        particles[i].amplitude = particles[i].probability * cexp(I * 2 * M_PI * rand() / RAND_MAX);
    }
    
    // Apply observer effect if measurement has been made
    if (measurement_effect > 0) {
        apply_observer_effect();
        measurement_effect--;
    }
    
    // Apply meditation effects if in meditation mode
    if (meditation_mode) {
        meditation_effect();
    }
}

void render_quantum_system() {
    if (meditation_mode) {
        draw_mandala_pattern();
    }
    
    // Draw quantum particles
    for (int i = 0; i < MAX_PARTICLES; i++) {
        Uint8 r, g, b;
        color_from_dimension(particles[i].dimension, &r, &g, &b);
        
        // Adjust color based on probability
        double brightness = 0.5 + 0.5 * particles[i].probability;
        r *= brightness;
        g *= brightness;
        b *= brightness;
        
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        
        // Draw the particle with size based on probability
        int size = 2 + (int)(3 * particles[i].probability);
        SDL_Rect rect = {particles[i].x - size/2, particles[i].y - size/2, size, size};
        SDL_RenderFillRect(renderer, &rect);
        
        // Draw connections between entangled particles
        for (int j = 0; j < particles[i].entangled_count; j++) {
            int entangled_idx = particles[i].entangled[j];
            if (entangled_idx < MAX_PARTICLES) {
                SDL_SetRenderDrawColor(renderer, r, g, b, 100); // Semi-transparent
                SDL_RenderDrawLine(renderer, 
                                  particles[i].x, particles[i].y,
                                  particles[entangled_idx].x, particles[entangled_idx].y);
            }
        }
    }
    
    // Draw dimensional interference patterns
    for (int i = 0; i < MAX_DIMENSIONS; i++) {
        if (i + 1 == focused_dimension) {
            Uint8 r, g, b;
            color_from_dimension(i + 1, &r, &g, &b);
            SDL_SetRenderDrawColor(renderer, r, g, b, 50); // Semi-transparent
            
            // Draw interference pattern for this dimension
            for (int x = 0; x < WIDTH; x += 10) {
                for (int y = 0; y < HEIGHT; y += 10) {
                    double value = dimensional_transform(x, y, i + 1);
                    if (fmod(value, 0.2) < 0.1) {
                        SDL_RenderDrawPoint(renderer, x, y);
                    }
                }
            }
        }
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
                case SDLK_1: case SDLK_2: case SDLK_3: case SDLK_4: 
                case SDLK_5: case SDLK_6: case SDLK_7: case SDLK_8: case SDLK_9:
                    focused_dimension = event.key.keysym.sym - SDLK_1 + 1;
                    if (focused_dimension > MAX_DIMENSIONS) {
                        focused_dimension = MAX_DIMENSIONS;
                    }
                    break;
                case SDLK_m:
                    meditation_mode = !meditation_mode;
                    break;
                case SDLK_SPACE:
                    // Create a quantum measurement effect
                    measurement_effect = 30;
                    for (int i = 0; i < 10; i++) {
                        int particle = rand() % MAX_PARTICLES;
                        initiate_quantum_measurement(particle);
                    }
                    break;
                case SDLK_UP:
                    observer_effect += 0.1;
                    if (observer_effect > 1.0) observer_effect = 1.0;
                    break;
                case SDLK_DOWN:
                    observer_effect -= 0.1;
                    if (observer_effect < 0.0) observer_effect = 0.0;
                    break;
                case SDLK_LEFT:
                    quantum_coherence -= 0.1;
                    if (quantum_coherence < 0.1) quantum_coherence = 0.1;
                    break;
                case SDLK_RIGHT:
                    quantum_coherence += 0.1;
                    if (quantum_coherence > 1.0) quantum_coherence = 1.0;
                    break;
            }
        }
    }
}

void draw_ui() {
    SDL_Color white = {255, 255, 255, 255};
    SDL_Color cyan = {0, 255, 255, 255};
    SDL_Color yellow = {255, 255, 0, 255};
    SDL_Color green = {0, 255, 0, 255};
    
    draw_string("QUANTUM CONSCIOUSNESS EXPLORER", 20, 20, yellow);
    
    char dim_text[50];
    snprintf(dim_text, 50, "Focused Dimension: %dD", focused_dimension);
    draw_string(dim_text, 20, 50, cyan);
    
    char effect_text[50];
    snprintf(effect_text, 50, "Observer Effect: %.1f", observer_effect);
    draw_string(effect_text, 20, 80, white);
    
    char coherence_text[50];
    snprintf(coherence_text, 50, "Quantum Coherence: %.1f", quantum_coherence);
    draw_string(coherence_text, 20, 110, white);
    
    if (meditation_mode) {
        draw_string("MEDITATION MODE: ACTIVE", WIDTH - 250, 20, green);
    }
    
    draw_string("Controls:", 20, HEIGHT - 150, white);
    draw_string("1-9: Focus on different dimensions (1D-9D)", 20, HEIGHT - 130, white);
    draw_string("UP/DOWN: Adjust observer effect", 20, HEIGHT - 110, white);
    draw_string("LEFT/RIGHT: Adjust quantum coherence", 20, HEIGHT - 90, white);
    draw_string("SPACE: Create quantum measurements", 20, HEIGHT - 70, white);
    draw_string("M: Toggle meditation mode", 20, HEIGHT - 50, white);
    draw_string("ESC: Quit", 20, HEIGHT - 30, white);
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

void color_from_dimension(int dim, Uint8* r, Uint8* g, Uint8* b) {
    // Map dimensions to colors using a hue spectrum
    float hue = (dim - 1) * (300.0 / MAX_DIMENSIONS); // 0-300 degree range
    float saturation = 0.8;
    float value = 0.9;
    
    // HSV to RGB conversion
    int i = (int)(hue / 60) % 6;
    float f = (hue / 60) - i;
    float p = value * (1 - saturation);
    float q = value * (1 - f * saturation);
    float t = value * (1 - (1 - f) * saturation);
    
    switch (i) {
        case 0: *r = value * 255; *g = t * 255; *b = p * 255; break;
        case 1: *r = q * 255; *g = value * 255; *b = p * 255; break;
        case 2: *r = p * 255; *g = value * 255; *b = t * 255; break;
        case 3: *r = p * 255; *g = q * 255; *b = value * 255; break;
        case 4: *r = t * 255; *g = p * 255; *b = value * 255; break;
        case 5: *r = value * 255; *g = p * 255; *b = q * 255; break;
    }
}

void initiate_quantum_measurement(int particle_index) {
    // Collapse the wave function for this particle
    double rand_val = (double)rand() / RAND_MAX;
    particles[particle_index].state = (rand_val < particles[particle_index].probability) ? 1 : 0;
    
    // Collapse entangled particles
    for (int i = 0; i < particles[particle_index].entangled_count; i++) {
        int entangled_idx = particles[particle_index].entangled[i];
        particles[entangled_idx].state = 1 - particles[particle_index].state; // Opposite state
    }
}

void create_quantum_entanglement(int particle1, int particle2) {
    if (particles[particle1].entangled_count < MAX_ENTANGLED &&
        particles[particle2].entangled_count < MAX_ENTANGLED) {
        
        particles[particle1].entangled[particles[particle1].entangled_count++] = particle2;
        particles[particle2].entangled[particles[particle2].entangled_count++] = particle1;
    }
}

double dimensional_transform(double x, double y, int dimension) {
    // Transform coordinates based on dimension
    double dx = x - CENTER_X;
    double dy = y - CENTER_Y;
    double distance = sqrt(dx*dx + dy*dy);
    double angle = atan2(dy, dx);
    
    return sin(distance * 0.01 * dimension + angle * dimension + time_flow);
}

void apply_observer_effect() {
    // Apply observer effect to particles based on observer_effect value
    for (int i = 0; i < MAX_PARTICLES; i++) {
        if ((double)rand() / RAND_MAX < observer_effect) {
            // Move particles toward center based on observer effect
            double dx = CENTER_X - particles[i].x;
            double dy = CENTER_Y - particles[i].y;
            double distance = sqrt(dx*dx + dy*dy);
            
            if (distance > 1) {
                particles[i].x += dx / distance * observer_effect * 2.0;
                particles[i].y += dy / distance * observer_effect * 2.0;
            }
        }
    }
}

void meditation_effect() {
    // Create a calming, centering effect on the particles
    for (int i = 0; i < MAX_PARTICLES; i++) {
        double dx = particles[i].x - CENTER_X;
        double dy = particles[i].y - CENTER_Y;
        double distance = sqrt(dx*dx + dy*dy);
        
        // Create spiral movement toward center
        double angle = atan2(dy, dx) + 0.05;
        double target_x = CENTER_X + cos(angle) * distance * 0.99;
        double target_y = CENTER_Y + sin(angle) * distance * 0.99;
        
        particles[i].x += (target_x - particles[i].x) * 0.1;
        particles[i].y += (target_y - particles[i].y) * 0.1;
    }
}

void draw_mandala_pattern() {
    // Draw a meditative mandala pattern in the background
    for (int i = 0; i < 72; i++) {
        double angle = i * 5 * M_PI / 180;
        double radius = 100 + 50 * sin(time_flow * 0.5);
        
        int x1 = CENTER_X + radius * cos(angle);
        int y1 = CENTER_Y + radius * sin(angle);
        int x2 = CENTER_X + (radius + 50) * cos(angle + 0.1);
        int y2 = CENTER_Y + (radius + 50) * sin(angle + 0.1);
        
        Uint8 r, g, b;
        color_from_dimension(focused_dimension, &r, &g, &b);
        SDL_SetRenderDrawColor(renderer, r, g, b, 100);
        SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
    }
}