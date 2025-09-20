#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>
#include <math.h>
#include <sys/select.h>

#define MAP_W 80
#define MAP_H 40
#define VIEW_W 50
#define VIEW_H 20

// Psychological principles implemented
#define COGNITIVE_LOAD 0
#define FLOW_STATE 1
#define SPACED_REPETITION 2
#define INTERLEAVED_PRACTICE 3
#define VARIABLE_REWARDS 4
#define SOCIAL_PROOF 5
#define GAMIFICATION 6

// Brain regions with different functions
#define PREFRONTAL 0  // Executive functions
#define PARIETAL 1    // Mathematical processing
#define TEMPORAL 2    // Memory and language
#define OCCIPITAL 3   // Visual processing
#define LIMBIC 4      // Emotional processing

typedef struct {
    int x, y;
    int activation;
    int math_topic;
    char problem[100];
    char solution[50];
    int difficulty;
    int cognitive_principle;
} CognitiveNode;

typedef struct {
    int from_node;
    int to_node;
    int strength;
    int active;
    int principle_applied;
} NeuralPathway;

typedef struct {
    int x, y;
    int type;
    int intensity;
    int duration;
} NeuroModulator;

typedef struct {
    int x, y;
    int region_type;
    char function[100];
    int activation_level;
} BrainRegion;

typedef struct {
    int x, y;
    int focus;
    int math_skill;
    int cognitive_load;
    int flow_state;
    int motivation;
    int anxiety;
    int working_memory;
    long last_math_interaction;
    int problems_solved;
    int streak;
    int total_exposure;
} Player;

// Game state
CognitiveNode nodes[20];
NeuralPathway pathways[40];
NeuroModulator modulators[15];
BrainRegion regions[5];
Player player;

int game_time = 0;
int current_level = 1;
int cognitive_mode = COGNITIVE_LOAD;
int subconscious_math_active = 0;
int subliminal_counter = 0;

// Psychological metrics
double cognitive_efficiency = 1.0;
double learning_rate = 0.05;
double retention_rate = 0.8;

// Visual elements with psychological significance
const char *node_emoji[] = {"🔴", "🟠", "🟡", "🟢", "🔵", "🟣"};
const char *modulator_emoji[] = {"💖", "💛", "💙", "💜", "💚"};
const char *region_emoji[] = {"🧠", "📊", "📝", "👁️", "💖"};
const char *principle_emoji[] = {"📚", "🌊", "🔄", "🎲", "🎁", "👥", "🎮"};
const char *math_emoji[] = {"➕", "➖", "✖️", "➗", "📐", "∫"};

// Function prototypes
void set_nonblocking_mode();
void restore_terminal();
void cls();
void init_game();
void generate_math_content(CognitiveNode *node);
void draw_game();
void handle_input(char input);
void update_game();
void activate_node(int node_index);
void update_psychology();
void apply_cognitive_principle(int principle);
void update_brain_regions();
void release_modulator(int type, int x, int y);
void check_subliminal_math();
void update_learning_metrics();
void show_feedback();
void adjust_difficulty();

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
 * Initialize the game with psychological elements
 */
void init_game() {
    srand(time(NULL));
    
    // Initialize player with psychological metrics
    player.x = MAP_W / 2;
    player.y = MAP_H / 2;
    player.focus = 85;
    player.math_skill = 50;
    player.cognitive_load = 30;
    player.flow_state = 40;
    player.motivation = 75;
    player.anxiety = 20;
    player.working_memory = 70;
    player.last_math_interaction = 0;
    player.problems_solved = 0;
    player.streak = 0;
    player.total_exposure = 0;
    
    // Initialize brain regions
    char *region_functions[] = {
        "Executive Control & Decision Making",
        "Mathematical Reasoning & Logic",
        "Memory Encoding & Recall", 
        "Visual-Spatial Processing",
        "Emotional Regulation & Motivation"
    };
    
    for (int i = 0; i < 5; i++) {
        regions[i].x = 15 + rand() % (MAP_W - 30);
        regions[i].y = 10 + rand() % (MAP_H - 20);
        regions[i].region_type = i;
        regions[i].activation_level = 40 + rand() % 40;
        strcpy(regions[i].function, region_functions[i]);
    }
    
    // Initialize cognitive nodes
    for (int i = 0; i < 20; i++) {
        nodes[i].x = 5 + rand() % (MAP_W - 10);
        nodes[i].y = 5 + rand() % (MAP_H - 10);
        nodes[i].activation = 0;
        nodes[i].math_topic = rand() % 6;
        nodes[i].difficulty = 1 + (i % 5);
        nodes[i].cognitive_principle = rand() % 7;
        generate_math_content(&nodes[i]);
    }
    
    // Initialize neural pathways
    for (int i = 0; i < 40; i++) {
        pathways[i].from_node = rand() % 20;
        pathways[i].to_node = rand() % 20;
        pathways[i].strength = 20 + rand() % 80;
        pathways[i].active = 0;
        pathways[i].principle_applied = rand() % 7;
    }
    
    // Initialize neuro modulators
    for (int i = 0; i < 15; i++) {
        modulators[i].x = rand() % MAP_W;
        modulators[i].y = rand() % MAP_H;
        modulators[i].type = rand() % 5;
        modulators[i].intensity = 30 + rand() % 70;
        modulators[i].duration = 50 + rand() % 100;
    }
}

/**
 * Generate math content for cognitive nodes
 */
void generate_math_content(CognitiveNode *node) {
    int a, b, c;
    double result;
    
    switch (node->math_topic) {
        case 0: // Addition
            a = 10 + rand() % 90;
            b = 10 + rand() % 90;
            sprintf(node->problem, "%d + %d", a, b);
            sprintf(node->solution, "%d", a + b);
            break;
        case 1: // Subtraction
            a = 50 + rand() % 50;
            b = 10 + rand() % 40;
            sprintf(node->problem, "%d - %d", a, b);
            sprintf(node->solution, "%d", a - b);
            break;
        case 2: // Multiplication
            a = 2 + rand() % 12;
            b = 2 + rand() % 12;
            sprintf(node->problem, "%d × %d", a, b);
            sprintf(node->solution, "%d", a * b);
            break;
        case 3: // Division
            b = 2 + rand() % 10;
            a = b * (2 + rand() % 10);
            sprintf(node->problem, "%d ÷ %d", a, b);
            sprintf(node->solution, "%d", a / b);
            break;
        case 4: // Fractions
            a = 1 + rand() % 8;
            b = a + rand() % 8 + 1;
            int gcd = 1;
            for (int i = 1; i <= a && i <= b; i++) {
                if (a % i == 0 && b % i == 0) gcd = i;
            }
            sprintf(node->problem, "Simplify %d/%d", a, b);
            sprintf(node->solution, "%d/%d", a/gcd, b/gcd);
            break;
        case 5: // Percentages
            a = 5 * (1 + rand() % 19); // 5, 10, 15, ..., 95
            b = 10 + rand() % 90;
            result = (a * b) / 100.0;
            sprintf(node->problem, "%d%% of %d", a, b);
            sprintf(node->solution, "%.0f", result);
            break;
    }
}

/**
 * Draw the game interface with psychological elements
 */
void draw_game() {
    cls();
    
    // Draw header with psychological metrics
    printf("🧠 PsyMath: Cognitive Fusion Training | Level: %d | Mode: %s\n\n", 
           current_level, principle_emoji[cognitive_mode]);
    
    printf("Focus: %d%% | Math Skill: %d | Flow: %d | Motivation: %d | Anxiety: %d\n\n", 
           player.focus, player.math_skill, player.flow_state, 
           player.motivation, player.anxiety);
    
    // Draw the cognitive landscape
    for (int y = 0; y < VIEW_H; y++) {
        for (int x = 0; x < VIEW_W; x++) {
            int wx = player.x - VIEW_W/2 + x;
            int wy = player.y - VIEW_H/2 + y;
            const char *c = "  "; // Default empty space
            
            // Check boundaries
            if (wx < 0 || wx >= MAP_W || wy < 0 || wy >= MAP_H) {
                printf("  ");
                continue;
            }
            
            // Draw cognitive background pattern (subtle neural network)
            int pattern_val = (wx * 7 + wy * 13) % 20;
            if (pattern_val == 0) c = "· ";
            else if (pattern_val == 1) c = "• ";
            
            // Draw neural pathways
            for (int i = 0; i < 40; i++) {
                if (pathways[i].active) {
                    int from_x = nodes[pathways[i].from_node].x;
                    int from_y = nodes[pathways[i].from_node].y;
                    int to_x = nodes[pathways[i].to_node].x;
                    int to_y = nodes[pathways[i].to_node].y;
                    
                    // Check if point is near the line between nodes
                    if (abs((to_y - from_y) * wx - (to_x - from_x) * wy + 
                            to_x * from_y - to_y * from_x) < 30) {
                        c = "▬ ";
                        break;
                    }
                }
            }
            
            // Draw neuro modulators
            for (int i = 0; i < 15; i++) {
                if (modulators[i].x == wx && modulators[i].y == wy && modulators[i].duration > 0) {
                    c = modulator_emoji[modulators[i].type];
                    break;
                }
            }
            
            // Draw brain regions
            for (int i = 0; i < 5; i++) {
                if (regions[i].x == wx && regions[i].y == wy) {
                    c = region_emoji[regions[i].region_type];
                    break;
                }
            }
            
            // Draw cognitive nodes
            for (int i = 0; i < 20; i++) {
                if (nodes[i].x == wx && nodes[i].y == wy) {
                    if (nodes[i].activation > 0) {
                        c = "⚡"; // Activated node
                    } else {
                        c = node_emoji[nodes[i].cognitive_principle];
                    }
                    break;
                }
            }
            
            // Draw player
            if (wx == player.x && wy == player.y) {
                c = "👤";
            }
            
            printf("%s", c);
        }
        printf("\n");
    }
    
    // Draw footer with controls and status
    printf("\nControls: WASD to move | SPACE to interact | 1-7 to change cognitive mode\n");
    printf("Modes: %s Load | %s Flow | %s Repetition | %s Interleaving | %s Rewards | %s Social | %s Game\n", 
           principle_emoji[0], principle_emoji[1], principle_emoji[2], 
           principle_emoji[3], principle_emoji[4], principle_emoji[5], principle_emoji[6]);
    
    // Show subliminal math if active
    if (subliminal_counter > 0 && game_time % 5 == 0) {
        int node_idx = rand() % 20;
        printf("\n\t  %s", nodes[node_idx].problem);
        subliminal_counter--;
    }
    
    // Show psychological feedback periodically
    if (game_time % 100 == 0) {
        show_feedback();
    }
}

/**
 * Show psychological feedback based on player state
 */
void show_feedback() {
    if (player.flow_state > 70) {
        printf("\n🌟 You're in a state of flow! Learning efficiency increased.");
    } else if (player.anxiety > 60) {
        printf("\n😰 High cognitive anxiety! Try switching to a different mode.");
    } else if (player.motivation < 40) {
        printf("\n💤 Motivation low! Collect modulators to boost engagement.");
    } else if (player.streak > 5) {
        printf("\n🔥 Learning streak! Keep going for maximum retention.");
    }
}

/**
 * Handle user input
 */
void handle_input(char input) {
    switch (input) {
        case 'w': if (player.y > 0) player.y--; break;
        case 's': if (player.y < MAP_H - 1) player.y++; break;
        case 'a': if (player.x > 0) player.x--; break;
        case 'd': if (player.x < MAP_W - 1) player.x++; break;
        case ' ': 
            // Interact with nearby nodes
            for (int i = 0; i < 20; i++) {
                if (abs(nodes[i].x - player.x) <= 2 && 
                    abs(nodes[i].y - player.y) <= 2) {
                    activate_node(i);
                    break;
                }
            }
            break;
        case '1': cognitive_mode = COGNITIVE_LOAD; break;
        case '2': cognitive_mode = FLOW_STATE; break;
        case '3': cognitive_mode = SPACED_REPETITION; break;
        case '4': cognitive_mode = INTERLEAVED_PRACTICE; break;
        case '5': cognitive_mode = VARIABLE_REWARDS; break;
        case '6': cognitive_mode = SOCIAL_PROOF; break;
        case '7': cognitive_mode = GAMIFICATION; break;
        case 'q':
            printf("Cognitive training session complete!\n");
            printf("Math problems solved: %d | Total math exposure: %d\n", 
                   player.problems_solved, player.total_exposure);
            restore_terminal();
            exit(0);
    }
    
    // Apply the selected cognitive principle
    apply_cognitive_principle(cognitive_mode);
}

/**
 * Activate a cognitive node (engage with math content)
 */
void activate_node(int node_index) {
    CognitiveNode *node = &nodes[node_index];
    
    if (node->activation > 0) {
        printf("This node is already active!\n");
        return;
    }
    
    // Switch to blocking mode for input
    restore_terminal();
    
    // Present the math problem based on cognitive principle
    if (cognitive_mode == SPACED_REPETITION) {
        printf("\n🔁 Spaced Repetition: %s = ?\n", node->problem);
    } else if (cognitive_mode == INTERLEAVED_PRACTICE) {
        printf("\n🔄 Interleaved Practice: %s = ?\n", node->problem);
    } else if (cognitive_mode == VARIABLE_REWARDS) {
        printf("\n🎲 Variable Reward: %s = ?\n", node->problem);
    } else {
        printf("\n%s %s = ?\n", math_emoji[node->math_topic], node->problem);
    }
    
    printf("Enter your answer: ");
    
    char answer[50];
    fgets(answer, 50, stdin);
    answer[strcspn(answer, "\n")] = 0;
    
    // Set back to non-blocking mode
    set_nonblocking_mode();
    
    if (strcmp(answer, node->solution) == 0) {
        printf("✅ Correct! Cognitive pathway strengthened!\n");
        node->activation = 100;
        player.math_skill += node->difficulty * 2;
        player.problems_solved++;
        player.streak++;
        player.last_math_interaction = game_time;
        
        // Reward based on cognitive mode
        switch (cognitive_mode) {
            case VARIABLE_REWARDS:
                player.motivation += 10 + rand() % 20; // Variable reward
                break;
            case GAMIFICATION:
                player.motivation += 15;
                player.focus += 10;
                break;
            case SOCIAL_PROOF:
                player.motivation += 12;
                printf("👥 87%% of users solved this correctly!\n");
                break;
            default:
                player.motivation += 8;
                break;
        }
        
        // Form new neural pathways
        for (int i = 0; i < 3; i++) {
            int random_node = rand() % 20;
            if (random_node != node_index) {
                for (int j = 0; j < 40; j++) {
                    if (!pathways[j].active) {
                        pathways[j].from_node = node_index;
                        pathways[j].to_node = random_node;
                        pathways[j].strength = 50;
                        pathways[j].active = 1;
                        pathways[j].principle_applied = cognitive_mode;
                        break;
                    }
                }
            }
        }
        
        // Release positive neuro modulators
        release_modulator(0, player.x, player.y); // Dopamine-like
        release_modulator(1, player.x, player.y); // Serotonin-like
        
    } else {
        printf("❌ Incorrect. The answer was %s. Try again!\n", node->solution);
        player.streak = 0;
        player.anxiety += 10;
        
        // Release stress modulators
        release_modulator(4, player.x, player.y); // Cortisol-like
    }
    
    player.total_exposure++;
    usleep(1500000); // Pause to show feedback
}

/**
 * Apply the selected cognitive principle
 */
void apply_cognitive_principle(int principle) {
    switch (principle) {
        case COGNITIVE_LOAD:
            player.cognitive_load = 60 + rand() % 30;
            player.focus = 80;
            subconscious_math_active = 1;
            break;
        case FLOW_STATE:
            if (player.math_skill > 40 && player.focus > 70) {
                player.flow_state = 80;
                cognitive_efficiency = 1.5;
            }
            break;
        case SPACED_REPETITION:
            // Reactivate previously solved nodes
            for (int i = 0; i < 20; i++) {
                if (nodes[i].activation == 0 && rand() % 5 == 0) {
                    nodes[i].activation = 30;
                }
            }
            break;
        case INTERLEAVED_PRACTICE:
            // Mix up math topics
            for (int i = 0; i < 20; i++) {
                if (rand() % 10 == 0) {
                    nodes[i].math_topic = rand() % 6;
                    generate_math_content(&nodes[i]);
                }
            }
            break;
        case VARIABLE_REWARDS:
            // Randomly boost motivation
            if (rand() % 5 == 0) {
                player.motivation += 15 + rand() % 20;
                printf("🎁 Unexpected reward! Motivation boosted.\n");
            }
            break;
    }
}

/**
 * Release a neuro modulator at the specified position
 */
void release_modulator(int type, int x, int y) {
    for (int i = 0; i < 15; i++) {
        if (modulators[i].duration <= 0) {
            modulators[i].x = x;
            modulators[i].y = y;
            modulators[i].type = type;
            modulators[i].intensity = 40 + rand() % 60;
            modulators[i].duration = 80 + rand() % 120;
            break;
        }
    }
}

/**
 * Update game state with psychological principles
 */
void update_game() {
    game_time++;
    
    // Update psychological metrics
    update_psychology();
    
    // Update brain regions based on activity
    update_brain_regions();
    
    // Check for subliminal math exposure
    check_subliminal_math();
    
    // Update learning metrics based on psychological state
    update_learning_metrics();
    
    // Adjust difficulty based on player performance
    adjust_difficulty();
    
    // Update neuro modulators
    for (int i = 0; i < 15; i++) {
        if (modulators[i].duration > 0) {
            modulators[i].duration--;
            
            // Apply modulator effects when player is near
            if (abs(modulators[i].x - player.x) < 3 && 
                abs(modulators[i].y - player.y) < 3) {
                switch (modulators[i].type) {
                    case 0: // Dopamine-like
                        player.motivation += 2;
                        player.focus += 1;
                        break;
                    case 1: // Serotonin-like
                        player.anxiety -= 2;
                        player.flow_state += 1;
                        break;
                    case 2: // Acetylcholine-like
                        player.focus += 3;
                        player.working_memory += 2;
                        break;
                    case 3: // GABA-like
                        player.anxiety -= 3;
                        player.cognitive_load -= 2;
                        break;
                    case 4: // Cortisol-like
                        player.anxiety += 2;
                        player.focus -= 1;
                        break;
                }
            }
        }
    }
    
    // Update node activation levels
    for (int i = 0; i < 20; i++) {
        if (nodes[i].activation > 0) {
            nodes[i].activation--;
        }
    }
    
    // Check for cognitive overload
    if (player.cognitive_load > 90 && player.anxiety > 70) {
        printf("\n💥 Cognitive overload! Taking a break...\n");
        player.cognitive_load = 40;
        player.anxiety = 30;
        usleep(2000000);
    }
    
    // Check for level advancement
    if (player.problems_solved >= current_level * 5) {
        current_level++;
        printf("\n🎉 Level Up! Advanced to level %d\n", current_level);
        player.motivation += 20;
        player.math_skill += 10;
    }
}

/**
 * Update psychological metrics based on game state
 */
void update_psychology() {
    // Focus naturally decreases but can be maintained with engagement
    player.focus -= 1;
    if (player.focus < 0) player.focus = 0;
    if (player.focus > 100) player.focus = 100;
    
    // Flow state requires balance of challenge and skill
    if (player.cognitive_load > 40 && player.cognitive_load < 80 && 
        player.math_skill > 30 && player.focus > 60) {
        player.flow_state += 2;
    } else {
        player.flow_state -= 1;
    }
    if (player.flow_state < 0) player.flow_state = 0;
    if (player.flow_state > 100) player.flow_state = 100;
    
    // Motivation fluctuates based on success and rewards
    player.motivation -= 1;
    if (player.motivation < 0) player.motivation = 0;
    if (player.motivation > 100) player.motivation = 100;
    
    // Anxiety increases with cognitive load and decreases with success
    player.anxiety += (player.cognitive_load / 30) - (player.streak / 5);
    if (player.anxiety < 0) player.anxiety = 0;
    if (player.anxiety > 100) player.anxiety = 100;
    
    // Working memory is affected by cognitive load and anxiety
    player.working_memory = 80 - (player.cognitive_load / 4) - (player.anxiety / 5);
    if (player.working_memory < 20) player.working_memory = 20;
    if (player.working_memory > 100) player.working_memory = 100;
}

/**
 * Update brain region activation based on player activity
 */
void update_brain_regions() {
    // Prefrontal cortex (executive functions)
    regions[PREFRONTAL].activation_level = player.focus;
    
    // Parietal cortex (mathematical processing)
    regions[PARIETAL].activation_level = player.math_skill;
    
    // Temporal cortex (memory)
    regions[TEMPORAL].activation_level = player.working_memory;
    
    // Occipital cortex (visual processing)
    regions[OCCIPITAL].activation_level = 60 + rand() % 40;
    
    // Limbic system (emotional processing)
    regions[LIMBIC].activation_level = (player.motivation + player.anxiety) / 2;
}

/**
 * Check for subliminal math exposure opportunities
 */
void check_subliminal_math() {
    // Show subliminal math problems when in high cognitive load
    if (player.cognitive_load > 70 && game_time % 30 == 0) {
        subliminal_counter = 3;
    }
    
    // Automatic math exposure when not actively solving problems
    if (game_time - player.last_math_interaction > 100) {
        player.total_exposure++;
        player.last_math_interaction = game_time;
        
        // Occasionally activate a random node
        if (rand() % 10 == 0) {
            int random_node = rand() % 20;
            nodes[random_node].activation = 30;
        }
    }
}

/**
 * Update learning metrics based on psychological state
 */
void update_learning_metrics() {
    // Cognitive efficiency is highest in flow state
    cognitive_efficiency = 0.8 + (player.flow_state / 100.0) * 0.7;
    
    // Learning rate improves with focus and motivation
    learning_rate = 0.03 + (player.focus / 100.0) * 0.04 + 
                   (player.motivation / 100.0) * 0.03;
    
    // Retention improves with spaced repetition and lower anxiety
    retention_rate = 0.6 + (player.working_memory / 100.0) * 0.4 - 
                   (player.anxiety / 100.0) * 0.2;
    
    // Apply learning to math skill
    player.math_skill += learning_rate * cognitive_efficiency;
    if (player.math_skill > 100) player.math_skill = 100;
}

/**
 * Adjust difficulty based on player performance
 */
void adjust_difficulty() {
    // Increase difficulty as math skill improves
    int target_difficulty = player.math_skill / 20;
    if (target_difficulty < 1) target_difficulty = 1;
    if (target_difficulty > 5) target_difficulty = 5;
    
    // Adjust node difficulties
    for (int i = 0; i < 20; i++) {
        if (rand() % 20 == 0) { // Occasionally adjust nodes
            nodes[i].difficulty = target_difficulty;
            generate_math_content(&nodes[i]);
        }
    }
}

/**
 * Main game loop
 */
int main() {
    set_nonblocking_mode();
    init_game();
    
    printf("🧠 Welcome to PsyMath: Cognitive Fusion Training\n\n");
    printf("This system uses advanced psychological principles to enhance\n");
    printf("math learning through cognitive engagement and subliminal exposure.\n\n");
    printf("Psychological principles implemented:\n");
    printf("• Cognitive Load Theory\n• Flow State Psychology\n• Spaced Repetition\n");
    printf("• Interleaved Practice\n• Variable Rewards\n• Social Proof\n• Gamification\n\n");
    printf("Press any key to begin your cognitive training session...");
    
    char dummy;
    read(STDIN_FILENO, &dummy, 1);
    
    char input;
    while (1) {
        draw_game();
        
        if (read(STDIN_FILENO, &input, 1) > 0) {
            handle_input(input);
        }
        
        update_game();
        usleep(100000); // 100ms delay
    }
    
    restore_terminal();
    return 0;
}