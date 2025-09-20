#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>
#include <math.h>

#define MAP_W 80
#define MAP_H 40
#define VIEW_W 50
#define VIEW_H 20

#define NUM_NEURONS 15
#define NUM_SYNAPSES 30
#define NUM_NEUROTRANSMITTERS 10
#define NUM_BRAIN_REGIONS 5

// Brain wave states for different learning modes
#define ALPHA 0    // Relaxed learning
#define BETA 1     // Focused problem-solving
#define THETA 2    // Creative insight
#define GAMMA 3    // Peak performance

typedef struct {
    int x, y;
    int activation;
    int math_topic;  // 0=arithmetic, 1=algebra, 2=geometry, 3=calculus
    char problem[100];
    char solution[50];
    int difficulty;
} Neuron;

typedef struct {
    int from_neuron;
    int to_neuron;
    int strength;
    int active;
} Synapse;

typedef struct {
    int x, y;
    int type;  // 0=dopamine, 1=serotonin, 2=acetylcholine, 3=GABA
    int effect; // Positive or negative effect on learning
} Neurotransmitter;

typedef struct {
    int x, y;
    int region_type; // 0=prefrontal, 1=parietal, 2=temporal, 3=occipital, 4=limbic
    char function[100];
} BrainRegion;

typedef struct {
    int x, y;
    int focus_level;
    int math_ability;
    int brain_state;
    int neurotransmitters[4];
    int active_neurons;
    int solved_problems;
    int learning_streak;
} Player;

// Game state
Neuron neurons[NUM_NEURONS];
Synapse synapses[NUM_SYNAPSES];
Neurotransmitter neurotransmitters[NUM_NEUROTRANSMITTERS];
BrainRegion regions[NUM_BRAIN_REGIONS];
Player player;

int game_time = 0;
int current_level = 1;
int brain_wave_state = ALPHA;

// Visual elements
const char *neuron_emoji[] = {"🔴", "🟠", "🟡", "🟢", "🔵", "🟣", "🟤", "⚫", "⚪"};
const char *nt_emoji[] = {"💖", "💛", "💙", "💜"};
const char *region_emoji[] = {"🧠", "📊", "📐", "🔍", "💞"};
const char *state_emoji[] = {"😌", "🤔", "💡", "🚀"};
const char *topic_emoji[] = {"➕", "📈", "△", "∫"};

// Psychology-based learning parameters
const double learning_rates[] = {1.2, 1.0, 0.8, 1.5}; // Alpha, Beta, Theta, Gamma
const int focus_drain_rates[] = {1, 2, 3, 4};
const int ability_gain_rates[] = {2, 3, 1, 5};

// Function prototypes
void set_nonblocking_mode();
void restore_terminal();
void cls();
void init_game();
void generate_math_problem(Neuron *neuron);
void draw_game();
void handle_input(char input);
void update_game();
void activate_neuron(int neuron_index);
void form_synapse(int from, int to);
void release_neurotransmitter(int type, int x, int y);
void change_brain_state(int new_state);
void show_learning_tip();
void update_psychology_stats();

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
 * Initialize the game world with neuroscience-inspired elements
 */
void init_game() {
    srand(time(NULL));
    
    // Initialize player
    player.x = MAP_W / 2;
    player.y = MAP_H / 2;
    player.focus_level = 100;
    player.math_ability = 50;
    player.brain_state = ALPHA;
    player.active_neurons = 0;
    player.solved_problems = 0;
    player.learning_streak = 0;
    for (int i = 0; i < 4; i++) player.neurotransmitters[i] = 10;
    
    // Initialize brain regions
    char *region_functions[] = {
        "Executive Functions & Problem Solving",
        "Mathematical Processing & Logic",
        "Memory & Pattern Recognition", 
        "Visual-Spatial Processing",
        "Emotional Regulation & Motivation"
    };
    
    for (int i = 0; i < NUM_BRAIN_REGIONS; i++) {
        regions[i].x = 10 + rand() % (MAP_W - 20);
        regions[i].y = 10 + rand() % (MAP_H - 20);
        regions[i].region_type = i;
        strcpy(regions[i].function, region_functions[i]);
    }
    
    // Initialize neurons with math problems
    for (int i = 0; i < NUM_NEURONS; i++) {
        neurons[i].x = 5 + rand() % (MAP_W - 10);
        neurons[i].y = 5 + rand() % (MAP_H - 10);
        neurons[i].activation = 0;
        neurons[i].math_topic = rand() % 4;
        neurons[i].difficulty = 1 + (i % 4);
        generate_math_problem(&neurons[i]);
    }
    
    // Initialize synapses between neurons
    for (int i = 0; i < NUM_SYNAPSES; i++) {
        synapses[i].from_neuron = rand() % NUM_NEURONS;
        synapses[i].to_neuron = rand() % NUM_NEURONS;
        synapses[i].strength = 10 + rand() % 90;
        synapses[i].active = 0;
    }
    
    // Initialize neurotransmitters
    for (int i = 0; i < NUM_NEUROTRANSMITTERS; i++) {
        neurotransmitters[i].x = rand() % MAP_W;
        neurotransmitters[i].y = rand() % MAP_H;
        neurotransmitters[i].type = rand() % 4;
        neurotransmitters[i].effect = (rand() % 2) * 2 - 1; // -1 or 1
    }
}

/**
 * Generate math problems based on topic and difficulty
 */
void generate_math_problem(Neuron *neuron) {
    int a, b, c;
    double result;
    
    switch (neuron->math_topic) {
        case 0: // Arithmetic
            switch (neuron->difficulty) {
                case 1:
                    a = 1 + rand() % 20;
                    b = 1 + rand() % 20;
                    sprintf(neuron->problem, "What is %d + %d?", a, b);
                    sprintf(neuron->solution, "%d", a + b);
                    break;
                case 2:
                    a = 10 + rand() % 40;
                    b = 10 + rand() % 40;
                    sprintf(neuron->problem, "What is %d - %d?", a, b);
                    sprintf(neuron->solution, "%d", a - b);
                    break;
                case 3:
                    a = 2 + rand() % 10;
                    b = 2 + rand() % 10;
                    sprintf(neuron->problem, "What is %d × %d?", a, b);
                    sprintf(neuron->solution, "%d", a * b);
                    break;
                case 4:
                    b = 2 + rand() % 8;
                    a = b * (2 + rand() % 10);
                    sprintf(neuron->problem, "What is %d ÷ %d?", a, b);
                    sprintf(neuron->solution, "%d", a / b);
                    break;
            }
            break;
            
        case 1: // Algebra
            switch (neuron->difficulty) {
                case 1:
                    a = 2 + rand() % 8;
                    b = 5 + rand() % 15;
                    sprintf(neuron->problem, "If x + %d = %d, what is x?", a, b);
                    sprintf(neuron->solution, "%d", b - a);
                    break;
                case 2:
                    a = 2 + rand() % 5;
                    b = 10 + rand() % 20;
                    sprintf(neuron->problem, "If %dx = %d, what is x?", a, b);
                    sprintf(neuron->solution, "%d", b / a);
                    break;
                case 3:
                    a = 3 + rand() % 5;
                    b = 5 + rand() % 10;
                    c = 15 + rand() % 30;
                    sprintf(neuron->problem, "Solve: %dx + %d = %d", a, b, c);
                    sprintf(neuron->solution, "%d", (c - b) / a);
                    break;
                case 4:
                    a = 2 + rand() % 4;
                    b = 5 + rand() % 10;
                    c = 3 + rand() % 7;
                    sprintf(neuron->problem, "Solve: %d(x + %d) = %d", a, b, c);
                    sprintf(neuron->solution, "%d", (c / a) - b);
                    break;
            }
            break;
            
        case 2: // Geometry
            switch (neuron->difficulty) {
                case 1:
                    a = 3 + rand() % 10;
                    sprintf(neuron->problem, "What is the area of a square with side %d?", a);
                    sprintf(neuron->solution, "%d", a * a);
                    break;
                case 2:
                    a = 3 + rand() % 10;
                    b = 5 + rand() % 15;
                    sprintf(neuron->problem, "What is the area of a rectangle %d by %d?", a, b);
                    sprintf(neuron->solution, "%d", a * b);
                    break;
                case 3:
                    a = 5 + rand() % 10;
                    sprintf(neuron->problem, "What is the circumference of a circle with radius %d? (Use π=3.14)", a);
                    sprintf(neuron->solution, "%.2f", 2 * 3.14 * a);
                    break;
                case 4:
                    a = 5 + rand() % 10;
                    sprintf(neuron->problem, "What is the area of a circle with radius %d? (Use π=3.14)", a);
                    sprintf(neuron->solution, "%.2f", 3.14 * a * a);
                    break;
            }
            break;
            
        case 3: // Calculus concepts
            switch (neuron->difficulty) {
                case 1:
                    a = 2 + rand() % 5;
                    sprintf(neuron->problem, "What is the derivative of %dx?", a);
                    sprintf(neuron->solution, "%d", a);
                    break;
                case 2:
                    a = 2 + rand() % 5;
                    b = 3 + rand() % 7;
                    sprintf(neuron->problem, "What is the derivative of %dx²?", a);
                    sprintf(neuron->solution, "%dx", 2 * a);
                    break;
                case 3:
                    a = 1 + rand() % 5;
                    b = 2 + rand() % 8;
                    sprintf(neuron->problem, "What is the integral of %d?", a);
                    sprintf(neuron->solution, "%dx", a);
                    break;
                case 4:
                    a = 2 + rand() % 5;
                    sprintf(neuron->problem, "What is the integral of %dx?", a);
                    sprintf(neuron->solution, "%dx²", a/2);
                    break;
            }
            break;
    }
}

/**
 * Draw the game interface with neuroscience-inspired visuals
 */
void draw_game() {
    cls();
    
    // Draw header with brain state and stats
    printf("🧠 NeuroMath: Brain-Inspired Learning | Level: %d | State: %s\n\n", 
           current_level, state_emoji[brain_wave_state]);
    
    printf("Focus: %d%% | Math Ability: %d | Neurons: %d/%d | Streak: %d\n\n", 
           player.focus_level, player.math_ability, player.active_neurons, 
           NUM_NEURONS, player.learning_streak);
    
    // Draw the neural network view
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
            
            // Draw neural background pattern
            if ((wx + wy) % 4 == 0) c = "· ";
            if ((wx + wy) % 7 == 0) c = "• ";
            
            // Draw synapses (neural connections)
            for (int i = 0; i < NUM_SYNAPSES; i++) {
                if (synapses[i].active) {
                    int from_x = neurons[synapses[i].from_neuron].x;
                    int from_y = neurons[synapses[i].from_neuron].y;
                    int to_x = neurons[synapses[i].to_neuron].x;
                    int to_y = neurons[synapses[i].to_neuron].y;
                    
                    // Simple line drawing algorithm
                    if (abs(wx - from_x) < 2 && abs(wy - from_y) < 2 && 
                        abs(wx - to_x) < 2 && abs(wy - to_y) < 2) {
                        c = "▬ ";
                        break;
                    }
                }
            }
            
            // Draw neurotransmitters
            for (int i = 0; i < NUM_NEUROTRANSMITTERS; i++) {
                if (neurotransmitters[i].x == wx && neurotransmitters[i].y == wy) {
                    c = nt_emoji[neurotransmitters[i].type];
                    break;
                }
            }
            
            // Draw brain regions
            for (int i = 0; i < NUM_BRAIN_REGIONS; i++) {
                if (regions[i].x == wx && regions[i].y == wy) {
                    c = region_emoji[regions[i].region_type];
                    break;
                }
            }
            
            // Draw neurons
            for (int i = 0; i < NUM_NEURONS; i++) {
                if (neurons[i].x == wx && neurons[i].y == wy) {
                    if (neurons[i].activation > 0) {
                        c = "⚡"; // Activated neuron
                    } else {
                        c = neuron_emoji[neurons[i].math_topic];
                    }
                    break;
                }
            }
            
            // Draw player
            if (wx == player.x && wy == player.y) {
                c = "👨‍🔬";
            }
            
            printf("%s", c);
        }
        printf("\n");
    }
    
    // Draw footer with controls and status
    printf("\nControls: WASD to move | SPACE to interact | 1-4 to change brain state\n");
    printf("Brain States: %s Relaxed | %s Focused | %s Creative | %s Peak\n", 
           state_emoji[ALPHA], state_emoji[BETA], state_emoji[THETA], state_emoji[GAMMA]);
    
    // Show learning tips periodically
    if (game_time % 50 == 0) {
        show_learning_tip();
    }
}

/**
 * Display psychology-based learning tips
 */
void show_learning_tip() {
    const char *tips[] = {
        "💡 Tip: Taking breaks improves memory consolidation!",
        "💡 Tip: Varying your study methods strengthens neural pathways!",
        "💡 Tip: Teaching concepts to others enhances your own understanding!",
        "💡 Tip: Sleep is essential for solidifying learning!",
        "💡 Tip: Challenging problems create stronger neural connections!",
        "💡 Tip: Mistakes are opportunities for brain growth!",
        "💡 Tip: Physical exercise boosts brain function and learning!",
        "💡 Tip: Curiosity activates the brain's reward system!",
    };
    
    printf("\n%s\n", tips[rand() % 8]);
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
            // Interact with nearby neurons
            for (int i = 0; i < NUM_NEURONS; i++) {
                if (abs(neurons[i].x - player.x) <= 2 && 
                    abs(neurons[i].y - player.y) <= 2) {
                    activate_neuron(i);
                    break;
                }
            }
            break;
        case '1': change_brain_state(ALPHA); break;
        case '2': change_brain_state(BETA); break;
        case '3': change_brain_state(THETA); break;
        case '4': change_brain_state(GAMMA); break;
        case 'q':
            printf("Thanks for playing NeuroMath!\n");
            restore_terminal();
            exit(0);
    }
}

/**
 * Activate a neuron (solve a math problem)
 */
void activate_neuron(int neuron_index) {
    Neuron *neuron = &neurons[neuron_index];
    
    if (neuron->activation > 0) {
        printf("This neuron is already active!\n");
        return;
    }
    
    printf("\n🧠 Math Challenge: %s\n", neuron->problem);
    printf("Enter your answer: ");
    
    // Switch to blocking mode for input
    restore_terminal();
    
    char answer[50];
    fgets(answer, 50, stdin);
    answer[strcspn(answer, "\n")] = 0;
    
    // Set back to non-blocking mode
    set_nonblocking_mode();
    
    if (strcmp(answer, neuron->solution) == 0) {
        printf("✅ Correct! Neural pathway strengthened!\n");
        neuron->activation = 100;
        player.math_ability += neuron->difficulty * 2;
        player.solved_problems++;
        player.learning_streak++;
        
        // Reward with neurotransmitters based on brain state
        player.neurotransmitters[brain_wave_state] += 5;
        
        // Form new synapses
        for (int i = 0; i < 3; i++) {
            int random_neuron = rand() % NUM_NEURONS;
            if (random_neuron != neuron_index) {
                form_synapse(neuron_index, random_neuron);
            }
        }
        
        // Check for level completion
        player.active_neurons++;
        if (player.active_neurons >= NUM_NEURONS) {
            current_level++;
            printf("\n🎉 Level Complete! Brain connectivity increased! 🎉\n");
            init_game(); // Reset for next level
        }
    } else {
        printf("❌ Incorrect. The answer was %s. Try again!\n", neuron->solution);
        player.focus_level -= 10;
        player.learning_streak = 0;
    }
    
    usleep(1500000); // Pause to show feedback
}

/**
 * Form a synapse between two neurons
 */
void form_synapse(int from, int to) {
    for (int i = 0; i < NUM_SYNAPSES; i++) {
        if (!synapses[i].active) {
            synapses[i].from_neuron = from;
            synapses[i].to_neuron = to;
            synapses[i].strength = 50;
            synapses[i].active = 1;
            break;
        }
    }
}

/**
 * Change the player's brain wave state
 */
void change_brain_state(int new_state) {
    brain_wave_state = new_state;
    printf("\nBrain state changed to: ");
    switch (new_state) {
        case ALPHA: printf("Relaxed Learning (α)\n"); break;
        case BETA: printf("Focused Problem-Solving (β)\n"); break;
        case THETA: printf("Creative Insight (θ)\n"); break;
        case GAMMA: printf("Peak Performance (γ)\n"); break;
    }
}

/**
 * Update game state based on psychology principles
 */
void update_game() {
    game_time++;
    
    // Update focus level based on brain state
    player.focus_level -= focus_drain_rates[brain_wave_state];
    if (player.focus_level < 0) player.focus_level = 0;
    if (player.focus_level > 100) player.focus_level = 100;
    
    // Gradually increase math ability based on learning
    if (game_time % 30 == 0) {
        player.math_ability += ability_gain_rates[brain_wave_state] * 
                              (1 + player.learning_streak / 5);
        if (player.math_ability > 100) player.math_ability = 100;
    }
    
    // Regenerate focus when in relaxed state
    if (brain_wave_state == ALPHA && game_time % 20 == 0) {
        player.focus_level += 2;
        if (player.focus_level > 100) player.focus_level = 100;
    }
    
    // Randomly release neurotransmitters
    if (game_time % 40 == 0) {
        int type = rand() % 4;
        int x = rand() % MAP_W;
        int y = rand() % MAP_H;
        release_neurotransmitter(type, x, y);
    }
    
    // Update neuron activation levels
    for (int i = 0; i < NUM_NEURONS; i++) {
        if (neurons[i].activation > 0) {
            neurons[i].activation--;
        }
    }
    
    // Check for game over (focus depletion)
    if (player.focus_level <= 0) {
        printf("\n💤 Mental fatigue! Time to rest your brain.\n");
        printf("Final Score: %d problems solved at level %d\n", 
               player.solved_problems, current_level);
        restore_terminal();
        exit(0);
    }
    
    // Update psychology stats every 100 frames
    if (game_time % 100 == 0) {
        update_psychology_stats();
    }
}

/**
 * Release a neurotransmitter into the environment
 */
void release_neurotransmitter(int type, int x, int y) {
    for (int i = 0; i < NUM_NEUROTRANSMITTERS; i++) {
        if (neurotransmitters[i].x == -1) { // Find an inactive one
            neurotransmitters[i].x = x;
            neurotransmitters[i].y = y;
            neurotransmitters[i].type = type;
            neurotransmitters[i].effect = (rand() % 2) * 2 - 1;
            break;
        }
    }
}

/**
 * Update psychology-based statistics
 */
void update_psychology_stats() {
    // Calculate learning efficiency based on current state and streak
    double efficiency = learning_rates[brain_wave_state] * 
                       (1.0 + (player.learning_streak * 0.1));
    
    printf("\n📊 Learning Efficiency: %.2fx | ", efficiency);
    
    // Provide feedback based on learning streak
    if (player.learning_streak >= 5) {
        printf("🔥 Hot streak! Keep going!\n");
    } else if (player.learning_streak >= 3) {
        printf("📈 Building momentum!\n");
    } else {
        printf("💪 You can do it!\n");
    }
}

/**
 * Main game loop
 */
int main() {
    set_nonblocking_mode();
    init_game();
    
    printf("🧠 Welcome to NeuroMath: Brain-Inspired Learning!\n\n");
    printf("Explore how your brain learns math through neural pathways,\n");
    printf("neurotransmitters, and different brain states.\n\n");
    printf("Psychological principles incorporated:\n");
    printf("• Spaced repetition\n• Growth mindset\n• Neuroplasticity\n");
    printf("• Optimal challenge level\n• Emotional engagement\n\n");
    printf("Press any key to begin your brain-based math journey...");
    
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