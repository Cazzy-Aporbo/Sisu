#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>

#define MAP_W 60
#define MAP_H 30
#define VIEW_W 40
#define VIEW_H 15

#define NUM_MATH_PROBLEMS 10
#define NUM_DRAGONS 3
#define NUM_TREASURES 5
#define NUM_OBSTACLES 8

typedef struct {
    int x, y;
    int type;
    int solved;
    char problem[50];
    int answer;
} MathProblem;

typedef struct {
    int x, y;
    int type;
    char hint[100];
} Dragon;

typedef struct {
    int x, y;
    int value;
} Treasure;

typedef struct {
    int x, y;
    char challenge[100];
} Obstacle;

MathProblem problems[NUM_MATH_PROBLEMS];
Dragon dragons[NUM_DRAGONS];
Treasure treasures[NUM_TREASURES];
Obstacle obstacles[NUM_OBSTACLES];

int playerX = MAP_W/2, playerY = MAP_H/2;
int score = 0;
int level = 1;
int lives = 3;
int math_skill = 0;
int current_problem = -1;

// Emoji sets
const char *dragon_emoji[] = {"🐉", "🐲", "🦎"};
const char *treasure_emoji[] = {"💎", "🔑", "🏆", "👑", "💰"};
const char *obstacle_emoji[] = {"🌋", "🌊", "🪨", "🔥", "🌪️"};
const char *math_emoji[] = {"➕", "➖", "✖️", "➗"};

// Set terminal to non-blocking mode
void set_nonblocking_mode() {
    struct termios ttystate;
    tcgetattr(STDIN_FILENO, &ttystate);
    ttystate.c_lflag &= ~(ICANON | ECHO);
    ttystate.c_cc[VMIN] = 0;
    ttystate.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSANOW, &ttystate);
}

// Clear screen
void cls() { printf("\033[2J\033[H"); }

// Generate math problems based on level
void generate_math_problems() {
    for (int i = 0; i < NUM_MATH_PROBLEMS; i++) {
        problems[i].x = 5 + rand() % (MAP_W - 10);
        problems[i].y = 5 + rand() % (MAP_H - 10);
        problems[i].type = rand() % 4;
        problems[i].solved = 0;
        
        int a, b;
        switch(level) {
            case 1: // Addition
                a = 1 + rand() % 10;
                b = 1 + rand() % 10;
                problems[i].answer = a + b;
                sprintf(problems[i].problem, "%d + %d = ?", a, b);
                break;
            case 2: // Subtraction
                a = 5 + rand() % 15;
                b = 1 + rand() % (a-1);
                problems[i].answer = a - b;
                sprintf(problems[i].problem, "%d - %d = ?", a, b);
                break;
            case 3: // Multiplication
                a = 1 + rand() % 6;
                b = 1 + rand() % 6;
                problems[i].answer = a * b;
                sprintf(problems[i].problem, "%d × %d = ?", a, b);
                break;
            case 4: // Division
                b = 1 + rand() % 5;
                a = b * (1 + rand() % 6);
                problems[i].answer = a / b;
                sprintf(problems[i].problem, "%d ÷ %d = ?", a, b);
                break;
            default: // Mixed operations
                int op = rand() % 4;
                if (op == 0) {
                    a = 1 + rand() % 15;
                    b = 1 + rand() % 15;
                    problems[i].answer = a + b;
                    sprintf(problems[i].problem, "%d + %d = ?", a, b);
                } else if (op == 1) {
                    a = 5 + rand() % 20;
                    b = 1 + rand() % (a-1);
                    problems[i].answer = a - b;
                    sprintf(problems[i].problem, "%d - %d = ?", a, b);
                } else if (op == 2) {
                    a = 1 + rand() % 8;
                    b = 1 + rand() % 8;
                    problems[i].answer = a * b;
                    sprintf(problems[i].problem, "%d × %d = ?", a, b);
                } else {
                    b = 1 + rand() % 5;
                    a = b * (1 + rand() % 8);
                    problems[i].answer = a / b;
                    sprintf(problems[i].problem, "%d ÷ %d = ?", a, b);
                }
                break;
        }
    }
}

// Initialize game world
void init_world() {
    srand(time(NULL));
    
    // Generate math problems
    generate_math_problems();
    
    // Initialize dragons (Sisu and friends)
    for (int i = 0; i < NUM_DRAGONS; i++) {
        dragons[i].x = 10 + rand() % (MAP_W - 20);
        dragons[i].y = 10 + rand() % (MAP_H - 20);
        dragons[i].type = rand() % 3;
        
        // Dragons give helpful hints
        const char *hints[] = {
            "Remember to take your time and think carefully!",
            "You can use your fingers to count if it helps!",
            "Breaking problems into smaller parts can make them easier!",
            "Practice makes perfect! Keep trying!",
            "Math is like a puzzle - find the right pieces!"
        };
        sprintf(dragons[i].hint, "%s", hints[rand() % 5]);
    }
    
    // Initialize treasures
    for (int i = 0; i < NUM_TREASURES; i++) {
        treasures[i].x = 5 + rand() % (MAP_W - 10);
        treasures[i].y = 5 + rand() % (MAP_H - 10);
        treasures[i].value = 10 * (1 + rand() % 5);
    }
    
    // Initialize obstacles
    for (int i = 0; i < NUM_OBSTACLES; i++) {
        obstacles[i].x = 8 + rand() % (MAP_W - 16);
        obstacles[i].y = 8 + rand() % (MAP_H - 16);
        
        const char *challenges[] = {
            "To pass, solve this: What is 7+5?",
            "To pass, solve this: What is 12-4?",
            "To pass, solve this: What is 3×4?",
            "To pass, solve this: What is 15÷3?",
            "To pass, solve this: What is 8+9?",
            "To pass, solve this: What is 16-7?",
            "To pass, solve this: What is 5×5?",
            "To pass, solve this: What is 18÷2?"
        };
        sprintf(obstacles[i].challenge, "%s", challenges[rand() % 8]);
    }
}

// Draw the viewport
void draw_view() {
    cls();
    printf("🐉 Math Adventure with Sisu - Level %d - Score: %d - Lives: %d\n\n", level, score, lives);
    
    for (int y = 0; y < VIEW_H; y++) {
        for (int x = 0; x < VIEW_W; x++) {
            int wx = playerX - VIEW_W/2 + x;
            int wy = playerY - VIEW_H/2 + y;
            char *c = "  "; // Default empty space

            // Check boundaries
            if (wx < 0 || wx >= MAP_W || wy < 0 || wy >= MAP_H) {
                printf("  ");
                continue;
            }

            // Draw ground with some variation
            if ((wx + wy) % 4 == 0) c = "🌱";
            else if ((wx + wy) % 7 == 0) c = "🌿";
            else c = "  ";

            // Check entities in order of priority
            for (int i = 0; i < NUM_OBSTACLES; i++)
                if (obstacles[i].x == wx && obstacles[i].y == wy) {
                    c = obstacle_emoji[rand() % 5];
                    break;
                }
            
            for (int i = 0; i < NUM_TREASURES; i++)
                if (treasures[i].x == wx && treasures[i].y == wy) {
                    c = treasure_emoji[rand() % 5];
                    break;
                }
            
            for (int i = 0; i < NUM_DRAGONS; i++)
                if (dragons[i].x == wx && dragons[i].y == wy) {
                    c = dragon_emoji[dragons[i].type];
                    break;
                }
            
            for (int i = 0; i < NUM_MATH_PROBLEMS; i++)
                if (problems[i].x == wx && problems[i].y == wy && !problems[i].solved) {
                    c = math_emoji[problems[i].type];
                    break;
                }

            if (wx == playerX && wy == playerY) c = "👦";

            printf("%s", c);
        }
        printf("\n");
    }
    
    printf("\nUse WASD to move, SPACE to interact, Q to quit\n");
    
    // Show current problem if interacting with one
    if (current_problem >= 0) {
        printf("\nMath Problem: %s\n", problems[current_problem].problem);
        printf("Enter your answer: ");
    }
}

// Handle interactions
void interact() {
    // Check for math problems
    for (int i = 0; i < NUM_MATH_PROBLEMS; i++) {
        int dx = abs(problems[i].x - playerX);
        int dy = abs(problems[i].y - playerY);
        if (dx <= 1 && dy <= 1 && !problems[i].solved) {
            current_problem = i;
            return;
        }
    }
    
    // Check for dragons
    for (int i = 0; i < NUM_DRAGONS; i++) {
        int dx = abs(dragons[i].x - playerX);
        int dy = abs(dragons[i].y - playerY);
        if (dx <= 1 && dy <= 1) {
            printf("\nSisu says: %s\n", dragons[i].hint);
            sleep(2);
        }
    }
    
    // Check for treasures
    for (int i = 0; i < NUM_TREASURES; i++) {
        int dx = abs(treasures[i].x - playerX);
        int dy = abs(treasures[i].y - playerY);
        if (dx <= 1 && dy <= 1) {
            printf("\nYou found a treasure worth %d points!\n", treasures[i].value);
            score += treasures[i].value;
            treasures[i].x = -1; // Remove treasure
            treasures[i].y = -1;
            sleep(1);
        }
    }
    
    // Check for obstacles
    for (int i = 0; i < NUM_OBSTACLES; i++) {
        int dx = abs(obstacles[i].x - playerX);
        int dy = abs(obstacles[i].y - playerY);
        if (dx <= 1 && dy <= 1) {
            printf("\n%s\n", obstacles[i].challenge);
            printf("Enter your answer: ");
            
            int answer;
            scanf("%d", &answer);
            
            // Simple obstacle challenges
            if ((obstacles[i].x % 4 == 0 && answer == 12) || // 7+5
                (obstacles[i].x % 4 == 1 && answer == 8) ||  // 12-4
                (obstacles[i].x % 4 == 2 && answer == 12) || // 3×4
                (obstacles[i].x % 4 == 3 && answer == 5) ||  // 15÷3
                (obstacles[i].x % 4 == 0 && answer == 17) || // 8+9
                (obstacles[i].x % 4 == 1 && answer == 9) ||  // 16-7
                (obstacles[i].x % 4 == 2 && answer == 25) || // 5×5
                (obstacles[i].x % 4 == 3 && answer == 9))    // 18÷2
            {
                printf("Correct! You can pass.\n");
                obstacles[i].x = -1; // Remove obstacle
                obstacles[i].y = -1;
                score += 5;
            } else {
                printf("Oops! That's not correct. Try again later.\n");
                lives--;
            }
            sleep(2);
        }
    }
}

// Check if all problems are solved
int check_level_complete() {
    for (int i = 0; i < NUM_MATH_PROBLEMS; i++) {
        if (!problems[i].solved) return 0;
    }
    return 1;
}

// Advance to next level
void next_level() {
    level++;
    math_skill += 10;
    printf("\n🎉 Level Complete! Advancing to Level %d 🎉\n", level);
    printf("Your math skills are improving!\n");
    sleep(2);
    init_world();
}

// Update game state
void update_game() {
    // Check if level is complete
    if (check_level_complete()) {
        next_level();
    }
    
    // Check if player is out of lives
    if (lives <= 0) {
        printf("\nGame Over! You ran out of lives.\n");
        printf("Final Score: %d\n", score);
        exit(0);
    }
}

int main() {
    set_nonblocking_mode();
    init_world();

    char input;
    while (1) {
        draw_view();
        
        // Handle input
        if (read(STDIN_FILENO, &input, 1) > 0) {
            if (input == 'q' || input == 'Q') break;
            
            if (current_problem < 0) {
                // Movement controls
                if (input == 'w' && playerY > 0) playerY--;
                if (input == 's' && playerY < MAP_H - 1) playerY++;
                if (input == 'a' && playerX > 0) playerX--;
                if (input == 'd' && playerX < MAP_W - 1) playerX++;
                if (input == ' ') interact();
            } else {
                // Answering a math problem
                if (input >= '0' && input <= '9') {
                    static char answer_str[10] = "";
                    static int answer_len = 0;
                    
                    if (input == '\n' || input == '\r') {
                        // Submit answer
                        int player_answer = atoi(answer_str);
                        if (player_answer == problems[current_problem].answer) {
                            printf("Correct! +10 points\n");
                            problems[current_problem].solved = 1;
                            score += 10;
                            math_skill += 2;
                        } else {
                            printf("Oops! The correct answer was %d\n", problems[current_problem].answer);
                            lives--;
                        }
                        current_problem = -1;
                        answer_str[0] = '\0';
                        answer_len = 0;
                        sleep(2);
                    } else {
                        // Build answer string
                        if (answer_len < 9) {
                            answer_str[answer_len++] = input;
                            answer_str[answer_len] = '\0';
                        }
                    }
                }
            }
        }

        update_game();
        usleep(100000);  // 100ms delay
    }

    // Restore terminal settings
    struct termios ttystate;
    tcgetattr(STDIN_FILENO, &ttystate);
    ttystate.c_lflag |= (ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &ttystate);

    printf("Thanks for playing! Final Score: %d\n", score);
    return 0;
}