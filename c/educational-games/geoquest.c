#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>
#include <math.h>

#define MAP_W 100
#define MAP_H 60
#define VIEW_W 60
#define VIEW_H 30

// Continent types
#define AFRICA 0
#define ASIA 1
#define EUROPE 2
#define NORTH_AMERICA 3
#define SOUTH_AMERICA 4
#define OCEANIA 5
#define ANTARCTICA 6

// Learning categories
#define COUNTRY_FACTS 0
#define LANDMARKS 1
#define CULTURE 2
#define GEOGRAPHY 3
#define WILDLIFE 4

typedef struct {
    int x, y;
    int width, height;
    int continent_type;
    char name[50];
    char capital[50];
    char fact1[100];
    char fact2[100];
    char fact3[100];
    int discovered;
    int learning_value;
} Country;

typedef struct {
    int x, y;
    int type;
    char name[50];
    char fact[100];
    int discovered;
} Landmark;

typedef struct {
    int x, y;
    int speed;
    int direction;
    char type[30];
    char fact[100];
} Wildlife;

typedef struct {
    int x, y;
    int type;
    char question[100];
    char options[4][50];
    int correct_answer;
    int completed;
} Challenge;

typedef struct {
    int x, y;
    int knowledge;
    int exploration;
    int culture_points;
    int countries_visited;
    int landmarks_discovered;
    int challenges_completed;
    int current_continent;
    int passport_stamps;
} Player;

// Game state
Country countries[50];
Landmark landmarks[30];
Wildlife wildlife[20];
Challenge challenges[15];
Player player;

int game_time = 0;
int current_level = 1;
int travel_mode = 0;
int learning_momentum = 0;

// Visual elements
const char *continent_emoji[] = {"🌍", "🌏", "🌍", "🌎", "🌎", "🐠", "❄️"};
const char *landmark_emoji[] = {"🏛️", "🏔️", "🗼", "🏰", "🗽", "🌋", "🏜️", "🕌"};
const char *wildlife_emoji[] = {"🐘", "🐅", "🐪", "🐻", "🦘", "🐧", "🦜", "🐊"};
const char *challenge_emoji[] = {"❓", "💡", "🧠", "🎯"};

// Function prototypes
void set_nonblocking_mode();
void restore_terminal();
void cls();
void init_game();
void draw_world();
void handle_input(char input);
void update_game();
void visit_country(int country_index);
void discover_landmark(int landmark_index);
void encounter_wildlife(int wildlife_index);
void complete_challenge(int challenge_index);
void update_learning();
void show_passport();
void update_travel_mode();
void generate_country_fact(int country_index);
void show_learning_momentum();

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
 * Initialize the game world with countries, landmarks, and challenges
 */
void init_game() {
    srand(time(NULL));
    
    // Initialize player
    player.x = MAP_W / 2;
    player.y = MAP_H / 2;
    player.knowledge = 50;
    player.exploration = 0;
    player.culture_points = 0;
    player.countries_visited = 0;
    player.landmarks_discovered = 0;
    player.challenges_completed = 0;
    player.current_continent = -1;
    player.passport_stamps = 0;
    
    // Initialize some sample countries (in a real game, this would be more comprehensive)
    Country sample_countries[] = {
        {30, 20, 8, 6, AFRICA, "Egypt", "Cairo", 
         "Home to the ancient pyramids", "The Nile River is the longest in the world", 
         "Ancient Egyptians invented paper", 0, 15},
        {50, 15, 10, 8, EUROPE, "France", "Paris", 
         "Famous for the Eiffel Tower", "Known for its delicious cuisine", 
         "The Louvre is the world's largest art museum", 0, 20},
        {80, 25, 12, 10, ASIA, "Japan", "Tokyo", 
         "Known as the Land of the Rising Sun", "Has the world's fastest bullet trains", 
         "Home to Mount Fuji, an active volcano", 0, 25},
        {20, 35, 15, 12, NORTH_AMERICA, "United States", "Washington D.C.", 
         "Has 50 states", "The Grand Canyon is one of the natural wonders", 
         "Invented the internet and many modern technologies", 0, 30},
        {35, 50, 10, 8, SOUTH_AMERICA, "Brazil", "Brasilia", 
         "Largest country in South America", "Home to the Amazon rainforest", 
         "Famous for carnival celebrations", 0, 18},
        {85, 45, 8, 6, OCEANIA, "Australia", "Canberra", 
         "Home to unique animals like kangaroos and koalas", "The Great Barrier Reef is the largest coral reef system", 
         "Has more sheep than people", 0, 22}
    };
    
    // Copy sample countries to our countries array
    for (int i = 0; i < 6; i++) {
        countries[i] = sample_countries[i];
    }
    
    // Initialize landmarks
    Landmark sample_landmarks[] = {
        {32, 22, 0, "Pyramids of Giza", "Ancient tombs built over 4500 years ago"},
        {52, 17, 1, "Eiffel Tower", "Iconic iron tower in Paris, France"},
        {82, 27, 2, "Mount Fuji", "Sacred volcano and highest mountain in Japan"},
        {25, 38, 3, "Grand Canyon", "Massive canyon carved by the Colorado River"},
        {38, 52, 4, "Amazon Rainforest", "Largest tropical rainforest in the world"},
        {87, 47, 5, "Great Barrier Reef", "World's largest coral reef system"}
    };
    
    for (int i = 0; i < 6; i++) {
        landmarks[i] = sample_landmarks[i];
    }
    
    // Initialize wildlife
    Wildlife sample_wildlife[] = {
        {33, 23, 1, 0, "African Elephant", "Largest land animal on Earth"},
        {53, 18, 1, 1, "European Brown Bear", "Found in forests across Europe"},
        {83, 28, 1, 2, "Japanese Macaque", "Snow monkeys that bathe in hot springs"},
        {26, 39, 1, 3, "Bald Eagle", "National bird of the United States"},
        {39, 53, 1, 4, "Jaguar", "Largest big cat in the Americas"},
        {88, 48, 1, 5, "Kangaroo", "Iconic marsupial from Australia"}
    };
    
    for (int i = 0; i < 6; i++) {
        wildlife[i] = sample_wildlife[i];
    }
    
    // Initialize challenges
    Challenge sample_challenges[] = {
        {31, 21, COUNTRY_FACTS, "What is the capital of Egypt?", 
         {"Cairo", "Alexandria", "Luxor", "Giza"}, 0, 0},
        {51, 16, LANDMARKS, "Which landmark is in France?", 
         {"Eiffel Tower", "Colosseum", "Big Ben", "Taj Mahal"}, 0, 0},
        {81, 26, CULTURE, "What is Japan known as?", 
         {"Land of the Rising Sun", "Land of the Midnight Sun", "Land of the Free", "Land of the Brave"}, 0, 0},
        {24, 37, GEOGRAPHY, "How many states does the US have?", 
         {"50", "52", "48", "45"}, 0, 0},
        {37, 51, WILDLIFE, "Which animal is found in the Amazon?", 
         {"Jaguar", "Kangaroo", "Polar Bear", "Penguin"}, 0, 0},
        {86, 46, GEOGRAPHY, "What is the largest coral reef system?", 
         {"Great Barrier Reef", "Maldives Coral Reef", "Red Sea Coral Reef", "Andaman Reef"}, 0, 0}
    };
    
    for (int i = 0; i < 6; i++) {
        challenges[i] = sample_challenges[i];
    }
}

/**
 * Draw the world map
 */
void draw_world() {
    cls();
    
    // Draw header with player stats
    printf("🗺️  GeoQuest: World Exploration | Level: %d | Knowledge: %d\n\n", 
           current_level, player.knowledge);
    
    printf("Countries: %d/50 | Landmarks: %d/30 | Challenges: %d/15 | Culture: %d\n\n", 
           player.countries_visited, player.landmarks_discovered, 
           player.challenges_completed, player.culture_points);
    
    // Draw the world map
    for (int y = 0; y < VIEW_H; y++) {
        for (int x = 0; x < VIEW_W; x++) {
            int wx = player.x - VIEW_W/2 + x;
            int wy = player.y - VIEW_H/2 + y;
            const char *c = "  "; // Default empty space (water)
            
            // Check boundaries
            if (wx < 0 || wx >= MAP_W || wy < 0 || wy >= MAP_H) {
                printf("  ");
                continue;
            }
            
            // Draw ocean pattern
            int pattern_val = (wx * 7 + wy * 13) % 20;
            if (pattern_val < 3) c = "~ ";
            else if (pattern_val < 6) c = "≈ ";
            
            // Draw countries
            for (int i = 0; i < 50; i++) {
                if (countries[i].width > 0 && 
                    wx >= countries[i].x && wx < countries[i].x + countries[i].width &&
                    wy >= countries[i].y && wy < countries[i].y + countries[i].height) {
                    
                    if (countries[i].discovered) {
                        c = continent_emoji[countries[i].continent_type];
                    } else {
                        c = "■ "; // Undiscovered country
                    }
                    break;
                }
            }
            
            // Draw landmarks
            for (int i = 0; i < 30; i++) {
                if (landmarks[i].x == wx && landmarks[i].y == wy) {
                    if (landmarks[i].discovered) {
                        c = landmark_emoji[landmarks[i].type];
                    } else {
                        c = "? "; // Undiscovered landmark
                    }
                    break;
                }
            }
            
            // Draw wildlife
            for (int i = 0; i < 20; i++) {
                if (wildlife[i].x == wx && wildlife[i].y == wy) {
                    c = wildlife_emoji[wildlife[i].type];
                    break;
                }
            }
            
            // Draw challenges
            for (int i = 0; i < 15; i++) {
                if (challenges[i].x == wx && challenges[i].y == wy) {
                    if (challenges[i].completed) {
                        c = "✅";
                    } else {
                        c = challenge_emoji[challenges[i].type];
                    }
                    break;
                }
            }
            
            // Draw player
            if (wx == player.x && wy == player.y) {
                c = "👦";
            }
            
            printf("%s", c);
        }
        printf("\n");
    }
    
    // Draw footer with controls
    printf("\nControls: WASD to move | SPACE to interact | P to show passport | Q to quit\n");
    printf("Travel Mode: %s | Learning Momentum: %d\n", 
           travel_mode ? "Fast" : "Normal", learning_momentum);
    
    // Show learning tips periodically
    if (game_time % 100 == 0) {
        printf("\n💡 Tip: Visit countries to learn about their cultures and landmarks!\n");
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
            // Check for country visits
            for (int i = 0; i < 50; i++) {
                if (countries[i].width > 0 && 
                    player.x >= countries[i].x && player.x < countries[i].x + countries[i].width &&
                    player.y >= countries[i].y && player.y < countries[i].y + countries[i].height) {
                    visit_country(i);
                    break;
                }
            }
            
            // Check for landmark discovery
            for (int i = 0; i < 30; i++) {
                if (abs(landmarks[i].x - player.x) <= 1 && 
                    abs(landmarks[i].y - player.y) <= 1) {
                    discover_landmark(i);
                    break;
                }
            }
            
            // Check for wildlife encounters
            for (int i = 0; i < 20; i++) {
                if (abs(wildlife[i].x - player.x) <= 1 && 
                    abs(wildlife[i].y - player.y) <= 1) {
                    encounter_wildlife(i);
                    break;
                }
            }
            
            // Check for challenges
            for (int i = 0; i < 15; i++) {
                if (abs(challenges[i].x - player.x) <= 1 && 
                    abs(challenges[i].y - player.y) <= 1) {
                    complete_challenge(i);
                    break;
                }
            }
            break;
        case 'p':
            show_passport();
            break;
        case 't':
            travel_mode = !travel_mode;
            printf("\n🚀 Travel mode %s\n", travel_mode ? "activated" : "deactivated");
            usleep(1000000);
            break;
        case 'q':
            printf("Thanks for playing GeoQuest!\n");
            printf("Final Knowledge: %d | Countries Visited: %d\n", 
                   player.knowledge, player.countries_visited);
            restore_terminal();
            exit(0);
    }
}

/**
 * Visit a country and learn about it
 */
void visit_country(int country_index) {
    Country *c = &countries[country_index];
    
    if (!c->discovered) {
        printf("\n🎉 You discovered %s! (%s)\n", c->name, continent_emoji[c->continent_type]);
        printf("Capital: %s\n", c->capital);
        printf("Fact 1: %s\n", c->fact1);
        printf("Fact 2: %s\n", c->fact2);
        printf("Fact 3: %s\n", c->fact3);
        
        c->discovered = 1;
        player.countries_visited++;
        player.knowledge += c->learning_value;
        player.culture_points += 10;
        player.passport_stamps++;
        
        // Generate additional random fact
        generate_country_fact(country_index);
        
        learning_momentum += 5;
    } else {
        printf("\n🏠 Welcome back to %s!\n", c->name);
        printf("Capital: %s\n", c->capital);
        
        // Show a random fact each time you revisit
        int fact_num = rand() % 4;
        switch (fact_num) {
            case 0: printf("Remember: %s\n", c->fact1); break;
            case 1: printf("Remember: %s\n", c->fact2); break;
            case 2: printf("Remember: %s\n", c->fact3); break;
            case 3: printf("Did you know? %s\n", c->fact1); break;
        }
        
        player.knowledge += 2;
        learning_momentum += 2;
    }
    
    usleep(2500000);
}

/**
 * Generate an additional random fact about a country
 */
void generate_country_fact(int country_index) {
    Country *c = &countries[country_index];
    const char *fact_templates[] = {
        "The official language is %s",
        "The currency used is the %s",
        "The population is about %d million",
        "The national dish is %s",
        "Famous for its %s",
        "The climate is mostly %s",
        "Known for its %s festivals"
    };
    
    const char *languages[] = {"English", "Spanish", "French", "German", "Japanese", "Arabic", "Portuguese", "Russian"};
    const char *currencies[] = {"Dollar", "Euro", "Yen", "Pound", "Peso", "Real", "Rupee", "Yuan"};
    const char *dishes[] = {"paella", "sushi", "pasta", "curry", "tacos", "steak", "seafood", "stew"};
    const char *features[] = {"music", "art", "dance", "literature", "architecture", "technology", "sports", "nature"};
    const char *climates[] = {"tropical", "temperate", "arid", "continental", "polar", "mediterranean"};
    const char *festivals[] = {"music", "film", "food", "cultural", "harvest", "historical"};
    
    // Create a random fact based on country type
    char new_fact[100];
    int template_idx = rand() % 7;
    
    switch (template_idx) {
        case 0:
            sprintf(new_fact, fact_templates[0], languages[rand() % 8]);
            break;
        case 1:
            sprintf(new_fact, fact_templates[1], currencies[rand() % 8]);
            break;
        case 2:
            sprintf(new_fact, fact_templates[2], 10 + rand() % 500);
            break;
        case 3:
            sprintf(new_fact, fact_templates[3], dishes[rand() % 8]);
            break;
        case 4:
            sprintf(new_fact, fact_templates[4], features[rand() % 8]);
            break;
        case 5:
            sprintf(new_fact, fact_templates[5], climates[rand() % 6]);
            break;
        case 6:
            sprintf(new_fact, fact_templates[6], festivals[rand() % 6]);
            break;
    }
    
    printf("New fact: %s\n", new_fact);
}

/**
 * Discover a landmark
 */
void discover_landmark(int landmark_index) {
    Landmark *l = &landmarks[landmark_index];
    
    if (!l->discovered) {
        printf("\n🏛️ You discovered %s!\n", l->name);
        printf("Fact: %s\n", l->fact);
        
        l->discovered = 1;
        player.landmarks_discovered++;
        player.knowledge += 15;
        player.culture_points += 5;
        
        learning_momentum += 3;
    } else {
        printf("\n🏛️ You're visiting %s again.\n", l->name);
        printf("Fact: %s\n", l->fact);
        
        player.knowledge += 3;
        learning_momentum += 1;
    }
    
    usleep(2000000);
}

/**
 * Encounter wildlife
 */
void encounter_wildlife(int wildlife_index) {
    Wildlife *w = &wildlife[wildlife_index];
    
    printf("\n%s You encountered a %s!\n", wildlife_emoji[w->type], w->type);
    printf("Fact: %s\n", w->fact);
    
    player.knowledge += 8;
    learning_momentum += 2;
    
    usleep(2000000);
}

/**
 * Complete a challenge
 */
void complete_challenge(int challenge_index) {
    Challenge *ch = &challenges[challenge_index];
    
    if (ch->completed) {
        printf("\n✅ You've already completed this challenge!\n");
        usleep(1000000);
        return;
    }
    
    printf("\n🧠 GEOGRAPHY CHALLENGE:\n");
    printf("%s\n", ch->question);
    for (int i = 0; i < 4; i++) {
        printf("%d. %s\n", i+1, ch->options[i]);
    }
    printf("Enter your answer (1-4): ");
    
    // Switch to blocking mode for input
    restore_terminal();
    
    char answer_str[10];
    fgets(answer_str, 10, stdin);
    int answer = atoi(answer_str) - 1;
    
    // Set back to non-blocking mode
    set_nonblocking_mode();
    
    if (answer == ch->correct_answer) {
        printf("✅ Correct! You earned %d knowledge points.\n", 20 + learning_momentum);
        ch->completed = 1;
        player.challenges_completed++;
        player.knowledge += 20 + learning_momentum;
        player.culture_points += 10;
        
        learning_momentum += 10;
    } else {
        printf("❌ Incorrect. The right answer was %d. %s\n", 
               ch->correct_answer + 1, ch->options[ch->correct_answer]);
        player.knowledge += 5; // Still learn something from mistakes
        learning_momentum = learning_momentum > 0 ? learning_momentum - 5 : 0;
    }
    
    usleep(2500000);
}

/**
 * Show passport with travel progress
 */
void show_passport() {
    cls();
    printf("🛂 GEOQUEST PASSPORT\n\n");
    printf("Countries Visited: %d/50\n", player.countries_visited);
    printf("Landmarks Discovered: %d/30\n", player.landmarks_discovered);
    printf("Challenges Completed: %d/15\n", player.challenges_completed);
    printf("Passport Stamps: %d\n\n", player.passport_stamps);
    
    printf("Continents Explored:\n");
    int continents[7] = {0};
    for (int i = 0; i < 50; i++) {
        if (countries[i].discovered && countries[i].width > 0) {
            continents[countries[i].continent_type]++;
        }
    }
    
    for (int i = 0; i < 7; i++) {
        if (continents[i] > 0) {
            printf("%s: %d countries\n", continent_emoji[i], continents[i]);
        }
    }
    
    printf("\nPress any key to continue...");
    char dummy;
    read(STDIN_FILENO, &dummy, 1);
}

/**
 * Update learning metrics
 */
void update_learning() {
    // Learning momentum naturally decreases over time
    if (learning_momentum > 0) {
        learning_momentum--;
    }
    
    // Check for level advancement
    if (player.knowledge >= current_level * 100) {
        current_level++;
        printf("\n🎉 Level Up! You reached level %d\n", current_level);
        printf("Your geographical knowledge is expanding!\n");
        usleep(2000000);
    }
}

/**
 * Update travel mode effects
 */
void update_travel_mode() {
    if (travel_mode) {
        // Faster movement but slower knowledge gain
        player.x += rand() % 3 - 1;
        player.y += rand() % 3 - 1;
        
        // Ensure player stays within bounds
        if (player.x < 0) player.x = 0;
        if (player.x >= MAP_W) player.x = MAP_W - 1;
        if (player.y < 0) player.y = 0;
        if (player.y >= MAP_H) player.y = MAP_H - 1;
    }
}

/**
 * Update game state
 */
void update_game() {
    game_time++;
    
    // Update learning metrics
    update_learning();
    
    // Update travel mode effects
    update_travel_mode();
    
    // Move wildlife
    for (int i = 0; i < 20; i++) {
        if (rand() % 10 == 0) {
            wildlife[i].x += rand() % 3 - 1;
            wildlife[i].y += rand() % 3 - 1;
            
            // Keep wildlife in bounds
            if (wildlife[i].x < 0) wildlife[i].x = 0;
            if (wildlife[i].x >= MAP_W) wildlife[i].x = MAP_W - 1;
            if (wildlife[i].y < 0) wildlife[i].y = 0;
            if (wildlife[i].y >= MAP_H) wildlife[i].y = MAP_H - 1;
        }
    }
    
    // Show learning momentum effect occasionally
    if (learning_momentum > 20 && game_time % 50 == 0) {
        show_learning_momentum();
    }
}

/**
 * Show learning momentum effect
 */
void show_learning_momentum() {
    printf("\n🚀 Learning Momentum: %d/100\n", learning_momentum);
    printf("You're learning quickly! Keep exploring!\n");
    usleep(1500000);
}

/**
 * Main game loop
 */
int main() {
    set_nonblocking_mode();
    init_game();
    
    printf("🗺️  Welcome to GeoQuest: World Exploration!\n\n");
    printf("Explore the world, learn about countries, discover landmarks,\n");
    printf("encounter wildlife, and complete geography challenges!\n\n");
    printf("Educational features:\n");
    printf("• Country facts and capitals\n• Cultural information\n");
    printf("• Geographical landmarks\n• Wildlife knowledge\n• Interactive quizzes\n\n");
    printf("Press any key to begin your world adventure...");
    
    char dummy;
    read(STDIN_FILENO, &dummy, 1);
    
    char input;
    while (1) {
        draw_world();
        
        if (read(STDIN_FILENO, &input, 1) > 0) {
            handle_input(input);
        }
        
        update_game();
        usleep(100000); // 100ms delay
    }
    
    restore_terminal();
    return 0;
}