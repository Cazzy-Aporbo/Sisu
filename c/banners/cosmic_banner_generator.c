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
#define MAX_ITERATIONS 150
#define PATTERN_COUNT 7

// Structure for color gradients
typedef struct {
    double r, g, b;
} Color;

// Structure for pattern parameters
typedef struct {
    double time;
    double scale;
    double speed;
    double complexity;
    int pattern_type;
} PatternParams;

// Global variables
SDL_Window* window = NULL;
SDL_Renderer* renderer = NULL;
int running = 1;
double global_time = 0;
int current_pattern = 0;
Color palette[256];
int color_shift = 0;

// Function declarations
void init_sdl();
void cleanup();
void generate_palette();
Color get_color(double value);
void render_pattern(PatternParams* params);
void handle_input();
void draw_ui();
void draw_string(const char* text, int x, int y, SDL_Color color);
void pattern_quantum_flux(PatternParams* params);
void pattern_cosmic_strings(PatternParams* params);
void pattern_fractal_dimensions(PatternParams* params);
void pattern_neural_network(PatternParams* params);
void pattern_magnetic_fields(PatternParams* params);
void pattern_hyperspace(PatternParams* params);
void pattern_quantum_foam(PatternParams* params);

int main(int argc, char* argv[]) {
    printf("Cosmic Pattern Generator\n");
    printf("=======================\n");
    printf("Generating never-before-seen visual experiences...\n");
    
    init_sdl();
    generate_palette();
    
    Uint32 last_time = SDL_GetTicks();
    
    // Main loop
    while (running) {
        Uint32 current_time = SDL_GetTicks();
        double dt = (current_time - last_time) / 1000.0;
        last_time = current_time;
        
        global_time += dt;
        color_shift = (color_shift + 1) % 256;
        
        handle_input();
        
        // Clear screen with a dark background
        SDL_SetRenderDrawColor(renderer, 5, 5, 15, 255);
        SDL_RenderClear(renderer);
        
        // Set up pattern parameters
        PatternParams params = {
            .time = global_time,
            .scale = 0.005 + 0.003 * sin(global_time * 0.2),
            .speed = 0.5 + 0.3 * sin(global_time * 0.1),
            .complexity = 5.0 + 2.0 * sin(global_time * 0.15),
            .pattern_type = current_pattern
        };
        
        // Render the current pattern
        render_pattern(&params);
        
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
    
    window = SDL_CreateWindow("Cosmic Pattern Generator", 
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

void generate_palette() {
    // Create a vibrant color palette
    for (int i = 0; i < 256; i++) {
        double t = (double)i / 256.0;
        
        // Use a combination of sine waves to create interesting color transitions
        palette[i].r = 0.5 + 0.5 * sin(2 * M_PI * t + 0);
        palette[i].g = 0.5 + 0.5 * sin(2 * M_PI * t + 2);
        palette[i].b = 0.5 + 0.5 * sin(2 * M_PI * t + 4);
    }
}

Color get_color(double value) {
    // Normalize value to [0, 1]
    while (value < 0) value += 1.0;
    while (value > 1) value -= 1.0;
    
    int index = (int)(value * 255 + color_shift) % 256;
    return palette[index];
}

void render_pattern(PatternParams* params) {
    // Dispatch to the appropriate pattern function
    switch (params->pattern_type) {
        case 0:
            pattern_quantum_flux(params);
            break;
        case 1:
            pattern_cosmic_strings(params);
            break;
        case 2:
            pattern_fractal_dimensions(params);
            break;
        case 3:
            pattern_neural_network(params);
            break;
        case 4:
            pattern_magnetic_fields(params);
            break;
        case 5:
            pattern_hyperspace(params);
            break;
        case 6:
            pattern_quantum_foam(params);
            break;
        default:
            pattern_quantum_flux(params);
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
                case SDLK_RIGHT:
                    current_pattern = (current_pattern + 1) % PATTERN_COUNT;
                    break;
                case SDLK_LEFT:
                    current_pattern = (current_pattern - 1 + PATTERN_COUNT) % PATTERN_COUNT;
                    break;
                case SDLK_1: case SDLK_2: case SDLK_3: case SDLK_4: 
                case SDLK_5: case SDLK_6: case SDLK_7:
                    current_pattern = event.key.keysym.sym - SDLK_1;
                    break;
            }
        }
    }
}

void draw_ui() {
    SDL_Color white = {255, 255, 255, 255};
    SDL_Color cyan = {0, 255, 255, 255};
    SDL_Color yellow = {255, 255, 0, 255};
    
    const char* pattern_names[] = {
        "Quantum Flux",
        "Cosmic Strings",
        "Fractal Dimensions",
        "Neural Network",
        "Magnetic Fields",
        "Hyperspace",
        "Quantum Foam"
    };
    
    char pattern_text[50];
    snprintf(pattern_text, 50, "Pattern: %s", pattern_names[current_pattern]);
    draw_string(pattern_text, 20, 20, yellow);
    
    draw_string("Controls:", 20, HEIGHT - 100, white);
    draw_string("LEFT/RIGHT: Change pattern", 20, HEIGHT - 80, white);
    draw_string("1-7: Select pattern directly", 20, HEIGHT - 60, white);
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

// Pattern 1: Quantum Flux
void pattern_quantum_flux(PatternParams* params) {
    for (int x = 0; x < WIDTH; x += 2) {
        for (int y = 0; y < HEIGHT; y += 2) {
            double dx = (x - CENTER_X) * params->scale;
            double dy = (y - CENTER_Y) * params->scale;
            
            // Create a quantum-inspired pattern
            double value = sin(dx * params->complexity + params->time * params->speed) *
                         cos(dy * params->complexity + params->time * params->speed) *
                         sin(dx * dy * 0.5 + params->time * 0.7);
            
            Color color = get_color(fabs(value));
            
            SDL_SetRenderDrawColor(renderer, 
                                  color.r * 255, 
                                  color.g * 255, 
                                  color.b * 255, 
                                  255);
            SDL_RenderDrawPoint(renderer, x, y);
        }
    }
}

// Pattern 2: Cosmic Strings
void pattern_cosmic_strings(PatternParams* params) {
    for (int x = 0; x < WIDTH; x += 2) {
        for (int y = 0; y < HEIGHT; y += 2) {
            double dx = (x - CENTER_X) * params->scale;
            double dy = (y - CENTER_Y) * params->scale;
            
            // Create string-like patterns
            double angle = atan2(dy, dx);
            double radius = sqrt(dx*dx + dy*dy);
            
            double value = sin(radius * params->complexity - params->time * params->speed) *
                         cos(angle * 10 + params->time * 0.5) *
                         sin(radius * angle * 2 + params->time * 0.3);
            
            Color color = get_color(0.5 + 0.5 * value);
            
            SDL_SetRenderDrawColor(renderer, 
                                  color.r * 255, 
                                  color.g * 255, 
                                  color.b * 255, 
                                  255);
            SDL_RenderDrawPoint(renderer, x, y);
        }
    }
}

// Pattern 3: Fractal Dimensions
void pattern_fractal_dimensions(PatternParams* params) {
    for (int x = 0; x < WIDTH; x += 2) {
        for (int y = 0; y < HEIGHT; y += 2) {
            double dx = (x - CENTER_X) * params->scale;
            double dy = (y - CENTER_Y) * params->scale;
            
            // Create a fractal-inspired pattern
            double real = dx;
            double imag = dy;
            
            double real_temp = real;
            double imag_temp = imag;
            
            int iteration = 0;
            while (real * real + imag * imag < 4 && iteration < MAX_ITERATIONS) {
                real_temp = real * real - imag * imag + dx;
                imag_temp = 2 * real * imag + dy;
                
                real = real_temp;
                imag = imag_temp;
                
                iteration++;
            }
            
            double value = (double)iteration / MAX_ITERATIONS;
            value += 0.2 * sin(params->time * params->speed);
            
            Color color = get_color(value);
            
            SDL_SetRenderDrawColor(renderer, 
                                  color.r * 255, 
                                  color.g * 255, 
                                  color.b * 255, 
                                  255);
            SDL_RenderDrawPoint(renderer, x, y);
        }
    }
}

// Pattern 4: Neural Network
void pattern_neural_network(PatternParams* params) {
    for (int x = 0; x < WIDTH; x += 2) {
        for (int y = 0; y < HEIGHT; y += 2) {
            double dx = (x - CENTER_X) * params->scale;
            double dy = (y - CENTER_Y) * params->scale;
            
            // Create a neural network-like pattern
            double value = tanh(dx * params->complexity + sin(dy * params->complexity + params->time * params->speed)) *
                         tanh(dy * params->complexity + cos(dx * params->complexity + params->time * params->speed));
            
            value = 0.5 + 0.5 * value;
            value += 0.1 * sin(params->time * 2 + dx * 10);
            value += 0.1 * cos(params->time * 1.5 + dy * 10);
            
            Color color = get_color(value);
            
            SDL_SetRenderDrawColor(renderer, 
                                  color.r * 255, 
                                  color.g * 255, 
                                  color.b * 255, 
                                  255);
            SDL_RenderDrawPoint(renderer, x, y);
        }
    }
}

// Pattern 5: Magnetic Fields
void pattern_magnetic_fields(PatternParams* params) {
    for (int x = 0; x < WIDTH; x += 2) {
        for (int y = 0; y < HEIGHT; y += 2) {
            double dx = (x - CENTER_X) * params->scale;
            double dy = (y - CENTER_Y) * params->scale;
            
            // Create magnetic field-like patterns
            double angle = atan2(dy, dx);
            double radius = sqrt(dx*dx + dy*dy);
            
            double value = sin(radius * params->complexity - params->time * params->speed) *
                         cos(angle * 5 + params->time * 0.7) *
                         sin(radius * 3 + angle * 7 + params->time * 0.3);
            
            // Add field lines
            value += 0.2 * sin(angle * 20 + params->time);
            
            Color color = get_color(0.5 + 0.5 * value);
            
            SDL_SetRenderDrawColor(renderer, 
                                  color.r * 255, 
                                  color.g * 255, 
                                  color.b * 255, 
                                  255);
            SDL_RenderDrawPoint(renderer, x, y);
        }
    }
}

// Pattern 6: Hyperspace
void pattern_hyperspace(PatternParams* params) {
    for (int x = 0; x < WIDTH; x += 2) {
        for (int y = 0; y < HEIGHT; y += 2) {
            double dx = (x - CENTER_X) * params->scale;
            double dy = (y - CENTER_Y) * params->scale;
            
            // Create a hyperspace/tunnel effect
            double angle = atan2(dy, dx);
            double radius = sqrt(dx*dx + dy*dy);
            
            double value = sin(1.0 / (radius + 0.1) * params->complexity + params->time * params->speed) *
                         cos(angle * 8 + params->time * 0.5) *
                         sin(radius * 2 + params->time * 0.3);
            
            // Add star-like points
            if (fmod(radius * 50 + params->time * 10, 5) < 0.1) {
                value = 1.0;
            }
            
            Color color = get_color(0.5 + 0.5 * value);
            
            SDL_SetRenderDrawColor(renderer, 
                                  color.r * 255, 
                                  color.g * 255, 
                                  color.b * 255, 
                                  255);
            SDL_RenderDrawPoint(renderer, x, y);
        }
    }
}

// Pattern 7: Quantum Foam
void pattern_quantum_foam(PatternParams* params) {
    for (int x = 0; x < WIDTH; x += 2) {
        for (int y = 0; y < HEIGHT; y += 2) {
            double dx = (x - CENTER_X) * params->scale;
            double dy = (y - CENTER_Y) * params->scale;
            
            // Create a quantum foam-like pattern
            double value = 0;
            
            // Multiple layers of noise
            for (int i = 1; i <= 3; i++) {
                double freq = pow(2, i);
                double amp = pow(0.5, i);
                
                value += amp * sin(freq * dx * params->complexity + params->time * params->speed * i) *
                        cos(freq * dy * params->complexity + params->time * params->speed * i) *
                        sin(freq * dx * dy * 0.3 + params->time * 0.7 * i);
            }
            
            // Add some randomness
            value += 0.1 * sin(1000 * dx * dy + params->time * 5);
            
            Color color = get_color(0.5 + 0.5 * value);
            
            SDL_SetRenderDrawColor(renderer, 
                                  color.r * 255, 
                                  color.g * 255, 
                                  color.b * 255, 
                                  255);
            SDL_RenderDrawPoint(renderer, x, y);
        }
    }
}