#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>
#include <math.h>
#include <complex.h>

#define WIDTH 120
#define HEIGHT 40
#define MAX_ITERATIONS 100
#define MAX_FRACTAL_DEPTH 12
#define NUM_FRACTAL_TYPES 8
#define NUM_RECURSIVE_PATTERNS 6

// Fractal types
#define MANDELBROT 0
#define JULIA 1
#define SIERPINSKI 2
#define KOCH_SNOWFLAKE 3
#define DRAGON_CURVE 4
#define HILBERT_CURVE 5
#define NEWTON_FRACTAL 6
#define BURNING_SHIP 7

// Recursive thinking modes
#define ITERATIVE 0
#define RECURSIVE 1
#define DIV_CONQUER 2
#define BACKTRACKING 3
#define DYNAMIC_PROG 4
#define TRANSFORM 5

typedef struct {
    int x, y;
    double complex c;
    int iteration;
    int pattern_type;
    int depth;
    double color_value;
} FractalPoint;

typedef struct {
    int type;
    double complex seed;
    double zoom;
    double move_x, move_y;
    int max_depth;
    int color_scheme;
    double parameter;
} FractalConfig;

typedef struct {
    int thinking_mode;
    int understanding_level;
    int pattern_recognition;
    int recursive_depth;
    int abstraction_ability;
    int transformation_skill;
    long last_breakthrough;
    int focus_level;
} PlayerMind;

typedef struct {
    int x, y;
    char symbol[10];
    double value;
    int active;
    int pattern_id;
} VisualElement;

// Game state
FractalConfig current_fractal;
PlayerMind player;
VisualElement elements[50];
int game_time = 0;
int cognitive_load = 50;
int visual_intensity = 70;
int mathematical_insight = 30;
int system_entropy = 0;

// Visual elements
const char *fractal_emoji[] = {"🌀", "🌪️", "🔺", "❄️", "🐉", "📊", "🎯", "🚀"};
const char *thinking_emoji[] = {"➰", "↩️", "🔀", "🔁", "💡", "♾️"};
const char *complexity_emoji[] = {"🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘"};

// Function prototypes
void set_nonblocking_mode();
void restore_terminal();
void cls();
void init_game();
void draw_fractal_world();
void handle_input(char input);
void update_game();
void generate_fractal();
void update_player_mind();
void show_cognitive_breakthrough();
void adjust_visual_complexity();
void create_visual_pattern(int pattern_type, int x, int y);
void update_visual_elements();
void apply_recursive_thinking(int mode);
void show_mathematical_insight();
void unlock_recursive_ability(const char *ability);
void generate_fractal_insight();

/**
 * Set terminal to non-blocking mode
 */
void set_nonblocking_mode() {
    struct termios ttystate;
    tcgetattr(STDIN_FILENO, &ttystate);
    ttystate.c_lflag &= ~(ICANON | ECHO);
    ttystate.c_cc[VMIN] = 0;
    ttystate.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSANOW, &ttystate);
}

/**
 * Restore terminal to normal mode
 */
void restore_terminal() {
    struct termios ttystate;
    tcgetattr(STDIN_FILENO, &ttystate);
    ttystate.c_lflag |= (ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &ttystate);
}

/**
 * Clear the terminal screen
 */
void cls() { 
    printf("\033[2J\033[H"); 
}

/**
 * Initialize the game
 */
void init_game() {
    srand(time(NULL));
    
    // Initialize fractal configuration
    current_fractal.type = MANDELBROT;
    current_fractal.seed = -0.7 + 0.27 * I;
    current_fractal.zoom = 1.0;
    current_fractal.move_x = 0.0;
    current_fractal.move_y = 0.0;
    current_fractal.max_depth = 5;
    current_fractal.color_scheme = 0;
    current_fractal.parameter = 0.0;
    
    // Initialize player mind
    player.thinking_mode = ITERATIVE;
    player.understanding_level = 30;
    player.pattern_recognition = 40;
    player.recursive_depth = 2;
    player.abstraction_ability = 25;
    player.transformation_skill = 20;
    player.last_breakthrough = 0;
    player.focus_level = 80;
    
    // Initialize visual elements
    for (int i = 0; i < 50; i++) {
        elements[i].active = 0;
    }
    
    // Create initial visual patterns
    for (int i = 0; i < 10; i++) {
        create_visual_pattern(rand() % NUM_RECURSIVE_PATTERNS, 
                             rand() % WIDTH, rand() % HEIGHT);
    }
}

/**
 * Draw the fractal world
 */
void draw_fractal_world() {
    cls();
    
    // Draw header with player stats
    printf("🌀 Recursive Realms: The Fractal Odyssey | Understanding: %d | Depth: %d\n\n", 
           player.understanding_level, player.recursive_depth);
    
    printf("Thinking: %s | Pattern Recognition: %d | Abstraction: %d | Transformation: %d\n\n", 
           thinking_emoji[player.thinking_mode], player.pattern_recognition,
           player.abstraction_ability, player.transformation_skill);
    
    // Generate and draw the fractal
    generate_fractal();
    
    // Draw footer with controls
    printf("\nControls: WASD to navigate | +/- to zoom | C to change fractal | T to think recursively\n");
    printf("Visual Intensity: %d | Cognitive Load: %d | Mathematical Insight: %d\n", 
           visual_intensity, cognitive_load, mathematical_insight);
    
    // Show cognitive breakthroughs periodically
    if (game_time % 150 == 0) {
        show_cognitive_breakthrough();
    }
    
    // Show mathematical insights
    if (game_time % 200 == 0) {
        show_mathematical_insight();
    }
}

/**
 * Generate and display the current fractal
 */
void generate_fractal() {
    double aspect_ratio = (double)WIDTH / HEIGHT;
    
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            double dx = (2.0 * (x + current_fractal.move_x) / WIDTH - 1.0) * current_fractal.zoom * aspect_ratio;
            double dy = (2.0 * (y + current_fractal.move_y) / HEIGHT - 1.0) * current_fractal.zoom;
            
            double complex c = dx + dy * I;
            double complex z = 0;
            int iteration = 0;
            
            // Different fractal formulas
            switch (current_fractal.type) {
                case MANDELBROT:
                    z = 0;
                    while (cabs(z) < 2.0 && iteration < MAX_ITERATIONS) {
                        z = z * z + c;
                        iteration++;
                    }
                    break;
                    
                case JULIA:
                    z = c;
                    while (cabs(z) < 2.0 && iteration < MAX_ITERATIONS) {
                        z = z * z + current_fractal.seed;
                        iteration++;
                    }
                    break;
                    
                case BURNING_SHIP:
                    z = 0;
                    while (cabs(z) < 2.0 && iteration < MAX_ITERATIONS) {
                        z = cpow(creal(z) - cimag(z) * I, 2) + c;
                        iteration++;
                    }
                    break;
                    
                default:
                    // Simple pattern for other fractals
                    z = c;
                    iteration = (int)(cabs(z) * 10) % MAX_ITERATIONS;
                    break;
            }
            
            // Color based on iterations
            char pixel = ' ';
            if (iteration < MAX_ITERATIONS) {
                int color_idx = iteration % 8;
                pixel = " .-+*#%@"[color_idx];
                
                // Add visual elements based on mathematical properties
                if (iteration % 7 == 0 && rand() % 100 < visual_intensity) {
                    printf("%s", complexity_emoji[color_idx]);
                    continue;
                }
            }
            
            printf("%c", pixel);
        }
        printf("\n");
    }
}

/**
 * Handle user input
 */
void handle_input(char input) {
    switch (input) {
        case 'w': current_fractal.move_y -= 0.1 / current_fractal.zoom; break;
        case 's': current_fractal.move_y += 0.1 / current_fractal.zoom; break;
        case 'a': current_fractal.move_x -= 0.1 / current_fractal.zoom; break;
        case 'd': current_fractal.move_x += 0.1 / current_fractal.zoom; break;
        case '+': 
            current_fractal.zoom *= 1.2;
            player.understanding_level += 2;
            break;
        case '-': 
            current_fractal.zoom /= 1.2;
            player.understanding_level += 1;
            break;
        case 'c':
            current_fractal.type = (current_fractal.type + 1) % NUM_FRACTAL_TYPES;
            printf("\n🔁 Changed to %s fractal\n", fractal_emoji[current_fractal.type]);
            player.pattern_recognition += 5;
            usleep(1000000);
            break;
        case 't':
            apply_recursive_thinking(player.thinking_mode);
            break;
        case '1': case '2': case '3': case '4': case '5': case '6':
            player.thinking_mode = input - '1';
            if (player.thinking_mode >= NUM_RECURSIVE_PATTERNS) player.thinking_mode = NUM_RECURSIVE_PATTERNS - 1;
            printf("\n🧠 Thinking mode: %s\n", thinking_emoji[player.thinking_mode]);
            usleep(1000000);
            break;
        case 'q':
            printf("Exiting Recursive Realms. Final Understanding: %d\n", player.understanding_level);
            restore_terminal();
            exit(0);
    }
    
    // Cap values
    if (player.understanding_level > 100) player.understanding_level = 100;
    if (player.pattern_recognition > 100) player.pattern_recognition = 100;
}

/**
 * Apply recursive thinking to gain insights
 */
void apply_recursive_thinking(int mode) {
    printf("\n💭 Applying %s thinking...\n", thinking_emoji[mode]);
    
    switch (mode) {
        case ITERATIVE:
            printf("   Analyzing patterns through iteration...\n");
            player.pattern_recognition += 8;
            cognitive_load += 5;
            break;
            
        case RECURSIVE:
            printf("   Exploring recursive structures...\n");
            player.recursive_depth += 1;
            player.abstraction_ability += 6;
            cognitive_load += 10;
            break;
            
        case DIV_CONQUER:
            printf("   Breaking complex problems into smaller ones...\n");
            player.understanding_level += 10;
            cognitive_load += 7;
            break;
            
        case BACKTRACKING:
            printf("   Exploring solution spaces systematically...\n");
            player.pattern_recognition += 7;
            player.transformation_skill += 5;
            cognitive_load += 8;
            break;
            
        case DYNAMIC_PROG:
            printf("   Building solutions from subproblems...\n");
            player.understanding_level += 8;
            player.abstraction_ability += 7;
            cognitive_load += 12;
            break;
            
        case TRANSFORM:
            printf("   Transforming problems into different representations...\n");
            player.transformation_skill += 10;
            player.abstraction_ability += 8;
            cognitive_load += 9;
            break;
    }
    
    // Check for breakthrough
    if (player.understanding_level > 80 && player.pattern_recognition > 70) {
        show_cognitive_breakthrough();
    }
    
    // Cap values
    if (player.recursive_depth > MAX_FRACTAL_DEPTH) player.recursive_depth = MAX_FRACTAL_DEPTH;
    if (cognitive_load > 100) cognitive_load = 100;
    
    usleep(2000000);
}

/**
 * Show a cognitive breakthrough
 */
void show_cognitive_breakthrough() {
    if (player.understanding_level < 60) return;
    
    int breakthrough_chance = (player.understanding_level - 60) * 2;
    if (rand() % 100 < breakthrough_chance) {
        printf("\n🌟 COGNITIVE BREAKTHROUGH!\n");
        
        // Different types of breakthroughs based on skills
        if (player.abstraction_ability > 70) {
            printf("   You've discovered a new abstraction pattern!\n");
            player.abstraction_ability += 10;
            unlock_recursive_ability("Advanced Abstraction");
        } 
        else if (player.transformation_skill > 70) {
            printf("   You've mastered dimensional transformation!\n");
            player.transformation_skill += 10;
            unlock_recursive_ability("Dimensional Mastery");
        }
        else {
            printf("   You've achieved deeper recursive understanding!\n");
            player.recursive_depth += 1;
            player.understanding_level += 5;
        }
        
        player.last_breakthrough = game_time;
        mathematical_insight += 15;
        
        usleep(2500000);
    }
}

/**
 * Show mathematical insight
 */
void show_mathematical_insight() {
    if (mathematical_insight < 40) return;
    
    printf("\n📐 MATHEMATICAL INSIGHT:\n");
    
    // Different insights based on current fractal
    switch (current_fractal.type) {
        case MANDELBROT:
            printf("   The Mandelbrot set reveals infinite complexity from simple rules.\n");
            printf("   Each zoom reveals self-similar patterns at different scales.\n");
            break;
            
        case JULIA:
            printf("   Julia sets demonstrate how small changes create vastly different patterns.\n");
            printf("   The boundary between order and chaos is infinitely complex.\n");
            break;
            
        case SIERPINSKI:
            printf("   The Sierpinski triangle shows how recursion creates fractal dimensions.\n");
            printf("   The pattern has zero area but infinite perimeter.\n");
            break;
            
        case KOCH_SNOWFLAKE:
            printf("   The Koch snowflake demonstrates finite area with infinite perimeter.\n");
            printf("   This challenges classical concepts of dimension.\n");
            break;
            
        default:
            printf("   Recursive structures often have non-integer dimensions.\n");
            printf("   Complexity emerges from simple rules applied iteratively.\n");
            break;
    }
    
    player.understanding_level += 3;
    mathematical_insight += 5;
    
    if (mathematical_insight > 100) mathematical_insight = 100;
    
    usleep(3000000);
}

/**
 * Unlock a recursive ability
 */
void unlock_recursive_ability(const char *ability) {
    printf("\n🔓 Ability Unlocked: %s!\n", ability);
    visual_intensity += 10;
    if (visual_intensity > 100) visual_intensity = 100;
    
    // Create visual celebration
    for (int i = 0; i < 5; i++) {
        create_visual_pattern(rand() % NUM_RECURSIVE_PATTERNS, 
                             WIDTH/2, HEIGHT/2);
    }
    
    usleep(1500000);
}

/**
 * Create a visual pattern
 */
void create_visual_pattern(int pattern_type, int x, int y) {
    for (int i = 0; i < 50; i++) {
        if (!elements[i].active) {
            elements[i].x = x;
            elements[i].y = y;
            elements[i].active = 1;
            elements[i].value = 1.0;
            elements[i].pattern_id = pattern_type;
            
            switch (pattern_type) {
                case 0: strcpy(elements[i].symbol, "🌀"); break;
                case 1: strcpy(elements[i].symbol, "🌪️"); break;
                case 2: strcpy(elements[i].symbol, "🔺"); break;
                case 3: strcpy(elements[i].symbol, "❄️"); break;
                case 4: strcpy(elements[i].symbol, "🐉"); break;
                case 5: strcpy(elements[i].symbol, "📊"); break;
                default: strcpy(elements[i].symbol, "✨"); break;
            }
            
            break;
        }
    }
}

/**
 * Update visual elements
 */
void update_visual_elements() {
    for (int i = 0; i < 50; i++) {
        if (elements[i].active) {
            // Move elements based on their pattern type
            switch (elements[i].pattern_id) {
                case 0: // Spiral
                    elements[i].x += (int)(2 * cos(game_time * 0.1 + i));
                    elements[i].y += (int)(2 * sin(game_time * 0.1 + i));
                    break;
                    
                case 1: // Chaos
                    elements[i].x += rand() % 5 - 2;
                    elements[i].y += rand() % 5 - 2;
                    break;
                    
                case 2: // Triangular
                    elements[i].x += (int)(3 * cos(i * M_PI * 2 / 3));
                    elements[i].y += (int)(3 * sin(i * M_PI * 2 / 3));
                    break;
                    
                case 3: // Snowflake
                    elements[i].x += (int)(2 * cos(i * M_PI / 3));
                    elements[i].y += (int)(2 * sin(i * M_PI / 3));
                    break;
                    
                case 4: // Dragon
                    elements[i].x += (int)(2 * cos(game_time * 0.05) * (i % 2 ? 1 : -1));
                    elements[i].y += (int)(2 * sin(game_time * 0.05) * (i % 2 ? 1 : -1));
                    break;
                    
                case 5: // Grid
                    elements[i].x += (i % 3) - 1;
                    elements[i].y += ((i / 3) % 3) - 1;
                    break;
            }
            
            // Keep elements in bounds
            if (elements[i].x < 0) elements[i].x = 0;
            if (elements[i].x >= WIDTH) elements[i].x = WIDTH - 1;
            if (elements[i].y < 0) elements[i].y = 0;
            if (elements[i].y >= HEIGHT) elements[i].y = HEIGHT - 1;
            
            // Fade elements over time
            elements[i].value -= 0.02;
            if (elements[i].value <= 0) {
                elements[i].active = 0;
            }
        }
    }
    
    // Occasionally create new patterns
    if (rand() % 100 < visual_intensity / 5) {
        create_visual_pattern(rand() % NUM_RECURSIVE_PATTERNS, 
                             rand() % WIDTH, rand() % HEIGHT);
    }
}

/**
 * Update game state
 */
void update_game() {
    game_time++;
    
    // Update player mind
    update_player_mind();
    
    // Update visual elements
    update_visual_elements();
    
    // Adjust visual complexity based on cognitive load
    adjust_visual_complexity();
    
    // Generate fractal insights periodically
    if (game_time % 300 == 0) {
        generate_fractal_insight();
    }
    
    // Check for mastery
    if (player.understanding_level >= 90 && player.recursive_depth >= MAX_FRACTAL_DEPTH) {
        printf("\n🎉 MASTERY ACHIEVED! You've mastered recursive thinking!\n");
        printf("Your mind can now navigate infinite complexity with ease.\n");
        restore_terminal();
        exit(0);
    }
}

/**
 * Update player mind state
 */
void update_player_mind() {
    // Gradually increase understanding through exposure
    if (cognitive_load > 30) {
        player.understanding_level += 0.1;
    }
    
    // Pattern recognition improves with exposure to different fractals
    if (current_fractal.type != MANDELBROT) {
        player.pattern_recognition += 0.05;
    }
    
    // Cognitive load decreases over time
    if (cognitive_load > 0) {
        cognitive_load -= 0.2;
    }
    
    // Focus level fluctuates
    player.focus_level = 70 + 20 * sin(game_time * 0.01);
    
    // Cap values
    if (player.understanding_level > 100) player.understanding_level = 100;
    if (player.pattern_recognition > 100) player.pattern_recognition = 100;
    if (cognitive_load < 0) cognitive_load = 0;
}

/**
 * Adjust visual complexity based on cognitive load
 */
void adjust_visual_complexity() {
    // Increase visual intensity with understanding but decrease with high cognitive load
    int target_intensity = player.understanding_level - cognitive_load / 2;
    if (target_intensity < 10) target_intensity = 10;
    if (target_intensity > 100) target_intensity = 100;
    
    // Smoothly adjust toward target intensity
    if (visual_intensity < target_intensity) {
        visual_intensity++;
    } else if (visual_intensity > target_intensity) {
        visual_intensity--;
    }
}

/**
 * Generate fractal insight
 */
void generate_fractal_insight() {
    if (mathematical_insight < 50) return;
    
    // Increase mathematical insight based on current skills
    mathematical_insight += (player.abstraction_ability + player.transformation_skill) / 20;
    if (mathematical_insight > 100) mathematical_insight = 100;
    
    // Unlock new abilities at insight milestones
    if (mathematical_insight >= 60 && player.recursive_depth < 5) {
        player.recursive_depth++;
        printf("\n🔍 Deeper recursive understanding achieved! Depth: %d\n", player.recursive_depth);
        unlock_recursive_ability("Deeper Recursion");
    }
    
    if (mathematical_insight >= 80 && player.thinking_mode < TRANSFORM) {
        player.thinking_mode = TRANSFORM;
        printf("\n🧠 Advanced thinking mode unlocked: Transformational Thinking\n");
        unlock_recursive_ability("Transformational Thinking");
    }
}

/**
 * Main game loop
 */
int main() {
    set_nonblocking_mode();
    init_game();
    
    printf("🌀 Welcome to Recursive Realms: The Fractal Odyssey!\n\n");
    printf("Explore the infinite complexity of fractal mathematics and recursive thinking.\n");
    printf("This journey will transform how you perceive patterns, dimensions, and infinity.\n\n");
    printf("Mathematical concepts you'll encounter:\n");
    printf("• Fractal Geometry • Complex Numbers • Recursive Algorithms •\n");
    printf("• Self-Similarity • Dimension Theory • Chaos Theory •\n");
    printf("• Iterated Function Systems • Nonlinear Dynamics •\n\n");
    printf("Press any key to begin your odyssey into recursive thinking...");
    
    char dummy;
    read(STDIN_FILENO, &dummy, 1);
    
    char input;
    while (1) {
        draw_fractal_world();
        
        if (read(STDIN_FILENO, &input, 1) > 0) {
            handle_input(input);
        }
        
        update_game();
        usleep(50000); // 50ms delay
    }
    
    restore_terminal();
    return 0;
}