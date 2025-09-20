#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>
#include <math.h>
#include <sys/select.h>

#define MAP_W 120
#define MAP_H 60
#define VIEW_W 60
#define VIEW_H 30

// District types with psychological functions
#define COGNITIVE_DISTRICT 0
#define MEMORY_DISTRICT 1
#define LOGIC_DISTRICT 2
#define CREATIVE_DISTRICT 3
#define SOCIAL_DISTRICT 4
#define NEURAL_HUB 5

// Math cognitive levels
#define AUTOMATICITY 0
#define UNDERSTANDING 1
#define STRATEGIC 2
#define ADAPTIVE 3
#define CREATIVE 4

typedef struct {
    int x, y;
    int width, height;
    int district_type;
    int activation;
    int math_level;
    int population;
    char name[50];
    char function[100];
    int problems_solved;
    int cognitive_load;
} District;

typedef struct {
    int x, y;
    int speed;
    int direction;
    int math_skill;
    int cognitive_load;
    int engagement;
    char role[30];
} Citizen;

typedef struct {
    int x, y;
    int intensity;
    int type;
    int duration;
    char message[100];
} ThoughtBubble;

typedef struct {
    int x, y;
    int focus;
    int math_mastery;
    int cognitive_bandwidth;
    int neural_connections;
    int influence;
    int district_control;
    long last_interaction;
    int problems_solved;
    int current_district;
    int flow_state;
} Player;

// Game state
District districts[25];
Citizen citizens[100];
ThoughtBubble thoughts[30];
Player player;

int game_time = 0;
int city_rhythm = 0;
int math_pulse = 0;
int cognitive_wave = 0;
int neural_activity = 0;

// Visual elements
const char *district_emoji[] = {"🧠", "📚", "📊", "🎨", "👥", "⚡"};
const char *citizen_emoji[] = {"👨‍💼", "👩‍🔬", "👨‍🎓", "👩‍💻", "👨‍🏫", "👩‍🎨"};
const char *math_emoji[] = {"🔢", "➗", "📐", "∞", "ψ"};
const char *thought_emoji[] = {"💭", "💡", "🌟", "❓", "❗"};

// Psychological parameters
double cognitive_efficiency = 1.0;
double learning_absorption = 0.8;
double neural_plasticity = 0.6;

// Function prototypes
void set_nonblocking_mode();
void restore_terminal();
void cls();
void init_game();
void draw_city();
void handle_input(char input);
void update_game();
void activate_district(int district_index);
void update_psychology();
void generate_math_challenge(int district_index);
void update_citizens();
void update_thoughts();
void update_neural_network();
void show_cognitive_dashboard();
void adjust_city_dynamics();
void process_math_wave();

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
 * Initialize the NeuroCity
 */
void init_game() {
    srand(time(NULL));
    
    // Initialize player
    player.x = MAP_W / 2;
    player.y = MAP_H / 2;
    player.focus = 85;
    player.math_mastery = 50;
    player.cognitive_bandwidth = 70;
    player.neural_connections = 30;
    player.influence = 40;
    player.district_control = 0;
    player.last_interaction = 0;
    player.problems_solved = 0;
    player.current_district = -1;
    player.flow_state = 40;
    
    // Initialize districts
    char *district_names[] = {
        "Cognitive Heights", "Memory Lane", "Logic Square", "Creative Corner", "Social Hub",
        "Neural Nexus", "Math Plaza", "Reasoning Road", "Calculation Court", "Pattern Parkway",
        "Algorithm Alley", "Geometry Gardens", "Statistics Street", "Probability Plaza", "Algebra Avenue",
        "Calculus Commons", "Trigonometry Terrace", "Fraction Fountain", "Decimal Drive", "Percentage Park",
        "Equation Estates", "Variable Village", "Theorem Towers", "Proof Plaza", "Analysis Arcade"
    };
    
    char *district_functions[] = {
        "Basic arithmetic processing and number sense",
        "Mathematical memory and fact recall",
        "Logical reasoning and problem-solving",
        "Creative mathematical thinking and innovation",
        "Collaborative mathematical learning",
        "Neural network integration and synthesis",
        "Advanced calculation techniques",
        "Deductive and inductive reasoning",
        "Complex computation strategies",
        "Pattern recognition and analysis",
        "Algorithm development and optimization",
        "Spatial reasoning and geometric visualization",
        "Data analysis and interpretation",
        "Probabilistic thinking and prediction",
        "Algebraic manipulation and equation solving",
        "Rates of change and accumulation",
        "Angle and relationship analysis",
        "Part-whole relationships and comparisons",
        "Place value and precision understanding",
        "Relative quantity comprehension",
        "Balancing relationships and equivalences",
        "Unknown quantity determination",
        "Mathematical truth verification",
        "Logical argument construction",
        "Continuous process examination"
    };
    
    for (int i = 0; i < 25; i++) {
        districts[i].x = 5 + rand() % (MAP_W - 10);
        districts[i].y = 5 + rand() % (MAP_H - 10);
        districts[i].width = 8 + rand() % 12;
        districts[i].height = 6 + rand() % 10;
        districts[i].district_type = i % 6;
        districts[i].activation = 30 + rand() % 40;
        districts[i].math_level = i % 5;
        districts[i].population = 10 + rand() % 20;
        districts[i].problems_solved = 0;
        districts[i].cognitive_load = 40 + rand() % 40;
        strcpy(districts[i].name, district_names[i]);
        strcpy(districts[i].function, district_functions[i]);
    }
    
    // Initialize citizens
    char *citizen_roles[] = {
        "Math Novice", "Problem Solver", "Data Analyst", "Logic Thinker", "Pattern Seeker",
        "Equation Balancer", "Theorem Prover", "Algorithm Designer", "Geometry Expert", "Statistics Master"
    };
    
    for (int i = 0; i < 100; i++) {
        citizens[i].x = rand() % MAP_W;
        citizens[i].y = rand() % MAP_H;
        citizens[i].speed = 1 + rand() % 3;
        citizens[i].direction = rand() % 8;
        citizens[i].math_skill = 20 + rand() % 60;
        citizens[i].cognitive_load = 30 + rand() % 50;
        citizens[i].engagement = 40 + rand() % 40;
        strcpy(citizens[i].role, citizen_roles[rand() % 10]);
    }
    
    // Initialize thought bubbles
    for (int i = 0; i < 30; i++) {
        thoughts[i].x = -1;
        thoughts[i].y = -1;
        thoughts[i].intensity = 0;
        thoughts[i].duration = 0;
    }
}

/**
 * Draw the NeuroCity
 */
void draw_city() {
    cls();
    
    // Draw header with city metrics
    printf("🏙️  NeuroCity: PsyMath Metropolis | Time: %d | Rhythm: %d%% | Math Pulse: %d\n\n", 
           game_time, city_rhythm, math_pulse);
    
    printf("Focus: %d%% | Math Mastery: %d | Neural Connections: %d | Influence: %d\n\n", 
           player.focus, player.math_mastery, player.neural_connections, player.influence);
    
    // Draw the cityscape
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
            
            // Draw city grid pattern
            int pattern_val = (wx * 11 + wy * 7) % 20;
            if (pattern_val < 2) c = "· ";
            else if (pattern_val < 4) c = "• ";
            
            // Draw districts
            for (int i = 0; i < 25; i++) {
                if (wx >= districts[i].x && wx < districts[i].x + districts[i].width &&
                    wy >= districts[i].y && wy < districts[i].y + districts[i].height) {
                    
                    // District core area
                    if (wx > districts[i].x + 1 && wx < districts[i].x + districts[i].width - 1 &&
                        wy > districts[i].y + 1 && wy < districts[i].y + districts[i].height - 1) {
                        c = district_emoji[districts[i].district_type];
                    } 
                    // District border
                    else {
                        c = "▣ ";
                    }
                    break;
                }
            }
            
            // Draw citizens
            for (int i = 0; i < 100; i++) {
                if (citizens[i].x == wx && citizens[i].y == wy) {
                    c = citizen_emoji[rand() % 6];
                    break;
                }
            }
            
            // Draw thought bubbles
            for (int i = 0; i < 30; i++) {
                if (thoughts[i].x == wx && thoughts[i].y == wy && thoughts[i].duration > 0) {
                    c = thought_emoji[thoughts[i].type];
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
    printf("\nControls: WASD to move | SPACE to interact | E to engage | Q to quit\n");
    printf("City Rhythm: %d%% | Cognitive Wave: %d | Neural Activity: %d\n", 
           city_rhythm, cognitive_wave, neural_activity);
    
    // Show current district info if player is in one
    if (player.current_district >= 0) {
        District *d = &districts[player.current_district];
        printf("\n🏙️  %s | Activation: %d%% | Math Level: %s\n", 
               d->name, d->activation, math_emoji[d->math_level]);
        printf("%s\n", d->function);
    }
    
    // Show cognitive dashboard periodically
    if (game_time % 120 == 0) {
        show_cognitive_dashboard();
    }
}

/**
 * Show cognitive dashboard with detailed metrics
 */
void show_cognitive_dashboard() {
    printf("\n🧠 COGNITIVE DASHBOARD:\n");
    printf("Learning Efficiency: %.2fx | Absorption: %.2f | Plasticity: %.2f\n", 
           cognitive_efficiency, learning_absorption, neural_plasticity);
    printf("Flow State: %d%% | Cognitive Bandwidth: %d%% | Neural Connections: %d\n", 
           player.flow_state, player.cognitive_bandwidth, player.neural_connections);
    
    // Show district summary
    printf("\n🏙️  DISTRICT SUMMARY:\n");
    for (int i = 0; i < 6; i++) {
        int count = 0;
        int total_activation = 0;
        for (int j = 0; j < 25; j++) {
            if (districts[j].district_type == i) {
                count++;
                total_activation += districts[j].activation;
            }
        }
        if (count > 0) {
            printf("%s: %d%% | ", district_emoji[i], total_activation / count);
        }
    }
    printf("\n");
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
            // Check if player is in a district
            player.current_district = -1;
            for (int i = 0; i < 25; i++) {
                if (player.x >= districts[i].x && player.x < districts[i].x + districts[i].width &&
                    player.y >= districts[i].y && player.y < districts[i].y + districts[i].height) {
                    player.current_district = i;
                    activate_district(i);
                    break;
                }
            }
            break;
        case 'e':
            // Engage with nearby citizens
            for (int i = 0; i < 100; i++) {
                if (abs(citizens[i].x - player.x) <= 2 && 
                    abs(citizens[i].y - player.y) <= 2) {
                    // Create a collaborative math event
                    printf("\n👥 Collaborative Learning with %s!\n", citizens[i].role);
                    player.math_mastery += citizens[i].math_skill / 10;
                    player.influence += 5;
                    player.neural_connections += 2;
                    
                    // Create a thought bubble
                    for (int j = 0; j < 30; j++) {
                        if (thoughts[j].duration <= 0) {
                            thoughts[j].x = citizens[i].x;
                            thoughts[j].y = citizens[i].y;
                            thoughts[j].intensity = 60;
                            thoughts[j].duration = 50;
                            thoughts[j].type = rand() % 5;
                            sprintf(thoughts[j].message, "%s shared math insights!", citizens[i].role);
                            break;
                        }
                    }
                    
                    usleep(1500000);
                    break;
                }
            }
            break;
        case 'q':
            printf("Exiting NeuroCity. Final Math Mastery: %d\n", player.math_mastery);
            printf("Neural Connections: %d | Districts Influenced: %d\n", 
                   player.neural_connections, player.district_control);
            restore_terminal();
            exit(0);
    }
}

/**
 * Activate a district (engage with math content)
 */
void activate_district(int district_index) {
    District *d = &districts[district_index];
    
    printf("\n🏙️  Activating %s...\n", d->name);
    printf("Mathematical Focus: %s\n", math_emoji[d->math_level]);
    printf("Cognitive Load: %d%%\n", d->cognitive_load);
    
    // Generate and present math challenge
    generate_math_challenge(district_index);
    
    // Increase district activation
    d->activation += 10;
    if (d->activation > 100) d->activation = 100;
    
    // Update player stats
    player.math_mastery += d->math_level * 2;
    player.neural_connections += 1;
    player.district_control++;
    player.last_interaction = game_time;
    
    // Create ripple effect in nearby districts
    for (int i = 0; i < 25; i++) {
        if (i != district_index) {
            int dx = districts[i].x - d->x;
            int dy = districts[i].y - d->y;
            int distance = sqrt(dx*dx + dy*dy);
            
            if (distance < 20) {
                districts[i].activation += 5;
                if (districts[i].activation > 100) districts[i].activation = 100;
            }
        }
    }
    
    usleep(1000000);
}

/**
 * Generate math challenge based on district type and level
 */
void generate_math_challenge(int district_index) {
    District *d = &districts[district_index];
    int a, b, c, answer;
    char problem[100];
    char solution[50];
    
    // Set difficulty based on district math level
    int difficulty = d->math_level + 1;
    
    switch (d->district_type) {
        case COGNITIVE_DISTRICT:
            // Arithmetic problems
            a = 10 * difficulty + rand() % (20 * difficulty);
            b = 10 * difficulty + rand() % (20 * difficulty);
            if (rand() % 2 == 0) {
                answer = a + b;
                sprintf(problem, "Calculate: %d + %d", a, b);
            } else {
                answer = a - b;
                sprintf(problem, "Calculate: %d - %d", a, b);
            }
            sprintf(solution, "%d", answer);
            break;
            
        case MEMORY_DISTRICT:
            // Sequence and pattern problems
            a = 2 + rand() % (3 * difficulty);
            b = a + (2 + rand() % 5);
            c = b + (2 + rand() % 5);
            sprintf(problem, "Complete the sequence: %d, %d, %d, ?", a, b, c);
            answer = c + (c - b);
            sprintf(solution, "%d", answer);
            break;
            
        case LOGIC_DISTRICT:
            // Logic and reasoning problems
            a = 10 + rand() % (20 * difficulty);
            b = 5 + rand() % (10 * difficulty);
            if (a > b) {
                sprintf(problem, "If A = %d and B = %d, what is A - B?", a, b);
                answer = a - b;
            } else {
                sprintf(problem, "If A = %d and B = %d, what is B - A?", a, b);
                answer = b - a;
            }
            sprintf(solution, "%d", answer);
            break;
            
        case CREATIVE_DISTRICT:
            // Creative math problems
            a = 2 + rand() % (4 * difficulty);
            b = 2 + rand() % (4 * difficulty);
            sprintf(problem, "What is %d × %d + %d?", a, b, difficulty * 5);
            answer = a * b + difficulty * 5;
            sprintf(solution, "%d", answer);
            break;
            
        case SOCIAL_DISTRICT:
            // Word problems with social context
            a = 5 + rand() % (10 * difficulty);
            b = 3 + rand() % (6 * difficulty);
            sprintf(problem, "If %d people solve %d problems each, total solutions?", a, b);
            answer = a * b;
            sprintf(solution, "%d", answer);
            break;
            
        case NEURAL_HUB:
            // Complex multi-step problems
            a = 5 + rand() % (5 * difficulty);
            b = 2 + rand() % (3 * difficulty);
            c = 10 + rand() % (10 * difficulty);
            sprintf(problem, "What is (%d × %d) + %d?", a, b, c);
            answer = a * b + c;
            sprintf(solution, "%d", answer);
            break;
    }
    
    // Present the problem
    printf("\n🧠 MATH CHALLENGE: %s\n", problem);
    printf("Enter your answer: ");
    
    // Switch to blocking mode for input
    restore_terminal();
    
    char user_answer[50];
    fgets(user_answer, 50, stdin);
    user_answer[strcspn(user_answer, "\n")] = 0;
    
    // Set back to non-blocking mode
    set_nonblocking_mode();
    
    // Check answer
    if (strcmp(user_answer, solution) == 0) {
        printf("✅ Correct! District activation increased.\n");
        d->problems_solved++;
        player.problems_solved++;
        player.math_mastery += difficulty * 3;
        
        // Create positive thought bubbles
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 30; j++) {
                if (thoughts[j].duration <= 0) {
                    thoughts[j].x = d->x + rand() % d->width;
                    thoughts[j].y = d->y + rand() % d->height;
                    thoughts[j].intensity = 70;
                    thoughts[j].duration = 60;
                    thoughts[j].type = 1; // Light bulb
                    sprintf(thoughts[j].message, "Math insight!");
                    break;
                }
            }
        }
    } else {
        printf("❌ Incorrect. The answer was %s.\n", solution);
        player.focus -= 10;
        if (player.focus < 0) player.focus = 0;
        
        // Create confusion thought bubble
        for (int j = 0; j < 30; j++) {
            if (thoughts[j].duration <= 0) {
                thoughts[j].x = d->x + d->width / 2;
                thoughts[j].y = d->y + d->height / 2;
                thoughts[j].intensity = 50;
                thoughts[j].duration = 40;
                thoughts[j].type = 3; // Question mark
                sprintf(thoughts[j].message, "Need to rethink...");
                break;
            }
        }
    }
    
    usleep(1500000);
}

/**
 * Update game state with psychological principles
 */
void update_game() {
    game_time++;
    
    // Update city rhythms and pulses
    city_rhythm = 50 + 30 * sin(game_time / 20.0);
    math_pulse = 40 + 40 * sin(game_time / 15.0 + 1.2);
    cognitive_wave = 60 + 30 * sin(game_time / 25.0 + 0.7);
    neural_activity = 70 + 20 * sin(game_time / 18.0 + 2.1);
    
    // Update psychological metrics
    update_psychology();
    
    // Update citizens
    update_citizens();
    
    // Update thought bubbles
    update_thoughts();
    
    // Update neural network
    update_neural_network();
    
    // Adjust city dynamics
    adjust_city_dynamics();
    
    // Process math waves through the city
    process_math_wave();
    
    // Check for city-wide math events
    if (game_time % 200 == 0) {
        printf("\n🌊 Math wave sweeping through the city!\n");
        for (int i = 0; i < 25; i++) {
            districts[i].activation += 5;
            if (districts[i].activation > 100) districts[i].activation = 100;
        }
        player.math_mastery += 5;
        usleep(1000000);
    }
}

/**
 * Update psychological metrics based on game state
 */
void update_psychology() {
    // Focus is affected by district activation and cognitive load
    int avg_activation = 0;
    for (int i = 0; i < 25; i++) {
        avg_activation += districts[i].activation;
    }
    avg_activation /= 25;
    
    player.focus = (player.focus * 0.9) + (avg_activation * 0.1);
    if (player.focus < 0) player.focus = 0;
    if (player.focus > 100) player.focus = 100;
    
    // Math mastery increases with activity and decreases with inactivity
    if (game_time - player.last_interaction < 50) {
        player.math_mastery += 0.1;
    } else {
        player.math_mastery -= 0.05;
    }
    if (player.math_mastery < 0) player.math_mastery = 0;
    if (player.math_mastery > 100) player.math_mastery = 100;
    
    // Cognitive bandwidth is affected by focus and math mastery
    player.cognitive_bandwidth = (player.focus + player.math_mastery) / 2;
    
    // Flow state requires balance of challenge and skill
    if (player.cognitive_bandwidth > 60 && player.focus > 70) {
        player.flow_state += 1;
    } else {
        player.flow_state -= 1;
    }
    if (player.flow_state < 0) player.flow_state = 0;
    if (player.flow_state > 100) player.flow_state = 100;
    
    // Neural connections grow with activity
    if (player.problems_solved > player.neural_connections / 2) {
        player.neural_connections += 0.5;
    }
    
    // Influence grows with district control
    player.influence = player.district_control * 4;
    if (player.influence > 100) player.influence = 100;
    
    // Update learning metrics
    cognitive_efficiency = 0.8 + (player.flow_state / 100.0) * 0.6;
    learning_absorption = 0.6 + (player.focus / 100.0) * 0.4;
    neural_plasticity = 0.5 + (player.neural_connections / 100.0) * 0.5;
}

/**
 * Update citizen positions and states
 */
void update_citizens() {
    for (int i = 0; i < 100; i++) {
        // Move citizens
        switch (citizens[i].direction) {
            case 0: if (citizens[i].y > 0) citizens[i].y--; break;
            case 1: if (citizens[i].y < MAP_H - 1) citizens[i].y++; break;
            case 2: if (citizens[i].x > 0) citizens[i].x--; break;
            case 3: if (citizens[i].x < MAP_W - 1) citizens[i].x++; break;
            case 4: if (citizens[i].x > 0 && citizens[i].y > 0) { citizens[i].x--; citizens[i].y--; } break;
            case 5: if (citizens[i].x < MAP_W - 1 && citizens[i].y > 0) { citizens[i].x++; citizens[i].y--; } break;
            case 6: if (citizens[i].x > 0 && citizens[i].y < MAP_H - 1) { citizens[i].x--; citizens[i].y++; } break;
            case 7: if (citizens[i].x < MAP_W - 1 && citizens[i].y < MAP_H - 1) { citizens[i].x++; citizens[i].y++; } break;
        }
        
        // Occasionally change direction
        if (rand() % 30 == 0) {
            citizens[i].direction = rand() % 8;
        }
        
        // Update engagement based on district activation
        for (int j = 0; j < 25; j++) {
            if (citizens[i].x >= districts[j].x && citizens[i].x < districts[j].x + districts[j].width &&
                citizens[i].y >= districts[j].y && citizens[i].y < districts[j].y + districts[j].height) {
                citizens[i].engagement = (citizens[i].engagement * 0.7) + (districts[j].activation * 0.3);
                break;
            }
        }
        
        // Occasionally create thought bubbles from highly engaged citizens
        if (citizens[i].engagement > 70 && rand() % 50 == 0) {
            for (int j = 0; j < 30; j++) {
                if (thoughts[j].duration <= 0) {
                    thoughts[j].x = citizens[i].x;
                    thoughts[j].y = citizens[i].y;
                    thoughts[j].intensity = citizens[i].engagement;
                    thoughts[j].duration = 40;
                    thoughts[j].type = rand() % 5;
                    sprintf(thoughts[j].message, "%s is engaged!", citizens[i].role);
                    break;
                }
            }
        }
    }
}

/**
 * Update thought bubbles
 */
void update_thoughts() {
    for (int i = 0; i < 30; i++) {
        if (thoughts[i].duration > 0) {
            thoughts[i].duration--;
            
            // Move thought bubbles upward
            if (thoughts[i].y > 0 && rand() % 3 == 0) {
                thoughts[i].y--;
            }
        }
    }
}

/**
 * Update neural network connections between districts
 */
void update_neural_network() {
    // Strengthen connections between highly activated districts
    for (int i = 0; i < 25; i++) {
        for (int j = i + 1; j < 25; j++) {
            if (districts[i].activation > 70 && districts[j].activation > 70) {
                int dx = districts[i].x - districts[j].x;
                int dy = districts[i].y - districts[j].y;
                int distance = sqrt(dx*dx + dy*dy);
                
                if (distance < 30) {
                    // Districts influence each other
                    districts[i].activation += 1;
                    districts[j].activation += 1;
                    
                    if (districts[i].activation > 100) districts[i].activation = 100;
                    if (districts[j].activation > 100) districts[j].activation = 100;
                    
                    // Occasionally create a visual connection
                    if (rand() % 100 == 0) {
                        for (int k = 0; k < 30; k++) {
                            if (thoughts[k].duration <= 0) {
                                thoughts[k].x = (districts[i].x + districts[j].x) / 2;
                                thoughts[k].y = (districts[i].y + districts[j].y) / 2;
                                thoughts[k].intensity = 80;
                                thoughts[k].duration = 30;
                                thoughts[k].type = 2; // Sparkle
                                sprintf(thoughts[k].message, "Neural connection!");
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}

/**
 * Adjust city dynamics based on player activity
 */
void adjust_city_dynamics() {
    // City rhythm affects district activation
    for (int i = 0; i < 25; i++) {
        districts[i].activation = (districts[i].activation * 0.95) + (city_rhythm * 0.05);
        if (districts[i].activation < 0) districts[i].activation = 0;
        if (districts[i].activation > 100) districts[i].activation = 100;
    }
    
    // Math pulse affects citizen math skills
    for (int i = 0; i < 100; i++) {
        citizens[i].math_skill = (citizens[i].math_skill * 0.9) + (math_pulse * 0.1);
        if (citizens[i].math_skill < 0) citizens[i].math_skill = 0;
        if (citizens[i].math_skill > 100) citizens[i].math_skill = 100;
    }
    
    // Cognitive wave affects cognitive load
    for (int i = 0; i < 25; i++) {
        districts[i].cognitive_load = (districts[i].cognitive_load * 0.9) + (cognitive_wave * 0.1);
        if (districts[i].cognitive_load < 0) districts[i].cognitive_load = 0;
        if (districts[i].cognitive_load > 100) districts[i].cognitive_load = 100;
    }
    
    // Neural activity affects thought bubble intensity
    for (int i = 0; i < 30; i++) {
        if (thoughts[i].duration > 0) {
            thoughts[i].intensity = (thoughts[i].intensity * 0.8) + (neural_activity * 0.2);
        }
    }
}

/**
 * Process math waves through the city
 */
void process_math_wave() {
    // Create periodic math waves that spread through the city
    if (game_time % 75 == 0) {
        int source = rand() % 25;
        int intensity = 30 + rand() % 50;
        
        for (int i = 0; i < 25; i++) {
            int dx = districts[i].x - districts[source].x;
            int dy = districts[i].y - districts[source].y;
            int distance = sqrt(dx*dx + dy*dy);
            
            if (distance < 40) {
                int effect = intensity * (1 - distance / 40.0);
                districts[i].activation += effect;
                if (districts[i].activation > 100) districts[i].activation = 100;
                
                // Create visual effect
                if (effect > 20 && rand() % 3 == 0) {
                    for (int j = 0; j < 30; j++) {
                        if (thoughts[j].duration <= 0) {
                            thoughts[j].x = districts[i].x + rand() % districts[i].width;
                            thoughts[j].y = districts[i].y + rand() % districts[i].height;
                            thoughts[j].intensity = effect;
                            thoughts[j].duration = 30;
                            thoughts[j].type = 4; // Exclamation
                            sprintf(thoughts[j].message, "Math wave!");
                            break;
                        }
                    }
                }
            }
        }
    }
}

/**
 * Main game loop
 */
int main() {
    set_nonblocking_mode();
    init_game();
    
    printf("🏙️  Welcome to NeuroCity: PsyMath Metropolis\n\n");
    printf("A living city where mathematics is the fundamental energy.\n");
    printf("Each district specializes in different mathematical thinking:\n");
    printf("🧠 Cognitive Districts - Basic arithmetic and number sense\n");
    printf("📚 Memory Districts - Mathematical memory and recall\n");
    printf("📊 Logic Districts - Reasoning and problem-solving\n");
    printf("🎨 Creative Districts - Innovative mathematical thinking\n");
    printf("👥 Social Districts - Collaborative mathematics\n");
    printf("⚡ Neural Hubs - Advanced synthesis and integration\n\n");
    printf("Your goal is to activate districts, solve math challenges,\n");
    printf("and increase your mathematical mastery and influence.\n\n");
    printf("Press any key to enter the NeuroCity...");
    
    char dummy;
    read(STDIN_FILENO, &dummy, 1);
    
    char input;
    while (1) {
        draw_city();
        
        if (read(STDIN_FILENO, &input, 1) > 0) {
            handle_input(input);
        }
        
        update_game();
        usleep(100000); // 100ms delay
    }
    
    restore_terminal();
    return 0;
}