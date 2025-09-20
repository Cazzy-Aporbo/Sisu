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
#define MAX_SNAKES 4
#define MAX_LENGTH 500
#define PI 3.14159265358979323846

// Structure for snake segments
typedef struct {
    double x, y;
    double r, g, b;
    double size;
} Segment;

// Structure for snakes
typedef struct {
    Segment segments[MAX_LENGTH];
    int length;
    double direction;
    double speed;
    double target_x, target_y;
    int forming_letter;
    int letter_segment;
    double hue;
    double age;
} Snake;

// Structure for color harmonics
typedef struct {
    double base_hue;
    double complement;
    double triad1, triad2;
    double analog1, analog2;
} ColorHarmony;

// Global variables
SDL_Window* window = NULL;
SDL_Renderer* renderer = NULL;
int running = 1;
Snake snakes[MAX_SNAKES];
double global_time = 0;
int mode = 0; // 0: Forming SISU, 1: Free movement, 2: Recursive patterns
ColorHarmony harmony;
int recursion_depth = 0;

// Function declarations
void init_sdl();
void cleanup();
void init_snakes();
void update_snakes(double dt);
void render_snakes();
void handle_input();
void draw_ui();
void draw_string(const char* text, int x, int y, SDL_Color color);
void calculate_color_harmony(double base_hue);
void hsl_to_rgb(double h, double s, double l, double* r, double* g, double* b);
void form_sisu_pattern();
void free_movement();
void recursive_pattern(int depth, double x, double y, double size, double hue);
void draw_sisu_letters();

int main(int argc, char* argv[]) {
    printf("Recursive Sisu Snake: A Colorful Motion Experience\n");
    printf("=================================================\n");
    printf("Watch as snakes form the word SISU with color theory and recursive patterns.\n");
    
    init_sdl();
    init_snakes();
    
    Uint32 last_time = SDL_GetTicks();
    
    // Main loop
    while (running) {
        Uint32 current_time = SDL_GetTicks();
        double dt = (current_time - last_time) / 1000.0;
        last_time = current_time;
        
        global_time += dt;
        
        handle_input();
        update_snakes(dt);
        
        // Clear screen with a dark background
        SDL_SetRenderDrawColor(renderer, 10, 10, 20, 255);
        SDL_RenderClear(renderer);
        
        // Render the snakes
        render_snakes();
        
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
    
    window = SDL_CreateWindow("Recursive Sisu Snake", 
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

void init_snakes() {
    // Initialize snakes with different properties
    for (int i = 0; i < MAX_SNAKES; i++) {
        snakes[i].length = 50;
        snakes[i].direction = (2 * PI * i) / MAX_SNAKES;
        snakes[i].speed = 2.0 + (i * 0.5);
        snakes[i].target_x = CENTER_X;
        snakes[i].target_y = CENTER_Y;
        snakes[i].forming_letter = 0;
        snakes[i].letter_segment = 0;
        snakes[i].hue = (double)i / MAX_SNAKES;
        snakes[i].age = 0;
        
        // Initialize segments
        for (int j = 0; j < snakes[i].length; j++) {
            snakes[i].segments[j].x = CENTER_X + cos(snakes[i].direction) * j * 2;
            snakes[i].segments[j].y = CENTER_Y + sin(snakes[i].direction) * j * 2;
            snakes[i].segments[j].size = 10.0 - (j * 0.1);
            
            // Set initial color based on hue
            hsl_to_rgb(snakes[i].hue, 0.8, 0.5, 
                       &snakes[i].segments[j].r, 
                       &snakes[i].segments[j].g, 
                       &snakes[i].segments[j].b);
        }
    }
    
    // Calculate initial color harmony
    calculate_color_harmony(0.0);
}

void update_snakes(double dt) {
    for (int i = 0; i < MAX_SNAKES; i++) {
        snakes[i].age += dt;
        
        // Update snake behavior based on mode
        switch (mode) {
            case 0:
                form_sisu_pattern();
                break;
            case 1:
                free_movement();
                break;
            case 2:
                // Recursive patterns are handled in render function
                break;
        }
        
        // Update snake position
        double dx = snakes[i].target_x - snakes[i].segments[0].x;
        double dy = snakes[i].target_y - snakes[i].segments[0].y;
        double dist = sqrt(dx*dx + dy*dy);
        
        if (dist > 1.0) {
            dx /= dist;
            dy /= dist;
            
            snakes[i].segments[0].x += dx * snakes[i].speed;
            snakes[i].segments[0].y += dy * snakes[i].speed;
        }
        
        // Update snake segments (follow the head)
        for (int j = snakes[i].length - 1; j > 0; j--) {
            double follow_x = snakes[i].segments[j-1].x - snakes[i].segments[j].x;
            double follow_y = snakes[i].segments[j-1].y - snakes[i].segments[j].y;
            double follow_dist = sqrt(follow_x*follow_x + follow_y*follow_y);
            
            if (follow_dist > 2.0) {
                follow_x /= follow_dist;
                follow_y /= follow_dist;
                
                snakes[i].segments[j].x += follow_x * (snakes[i].speed * 0.8);
                snakes[i].segments[j].y += follow_y * (snakes[i].speed * 0.8);
            }
        }
        
        // Update colors based on color harmony and time
        for (int j = 0; j < snakes[i].length; j++) {
            double age_factor = sin(snakes[i].age * 0.5 + j * 0.05) * 0.5 + 0.5;
            double hue = fmod(harmony.base_hue + (j * 0.001) + (global_time * 0.1), 1.0);
            
            hsl_to_rgb(hue, 0.8, 0.5, 
                       &snakes[i].segments[j].r, 
                       &snakes[i].segments[j].g, 
                       &snakes[i].segments[j].b);
        }
    }
}

void render_snakes() {
    if (mode == 2) {
        // Draw recursive patterns
        recursion_depth = 0;
        recursive_pattern(0, CENTER_X, CENTER_Y, 300.0, harmony.base_hue);
    } else {
        // Draw snakes
        for (int i = 0; i < MAX_SNAKES; i++) {
            for (int j = 0; j < snakes[i].length; j++) {
                Segment seg = snakes[i].segments[j];
                
                SDL_SetRenderDrawColor(renderer, 
                                      seg.r * 255, 
                                      seg.g * 255, 
                                      seg.b * 255, 
                                      255);
                
                // Draw a circle for each segment
                for (int k = 0; k < 16; k++) {
                    double angle1 = (2 * PI * k) / 16;
                    double angle2 = (2 * PI * (k + 1)) / 16;
                    
                    int x1 = seg.x + cos(angle1) * seg.size;
                    int y1 = seg.y + sin(angle1) * seg.size;
                    int x2 = seg.x + cos(angle2) * seg.size;
                    int y2 = seg.y + sin(angle2) * seg.size;
                    
                    SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
                }
            }
        }
        
        // If in forming mode, draw the SISU letters
        if (mode == 0) {
            draw_sisu_letters();
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
                case SDLK_1:
                    mode = 0;
                    break;
                case SDLK_2:
                    mode = 1;
                    break;
                case SDLK_3:
                    mode = 2;
                    break;
                case SDLK_UP:
                    harmony.base_hue += 0.05;
                    if (harmony.base_hue > 1.0) harmony.base_hue -= 1.0;
                    calculate_color_harmony(harmony.base_hue);
                    break;
                case SDLK_DOWN:
                    harmony.base_hue -= 0.05;
                    if (harmony.base_hue < 0.0) harmony.base_hue += 1.0;
                    calculate_color_harmony(harmony.base_hue);
                    break;
            }
        } else if (event.type == SDL_MOUSEMOTION) {
            // Set target based on mouse position for free movement mode
            if (mode == 1) {
                for (int i = 0; i < MAX_SNAKES; i++) {
                    snakes[i].target_x = event.motion.x;
                    snakes[i].target_y = event.motion.y;
                }
            }
        }
    }
}

void draw_ui() {
    SDL_Color white = {255, 255, 255, 255};
    SDL_Color cyan = {0, 255, 255, 255};
    SDL_Color yellow = {255, 255, 0, 255};
    
    const char* mode_names[] = {
        "Forming SISU",
        "Free Movement",
        "Recursive Patterns"
    };
    
    char mode_text[50];
    snprintf(mode_text, 50, "Mode: %s", mode_names[mode]);
    draw_string(mode_text, 20, 20, yellow);
    
    char hue_text[50];
    snprintf(hue_text, 50, "Base Hue: %.2f", harmony.base_hue);
    draw_string(hue_text, 20, 50, cyan);
    
    draw_string("Controls:", 20, HEIGHT - 120, white);
    draw_string("1-3: Change mode", 20, HEIGHT - 100, white);
    draw_string("UP/DOWN: Adjust base hue", 20, HEIGHT - 80, white);
    draw_string("Mouse: Control snakes in free mode", 20, HEIGHT - 60, white);
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

void calculate_color_harmony(double base_hue) {
    harmony.base_hue = base_hue;
    harmony.complement = fmod(base_hue + 0.5, 1.0);
    harmony.triad1 = fmod(base_hue + 0.333, 1.0);
    harmony.triad2 = fmod(base_hue + 0.667, 1.0);
    harmony.analog1 = fmod(base_hue + 0.042, 1.0);
    harmony.analog2 = fmod(base_hue + 0.083, 1.0);
}

void hsl_to_rgb(double h, double s, double l, double* r, double* g, double* b) {
    // Convert HSL to RGB
    // Algorithm from https://en.wikipedia.org/wiki/HSL_and_HSV
    
    double c = (1 - fabs(2 * l - 1)) * s;
    double h_prime = h * 6;
    double x = c * (1 - fabs(fmod(h_prime, 2) - 1));
    
    if (h_prime >= 0 && h_prime < 1) {
        *r = c; *g = x; *b = 0;
    } else if (h_prime >= 1 && h_prime < 2) {
        *r = x; *g = c; *b = 0;
    } else if (h_prime >= 2 && h_prime < 3) {
        *r = 0; *g = c; *b = x;
    } else if (h_prime >= 3 && h_prime < 4) {
        *r = 0; *g = x; *b = c;
    } else if (h_prime >= 4 && h_prime < 5) {
        *r = x; *g = 0; *b = c;
    } else {
        *r = c; *g = 0; *b = x;
    }
    
    double m = l - c / 2;
    *r += m;
    *g += m;
    *b += m;
    
    // Clamp values
    if (*r < 0) *r = 0;
    if (*r > 1) *r = 1;
    if (*g < 0) *g = 0;
    if (*g > 1) *g = 1;
    if (*b < 0) *b = 0;
    if (*b > 1) *b = 1;
}

void form_sisu_pattern() {
    // Define the points that form the letters S-I-S-U
    static double letter_points[4][20][2];
    static int initialized = 0;
    
    if (!initialized) {
        // S shape
        for (int i = 0; i < 20; i++) {
            double angle = (2 * PI * i) / 20;
            letter_points[0][i][0] = CENTER_X - 200 + cos(angle) * 50;
            letter_points[0][i][1] = CENTER_Y - 100 + sin(angle) * 50;
            if (i > 10) {
                letter_points[0][i][0] = CENTER_X - 200 + cos(angle) * 50;
                letter_points[0][i][1] = CENTER_Y + sin(angle) * 50;
            }
        }
        
        // I shape (vertical line)
        for (int i = 0; i < 20; i++) {
            letter_points[1][i][0] = CENTER_X - 50;
            letter_points[1][i][1] = CENTER_Y - 100 + i * 10;
        }
        
        // S shape (different from first)
        for (int i = 0; i < 20; i++) {
            double angle = (2 * PI * i) / 20;
            letter_points[2][i][0] = CENTER_X + 50 + cos(angle) * 50;
            letter_points[2][i][1] = CENTER_Y - 100 + sin(angle) * 50;
            if (i > 10) {
                letter_points[2][i][0] = CENTER_X + 50 + cos(angle) * 50;
                letter_points[2][i][1] = CENTER_Y + sin(angle) * 50;
            }
        }
        
        // U shape
        for (int i = 0; i < 20; i++) {
            double angle = (PI * i) / 19;
            letter_points[3][i][0] = CENTER_X + 200 + cos(angle) * 50;
            letter_points[3][i][1] = CENTER_Y - 50 + sin(angle) * 50;
        }
        
        initialized = 1;
    }
    
    // Set targets for each snake to form the letters
    for (int i = 0; i < MAX_SNAKES; i++) {
        int letter_idx = i % 4;
        int point_idx = (snakes[i].letter_segment) % 20;
        
        snakes[i].target_x = letter_points[letter_idx][point_idx][0];
        snakes[i].target_y = letter_points[letter_idx][point_idx][1];
        
        snakes[i].letter_segment = (snakes[i].letter_segment + 1) % 20;
    }
}

void free_movement() {
    // In free movement mode, targets are set by mouse motion
    // This function doesn't need to do anything as targets are set in handle_input
}

void recursive_pattern(int depth, double x, double y, double size, double hue) {
    if (depth > 5) return; // Limit recursion depth
    
    // Draw a pattern based on the current recursion
    for (int i = 0; i < 6; i++) {
        double angle = (2 * PI * i) / 6 + global_time * 0.5;
        double new_x = x + cos(angle) * size;
        double new_y = y + sin(angle) * size;
        
        // Calculate color based on depth and hue
        double r, g, b;
        double new_hue = fmod(hue + depth * 0.1, 1.0);
        hsl_to_rgb(new_hue, 0.8, 0.5, &r, &g, &b);
        
        SDL_SetRenderDrawColor(renderer, r * 255, g * 255, b * 255, 255);
        
        // Draw a line
        SDL_RenderDrawLine(renderer, x, y, new_x, new_y);
        
        // Draw a circle
        for (int j = 0; j < 16; j++) {
            double angle1 = (2 * PI * j) / 16;
            double angle2 = (2 * PI * (j + 1)) / 16;
            
            int x1 = new_x + cos(angle1) * size * 0.2;
            int y1 = new_y + sin(angle1) * size * 0.2;
            int x2 = new_x + cos(angle2) * size * 0.2;
            int y2 = new_y + sin(angle2) * size * 0.2;
            
            SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
        }
        
        // Recursive call
        recursive_pattern(depth + 1, new_x, new_y, size * 0.6, new_hue);
    }
}

void draw_sisu_letters() {
    // Draw the word SISU in the background
    SDL_Color color = {100, 100, 200, 100}; // Semi-transparent blue
    SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
    
    // Draw S
    for (int i = 0; i < 20; i++) {
        double angle = (2 * PI * i) / 20;
        int x = CENTER_X - 200 + cos(angle) * 50;
        int y = CENTER_Y - 100 + sin(angle) * 50;
        if (i > 10) {
            x = CENTER_X - 200 + cos(angle) * 50;
            y = CENTER_Y + sin(angle) * 50;
        }
        
        if (i > 0) {
            double prev_angle = (2 * PI * (i-1)) / 20;
            int prev_x = CENTER_X - 200 + cos(prev_angle) * 50;
            int prev_y = CENTER_Y - 100 + sin(prev_angle) * 50;
            if (i-1 > 10) {
                prev_x = CENTER_X - 200 + cos(prev_angle) * 50;
                prev_y = CENTER_Y + sin(prev_angle) * 50;
            }
            
            SDL_RenderDrawLine(renderer, prev_x, prev_y, x, y);
        }
    }
    
    // Draw I
    SDL_RenderDrawLine(renderer, CENTER_X - 50, CENTER_Y - 100, CENTER_X - 50, CENTER_Y + 100);
    
    // Draw S
    for (int i = 0; i < 20; i++) {
        double angle = (2 * PI * i) / 20;
        int x = CENTER_X + 50 + cos(angle) * 50;
        int y = CENTER_Y - 100 + sin(angle) * 50;
        if (i > 10) {
            x = CENTER_X + 50 + cos(angle) * 50;
            y = CENTER_Y + sin(angle) * 50;
        }
        
        if (i > 0) {
            double prev_angle = (2 * PI * (i-1)) / 20;
            int prev_x = CENTER_X + 50 + cos(prev_angle) * 50;
            int prev_y = CENTER_Y - 100 + sin(prev_angle) * 50;
            if (i-1 > 10) {
                prev_x = CENTER_X + 50 + cos(prev_angle) * 50;
                prev_y = CENTER_Y + sin(prev_angle) * 50;
            }
            
            SDL_RenderDrawLine(renderer, prev_x, prev_y, x, y);
        }
    }
    
    // Draw U
    for (int i = 0; i < 20; i++) {
        double angle = (PI * i) / 19;
        int x = CENTER_X + 200 + cos(angle) * 50;
        int y = CENTER_Y - 50 + sin(angle) * 50;
        
        if (i > 0) {
            double prev_angle = (PI * (i-1)) / 19;
            int prev_x = CENTER_X + 200 + cos(prev_angle) * 50;
            int prev_y = CENTER_Y - 50 + sin(prev_angle) * 50;
            
            SDL_RenderDrawLine(renderer, prev_x, prev_y, x, y);
        }
    }
}