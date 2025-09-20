/**
 * COSMIC MATH ODYSSEY
 * 
 * An advanced educational game that teaches math through space exploration.
 * Features multiple difficulty levels, progressive learning, and engaging gameplay.
 * 
 * Learning Objectives:
 * - Arithmetic operations (addition, subtraction, multiplication, division)
 * - Fractions and percentages
 * - Basic algebra concepts
 * - Geometry fundamentals
 * - Problem-solving skills
 * 
 * Target Age: 8-14 years
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>
#include <math.h>

// Game constants
#define MAP_W 80
#define MAP_H 40
#define VIEW_W 50
#define VIEW_H 20
#define NUM_PLANETS 12
#define NUM_ASTEROIDS 15
#define NUM_STARS 50
#define NUM_SPACE_STATIONS 3

// Difficulty levels
#define EASY 1
#define MEDIUM 2
#define HARD 3
#define EXPERT 4

// Math categories
#define ARITHMETIC 0
#define FRACTIONS 1
#define ALGEBRA 2
#define GEOMETRY 3

typedef struct {
    int x, y;
    int difficulty;
    int category;
    char problem[100];
    char solution[50];
    int solved;
    int reward;
} Planet;

typedef struct {
    int x, y;
    int speed;
} Asteroid;

typedef struct {
    int x, y;
    int brightness;
} Star;

typedef struct {
    int x, y;
    char tutorial[200];
} SpaceStation;

typedef struct {
    int x, y;
    int fuel;
    int health;
    int score;
    int level;
    int math_skill;
    int current_planet;
    int difficulty;
} Player;

// Game state
Planet planets[NUM_PLANETS];
Asteroid asteroids[NUM_ASTEROIDS];
Star stars[NUM_STARS];
SpaceStation stations[NUM_SPACE_STATIONS];
Player player;

// Game emojis
const char *planet_emoji[] = {"🟠", "🟢", "🔵", "🟣", "🟤", "⚪"};
const char *asteroid_emoji[] = {"🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘"};
const char *station_emoji[] = {"🛰️", "🛸", "🚀"};
const char *difficulty_emoji[] = {"🌱", "🎯", "🔥", "🧠"};
const char *category_emoji[] = {"🔢", "➗", "📐", "△"};

// Function prototypes
void set_nonblocking_mode();
void restore_terminal();
void cls();
void init_game();
void generate_math_problem(Planet *planet);
void draw_game();
void handle_input(char input);
void update_game();
void show_planet_problem();
void check_collisions();
void show_tutorial(int station_index);
void show_stats();
void generate_arithmetic_problem(Planet *planet);
void generate_fraction_problem(Planet *planet);
void generate_algebra_problem(Planet *planet);
void generate_geometry_problem(Planet *planet);
int calculate_correct_answer(Planet *planet);

/**
 * Set terminal to non-blocking mode for smooth gameplay
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
 * Initialize game state
 */
void init_game() {
    srand(time(NULL));
    
    // Initialize player
    player.x = MAP_W / 2;
    player.y = MAP_H / 2;
    player.fuel = 100;
    player.health = 100;
    player.score = 0;
    player.level = 1;
    player.math_skill = 0;
    player.current_planet = -1;
    player.difficulty = EASY;
    
    // Initialize stars
    for (int i = 0; i < NUM_STARS; i++) {
        stars[i].x = rand() % MAP_W;
        stars[i].y = rand() % MAP_H;
        stars[i].brightness = 1 + rand() % 3;
    }
    
    // Initialize asteroids
    for (int i = 0; i < NUM_ASTEROIDS; i++) {
        asteroids[i].x = rand() % MAP_W;
        asteroids[i].y = rand() % MAP_H;
        asteroids[i].speed = 1 + rand() % 3;
    }
    
    // Initialize space stations
    for (int i = 0; i < NUM_SPACE_STATIONS; i++) {
        stations[i].x = 10 + rand() % (MAP_W - 20);
        stations[i].y = 10 + rand() % (MAP_H - 20);
        
        // Set tutorials based on station index
        if (i == 0) {
            strcpy(stations[i].tutorial, "Welcome to the Arithmetic Station! Learn basic operations like addition, subtraction, multiplication, and division.");
        } else if (i == 1) {
            strcpy(stations[i].tutorial, "Welcome to the Fractions Station! Learn about fractions, percentages, and ratios.");
        } else {
            strcpy(stations[i].tutorial, "Welcome to the Algebra & Geometry Station! Learn basic equations and geometric concepts.");
        }
    }
    
    // Initialize planets with math problems
    for (int i = 0; i < NUM_PLANETS; i++) {
        planets[i].x = 5 + rand() % (MAP_W - 10);
        planets[i].y = 5 + rand() % (MAP_H - 10);
        planets[i].difficulty = 1 + (i % 4);
        planets[i].category = i % 4;
        planets[i].solved = 0;
        planets[i].reward = planets[i].difficulty * 10;
        generate_math_problem(&planets[i]);
    }
}

/**
 * Generate a math problem based on planet category and difficulty
 */
void generate_math_problem(Planet *planet) {
    switch (planet->category) {
        case ARITHMETIC:
            generate_arithmetic_problem(planet);
            break;
        case FRACTIONS:
            generate_fraction_problem(planet);
            break;
        case ALGEBRA:
            generate_algebra_problem(planet);
            break;
        case GEOMETRY:
            generate_geometry_problem(planet);
            break;
    }
}

/**
 * Generate an arithmetic problem
 */
void generate_arithmetic_problem(Planet *planet) {
    int a, b, result;
    char op;
    
    switch (planet->difficulty) {
        case EASY:
            a = 1 + rand() % 20;
            b = 1 + rand() % 20;
            op = (rand() % 2 == 0) ? '+' : '-';
            result = (op == '+') ? a + b : a - b;
            sprintf(planet->problem, "What is %d %c %d?", a, op, b);
            sprintf(planet->solution, "%d", result);
            break;
            
        case MEDIUM:
            a = 10 + rand() % 50;
            b = 1 + rand() % 9;
            op = (rand() % 2 == 0) ? '*' : '/';
            if (op == '*') {
                result = a * b;
                sprintf(planet->problem, "What is %d × %d?", a, b);
            } else {
                // Make sure division is exact
                result = a;
                a = a * b;
                sprintf(planet->problem, "What is %d ÷ %d?", a, b);
            }
            sprintf(planet->solution, "%d", result);
            break;
            
        case HARD:
            a = 1 + rand() % 100;
            b = 1 + rand() % 100;
            int c = 1 + rand() % 100;
            int ops = rand() % 3;
            
            if (ops == 0) {
                result = a + b - c;
                sprintf(planet->problem, "What is %d + %d - %d?", a, b, c);
            } else if (ops == 1) {
                result = a * b + c;
                sprintf(planet->problem, "What is %d × %d + %d?", a, b, c);
            } else {
                result = a * (b + c);
                sprintf(planet->problem, "What is %d × (%d + %d)?", a, b, c);
            }
            sprintf(planet->solution, "%d", result);
            break;
            
        case EXPERT:
            a = 10 + rand() % 90;
            b = 2 + rand() % 8;
            int c2 = 1 + rand() % 20;
            int ops2 = rand() % 2;
            
            if (ops2 == 0) {
                result = a * b + c2 * 2;
                sprintf(planet->problem, "What is %d × %d + %d × 2?", a, b, c2);
            } else {
                result = (a + b) * c2;
                sprintf(planet->problem, "What is (%d + %d) × %d?", a, b, c2);
            }
            sprintf(planet->solution, "%d", result);
            break;
    }
}

/**
 * Generate a fraction problem
 */
void generate_fraction_problem(Planet *planet) {
    int a, b, c, d, result_num, result_den;
    char op;
    
    switch (planet->difficulty) {
        case EASY:
            a = 1 + rand() % 4;
            b = a + rand() % 4 + 1;
            sprintf(planet->problem, "Simplify the fraction %d/%d", a, b);
            
            // Find GCD to simplify
            int gcd = 1;
            for (int i = 1; i <= a && i <= b; i++) {
                if (a % i == 0 && b % i == 0) {
                    gcd = i;
                }
            }
            sprintf(planet->solution, "%d/%d", a/gcd, b/gcd);
            break;
            
        case MEDIUM:
            a = 1 + rand() % 5;
            b = a + rand() % 5 + 1;
            c = 1 + rand() % 5;
            d = c + rand() % 5 + 1;
            op = (rand() % 2 == 0) ? '+' : '-';
            
            if (op == '+') {
                result_num = a * d + b * c;
                result_den = b * d;
                sprintf(planet->problem, "What is %d/%d + %d/%d?", a, b, c, d);
            } else {
                result_num = a * d - b * c;
                result_den = b * d;
                sprintf(planet->problem, "What is %d/%d - %d/%d?", a, b, c, d);
            }
            
            // Simplify result
            int gcd2 = 1;
            for (int i = 1; i <= abs(result_num) && i <= result_den; i++) {
                if (result_num % i == 0 && result_den % i == 0) {
                    gcd2 = i;
                }
            }
            sprintf(planet->solution, "%d/%d", result_num/gcd2, result_den/gcd2);
            break;
            
        case HARD:
            a = 1 + rand() % 8;
            b = a + rand() % 8 + 1;
            c = 1 + rand() % 8;
            d = c + rand() % 8 + 1;
            op = (rand() % 2 == 0) ? '*' : '/';
            
            if (op == '*') {
                result_num = a * c;
                result_den = b * d;
                sprintf(planet->problem, "What is %d/%d × %d/%d?", a, b, c, d);
            } else {
                result_num = a * d;
                result_den = b * c;
                sprintf(planet->problem, "What is %d/%d ÷ %d/%d?", a, b, c, d);
            }
            
            // Simplify result
            int gcd3 = 1;
            for (int i = 1; i <= result_num && i <= result_den; i++) {
                if (result_num % i == 0 && result_den % i == 0) {
                    gcd3 = i;
                }
            }
            sprintf(planet->solution, "%d/%d", result_num/gcd3, result_den/gcd3);
            break;
            
        case EXPERT:
            a = 10 + rand() % 90;
            sprintf(planet->problem, "What is %d%% as a simplified fraction?", a);
            sprintf(planet->solution, "%d/100", a);
            
            // Simplify the fraction
            int gcd4 = 1;
            for (int i = 1; i <= a && i <= 100; i++) {
                if (a % i == 0 && 100 % i == 0) {
                    gcd4 = i;
                }
            }
            sprintf(planet->solution, "%d/%d", a/gcd4, 100/gcd4);
            break;
    }
}

/**
 * Generate an algebra problem
 */
void generate_algebra_problem(Planet *planet) {
    int a, b, c, x;
    
    switch (planet->difficulty) {
        case EASY:
            a = 1 + rand() % 5;
            b = 1 + rand() % 10;
            x = 1 + rand() % 5;
            c = a * x + b;
            sprintf(planet->problem, "Solve for x: %dx + %d = %d", a, b, c);
            sprintf(planet->solution, "%d", x);
            break;
            
        case MEDIUM:
            a = 2 + rand() % 4;
            b = 5 + rand() % 10;
            x = 2 + rand() % 5;
            c = a * x - b;
            sprintf(planet->problem, "Solve for x: %dx - %d = %d", a, b, c);
            sprintf(planet->solution, "%d", x);
            break;
            
        case HARD:
            a = 2 + rand() % 5;
            b = 1 + rand() % 5;
            c = 10 + rand() % 20;
            x = 3 + rand() % 5;
            int right_side = a * x + b * x;
            sprintf(planet->problem, "Solve for x: %dx + %dx = %d", a, b, right_side);
            sprintf(planet->solution, "%d", x);
            break;
            
        case EXPERT:
            a = 3 + rand() % 5;
            b = 2 + rand() % 5;
            c = 1 + rand() % 5;
            x = 4 + rand() % 5;
            int right_side2 = a * (x + b) + c;
            sprintf(planet->problem, "Solve for x: %d(x + %d) + %d = %d", a, b, c, right_side2);
            sprintf(planet->solution, "%d", x);
            break;
    }
}

/**
 * Generate a geometry problem
 */
void generate_geometry_problem(Planet *planet) {
    int a, b, result;
    
    switch (planet->difficulty) {
        case EASY:
            a = 2 + rand() % 10;
            b = 2 + rand() % 10;
            result = a * b;
            sprintf(planet->problem, "What is the area of a rectangle with length %d and width %d?", a, b);
            sprintf(planet->solution, "%d", result);
            break;
            
        case MEDIUM:
            a = 5 + rand() % 10;
            result = a * a;
            sprintf(planet->problem, "What is the area of a square with side length %d?", a);
            sprintf(planet->solution, "%d", result);
            break;
            
        case HARD:
            a = 5 + rand() % 10;
            b = 5 + rand() % 10;
            result = (a * b) / 2;
            sprintf(planet->problem, "What is the area of a right triangle with base %d and height %d?", a, b);
            sprintf(planet->solution, "%d", result);
            break;
            
        case EXPERT:
            a = 5 + rand() % 10;
            float radius = a;
            float area = 3.14 * radius * radius;
            sprintf(planet->problem, "What is the area of a circle with radius %d? (Round to nearest whole number)", a);
            sprintf(planet->solution, "%.0f", area);
            break;
    }
}

/**
 * Calculate the correct answer for a problem (used for validation)
 */
int calculate_correct_answer(Planet *planet) {
    // This function would parse the solution string and return the numeric answer
    // For simplicity, we'll just return 0 here and use string comparison for checking
    return 0;
}

/**
 * Draw the game screen
 */
void draw_game() {
    cls();
    
    // Draw header with game information
    printf("🚀 COSMIC MATH ODYSSEY | Level: %d | Fuel: %d | Health: %d | Score: %d\n\n", 
           player.level, player.fuel, player.health, player.score);
    
    // Draw the game map
    for (int y = 0; y < VIEW_H; y++) {
        for (int x = 0; x < VIEW_W; x++) {
            int wx = player.x - VIEW_W/2 + x;
            int wy = player.y - VIEW_H/2 + y;
            char *c = "  "; // Space background
            
            // Check boundaries
            if (wx < 0 || wx >= MAP_W || wy < 0 || wy >= MAP_H) {
                printf("  ");
                continue;
            }
            
            // Draw stars
            for (int i = 0; i < NUM_STARS; i++) {
                if (stars[i].x == wx && stars[i].y == wy) {
                    c = (stars[i].brightness == 1) ? "⋅ " : 
                        (stars[i].brightness == 2) ? "⋆ " : "🌟";
                    break;
                }
            }
            
            // Draw asteroids
            for (int i = 0; i < NUM_ASTEROIDS; i++) {
                if (asteroids[i].x == wx && asteroids[i].y == wy) {
                    c = asteroid_emoji[rand() % 8];
                    break;
                }
            }
            
            // Draw space stations
            for (int i = 0; i < NUM_SPACE_STATIONS; i++) {
                if (stations[i].x == wx && stations[i].y == wy) {
                    c = station_emoji[i];
                    break;
                }
            }
            
            // Draw planets
            for (int i = 0; i < NUM_PLANETS; i++) {
                if (planets[i].x == wx && planets[i].y == wy) {
                    if (planets[i].solved) {
                        c = "💫"; // Solved planets glow
                    } else {
                        c = planet_emoji[planets[i].category];
                    }
                    break;
                }
            }
            
            // Draw player
            if (wx == player.x && wy == player.y) {
                c = "👨‍🚀";
            }
            
            printf("%s", c);
        }
        printf("\n");
    }
    
    // Draw footer with controls
    printf("\nControls: WASD to move | E to interact | Q to quit\n");
    printf("Math Skills: %d/100 | Difficulty: %s\n", player.math_skill, difficulty_emoji[player.difficulty-1]);
    
    // If currently interacting with a planet, show the problem
    if (player.current_planet >= 0) {
        printf("\n🌍 MATH CHALLENGE: %s\n", planets[player.current_planet].problem);
        printf("Enter your answer: ");
    }
}

/**
 * Handle user input
 */
void handle_input(char input) {
    if (player.current_planet >= 0) {
        // Currently answering a math problem
        static char answer[50] = "";
        
        if (input == '\n' || input == '\r') {
            // Submit answer
            if (strcmp(answer, planets[player.current_planet].solution) == 0) {
                printf("✅ Correct! +%d points\n", planets[player.current_planet].reward);
                player.score += planets[player.current_planet].reward;
                player.math_skill += planets[player.current_planet].difficulty * 2;
                planets[player.current_planet].solved = 1;
                
                // Check if all planets are solved
                int all_solved = 1;
                for (int i = 0; i < NUM_PLANETS; i++) {
                    if (!planets[i].solved) {
                        all_solved = 0;
                        break;
                    }
                }
                
                if (all_solved) {
                    player.level++;
                    printf("🎉 Level complete! Advancing to level %d\n", player.level);
                    
                    // Increase difficulty every 2 levels
                    if (player.level % 2 == 0 && player.difficulty < EXPERT) {
                        player.difficulty++;
                        printf("📈 Difficulty increased to %s\n", difficulty_emoji[player.difficulty-1]);
                    }
                    
                    // Reset planets with new problems
                    for (int i = 0; i < NUM_PLANETS; i++) {
                        planets[i].solved = 0;
                        planets[i].difficulty = player.difficulty;
                        generate_math_problem(&planets[i]);
                    }
                }
            } else {
                printf("❌ Incorrect! The answer was %s\n", planets[player.current_planet].solution);
                player.health -= 10;
            }
            
            player.current_planet = -1;
            strcpy(answer, "");
            usleep(1500000); // Pause to show feedback
        } else if (input == 127 || input == 8) {
            // Backspace
            int len = strlen(answer);
            if (len > 0) answer[len-1] = '\0';
        } else if (strlen(answer) < 49) {
            // Append character to answer
            int len = strlen(answer);
            answer[len] = input;
            answer[len+1] = '\0';
        }
    } else {
        // Normal movement
        switch (input) {
            case 'w': if (player.y > 0) player.y--; break;
            case 's': if (player.y < MAP_H - 1) player.y++; break;
            case 'a': if (player.x > 0) player.x--; break;
            case 'd': if (player.x < MAP_W - 1) player.x++; break;
            case 'e': check_collisions(); break;
            case 'q': 
                printf("Thanks for playing! Final score: %d\n", player.score);
                restore_terminal();
                exit(0);
        }
        
        // Consume fuel when moving
        player.fuel--;
        if (player.fuel <= 0) {
            player.health -= 5;
            player.fuel = 0;
            printf("⚠️  Out of fuel! Health decreasing.\n");
        }
    }
}

/**
 * Check for collisions with objects
 */
void check_collisions() {
    // Check for planet collisions
    for (int i = 0; i < NUM_PLANETS; i++) {
        if (abs(planets[i].x - player.x) <= 1 && 
            abs(planets[i].y - player.y) <= 1) {
            player.current_planet = i;
            return;
        }
    }
    
    // Check for space station collisions
    for (int i = 0; i < NUM_SPACE_STATIONS; i++) {
        if (abs(stations[i].x - player.x) <= 1 && 
            abs(stations[i].y - player.y) <= 1) {
            show_tutorial(i);
            return;
        }
    }
    
    // Check for asteroid collisions
    for (int i = 0; i < NUM_ASTEROIDS; i++) {
        if (asteroids[i].x == player.x && asteroids[i].y == player.y) {
            player.health -= 15;
            printf("💥 Asteroid collision! -15 health\n");
            usleep(1000000);
            return;
        }
    }
}

/**
 * Show tutorial from a space station
 */
void show_tutorial(int station_index) {
    cls();
    printf("🛰️  SPACE STATION TUTORIAL\n\n");
    printf("%s\n\n", stations[station_index].tutorial);
    
    // Show examples based on station type
    if (station_index == 0) {
        printf("Arithmetic Examples:\n");
        printf("➗ Addition: 5 + 3 = 8\n");
        printf("➗ Subtraction: 10 - 4 = 6\n");
        printf("➗ Multiplication: 6 × 7 = 42\n");
        printf("➗ Division: 20 ÷ 5 = 4\n");
    } else if (station_index == 1) {
        printf("Fraction Examples:\n");
        printf("➗ Simplifying: 4/8 = 1/2\n");
        printf("➗ Addition: 1/4 + 1/2 = 3/4\n");
        printf("➗ Multiplication: 2/3 × 3/4 = 1/2\n");
        printf("➗ Percentage: 25% = 1/4\n");
    } else {
        printf("Algebra & Geometry Examples:\n");
        printf("➗ Algebra: 2x + 5 = 15 → x = 5\n");
        printf("➗ Rectangle Area: length × width\n");
        printf("➗ Triangle Area: (base × height) ÷ 2\n");
        printf("➗ Circle Area: π × radius²\n");
    }
    
    printf("\nPress any key to continue...");
    char dummy;
    read(STDIN_FILENO, &dummy, 1);
}

/**
 * Update game state
 */
void update_game() {
    // Move asteroids
    for (int i = 0; i < NUM_ASTEROIDS; i++) {
        asteroids[i].x += asteroids[i].speed;
        if (asteroids[i].x >= MAP_W) {
            asteroids[i].x = 0;
            asteroids[i].y = rand() % MAP_H;
        }
    }
    
    // Twinkle stars
    for (int i = 0; i < NUM_STARS; i++) {
        if (rand() % 100 < 5) {
            stars[i].brightness = 1 + rand() % 3;
        }
    }
    
    // Regenerate fuel slowly
    if (rand() % 100 < 10) {
        player.fuel += 1;
        if (player.fuel > 100) player.fuel = 100;
    }
    
    // Check for game over
    if (player.health <= 0) {
        cls();
        printf("💀 GAME OVER\n\n");
        printf("Your spaceship was destroyed!\n");
        printf("Final Score: %d\n", player.score);
        printf("Math Skills: %d/100\n", player.math_skill);
        printf("Level Reached: %d\n", player.level);
        restore_terminal();
        exit(0);
    }
}

/**
 * Main game loop
 */
int main() {
    set_nonblocking_mode();
    init_game();
    
    printf("🚀 Welcome to COSMIC MATH ODYSSEY!\n");
    printf("🌌 Explore the universe while learning math!\n");
    printf("📚 Solve problems to increase your math skills.\n");
    printf("⛽ Manage your fuel and health carefully.\n");
    printf("🎯 Complete levels to advance to harder challenges.\n\n");
    printf("Press any key to begin...");
    
    char dummy;
    read(STDIN_FILENO, &dummy, 1);
    
    char input;
    while (1) {
        draw_game();
        
        if (read(STDIN_FILENO, &input, 1) > 0) {
            handle_input(input);
        }
        
        update_game();
        usleep(50000); // 50ms delay
    }
    
    restore_terminal();
    return 0;
}