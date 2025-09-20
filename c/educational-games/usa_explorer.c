#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>
#include <math.h>

#define MAP_W 120
#define MAP_H 60
#define VIEW_W 60
#define VIEW_H 30
#define NUM_STATES 50

// Game modes
#define EXPLORATION 0
#define QUIZ 1
#define FLAG_CHALLENGE 2
#define CAPITAL_MATCH 3

// Region types
#define NEW_ENGLAND 0
#define MID_ATLANTIC 1
#define MIDWEST 2
#define SOUTH 3
#define WEST 4
#define PACIFIC 5

typedef struct {
    int x, y;
    int width, height;
    char name[20];
    char capital[20];
    char abbreviation[3];
    char flag_emoji[10];
    int discovered;
    int region;
    int quiz_score;
    int challenge_completed;
} State;

typedef struct {
    int x, y;
    int type;
    char question[100];
    char options[4][30];
    int correct_answer;
    int completed;
} QuizChallenge;

typedef struct {
    int x, y;
    int type;
    char state_abbr[3];
    int completed;
} FlagChallenge;

typedef struct {
    int x, y;
    int knowledge;
    int states_discovered;
    int quizzes_completed;
    int flags_mastered;
    int capitals_learned;
    int current_region;
    int streak;
    int motivation;
    int game_mode;
    int exploration_progress;
} Player;

// Game state
State states[NUM_STATES];
QuizChallenge quizzes[20];
FlagChallenge flag_challenges[15];
Player player;

int game_time = 0;
int current_level = 1;
int learning_intensity = 50;
int positive_affirmation_timer = 0;
int subliminal_timer = 0;

// Visual elements
const char *region_emoji[] = {"🍁", "🗽", "🌽", "🎸", "🏔️", "🌊"};
const char *mode_emoji[] = {"🧭", "📝", "🏴", "🏛️"};
const char *streak_emoji[] = {"🔥", "🚀", "🌟", "💫", "🌈"};

// Positive affirmations
const char *affirmations[] = {
    "You're a geography genius!",
    "Your brain is getting stronger!",
    "Learning is your superpower!",
    "You remember everything you learn!",
    "Your memory is amazing!",
    "You're great at remembering facts!",
    "Geography is fun and easy for you!",
    "You're becoming a states expert!",
    "Your knowledge is growing fast!",
    "You're awesome at learning!"
};

// Subliminal messages
const char *subliminal_messages[] = {
    "I remember states easily",
    "Capitals are fun to learn",
    "I'm good at geography",
    "Learning is enjoyable",
    "I enjoy memorizing facts",
    "I have an excellent memory",
    "States and capitals are easy",
    "I'm a quick learner",
    "Geography is my strength",
    "I love learning new things"
};

// Function prototypes
void set_nonblocking_mode();
void restore_terminal();
void cls();
void init_game();
void draw_usa_map();
void handle_input(char input);
void update_game();
void discover_state(int state_index);
void start_quiz(int quiz_index);
void start_flag_challenge(int challenge_index);
void start_capital_match();
void update_learning();
void show_positive_affirmation();
void show_subliminal_message();
void update_streak(int success);
void update_motivation();
void show_progress_dashboard();
void unlock_achievement(const char *achievement);
void adjust_learning_intensity();

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
 * Initialize the game with all 50 US states
 */
void init_game() {
    srand(time(NULL));
    
    // Initialize player
    player.x = MAP_W / 2;
    player.y = MAP_H / 2;
    player.knowledge = 50;
    player.states_discovered = 0;
    player.quizzes_completed = 0;
    player.flags_mastered = 0;
    player.capitals_learned = 0;
    player.current_region = -1;
    player.streak = 0;
    player.motivation = 80;
    player.game_mode = EXPLORATION;
    player.exploration_progress = 0;
    
    // Initialize all 50 US states with approximate geographic positions
    State us_states[] = {
        // New England Region
        {30, 15, 4, 3, "Maine", "Augusta", "ME", "🏔️", 0, NEW_ENGLAND, 0, 0},
        {28, 18, 3, 3, "New Hampshire", "Concord", "NH", "⛰️", 0, NEW_ENGLAND, 0, 0},
        {26, 20, 3, 3, "Vermont", "Montpelier", "VT", "🍁", 0, NEW_ENGLAND, 0, 0},
        {32, 20, 3, 3, "Massachusetts", "Boston", "MA", "⚓", 0, NEW_ENGLAND, 0, 0},
        {35, 20, 3, 3, "Rhode Island", "Providence", "RI", "⚓", 0, NEW_ENGLAND, 0, 0},
        {32, 23, 4, 3, "Connecticut", "Hartford", "CT", "🌳", 0, NEW_ENGLAND, 0, 0},
        
        // Mid-Atlantic Region
        {28, 25, 5, 4, "New York", "Albany", "NY", "🗽", 0, MID_ATLANTIC, 0, 0},
        {25, 28, 4, 3, "Pennsylvania", "Harrisburg", "PA", "🔔", 0, MID_ATLANTIC, 0, 0},
        {30, 28, 3, 3, "New Jersey", "Trenton", "NJ", "🌊", 0, MID_ATLANTIC, 0, 0},
        {28, 32, 3, 3, "Delaware", "Dover", "DE", "🦀", 0, MID_ATLANTIC, 0, 0},
        {25, 32, 4, 3, "Maryland", "Annapolis", "MD", "🐢", 0, MID_ATLANTIC, 0, 0},
        {22, 32, 4, 4, "Virginia", "Richmond", "VA", "🔺", 0, MID_ATLANTIC, 0, 0},
        {20, 36, 5, 4, "West Virginia", "Charleston", "WV", "⛰️", 0, MID_ATLANTIC, 0, 0},
        
        // Midwest Region
        {18, 20, 5, 4, "Ohio", "Columbus", "OH", "🛶", 0, MIDWEST, 0, 0},
        {15, 18, 5, 4, "Michigan", "Lansing", "MI", "👋", 0, MIDWEST, 0, 0},
        {12, 22, 6, 4, "Indiana", "Indianapolis", "IN", "🏎️", 0, MIDWEST, 0, 0},
        {10, 26, 6, 4, "Illinois", "Springfield", "IL", "🌬️", 0, MIDWEST, 0, 0},
        {8, 30, 8, 5, "Wisconsin", "Madison", "WI", "🧀", 0, MIDWEST, 0, 0},
        {5, 35, 8, 6, "Minnesota", "St. Paul", "MN", "❄️", 0, MIDWEST, 0, 0},
        {3, 41, 8, 6, "Iowa", "Des Moines", "IA", "🌽", 0, MIDWEST, 0, 0},
        {5, 47, 8, 6, "Missouri", "Jefferson City", "MO", "🎵", 0, MIDWEST, 0, 0},
        {12, 47, 7, 5, "Kentucky", "Frankfort", "KY", "🐎", 0, MIDWEST, 0, 0},
        {15, 42, 5, 4, "Tennessee", "Nashville", "TN", "🎸", 0, MIDWEST, 0, 0},
        
        // Southern Region
        {20, 40, 6, 5, "North Carolina", "Raleigh", "NC", "✈️", 0, SOUTH, 0, 0},
        {22, 45, 6, 5, "South Carolina", "Columbia", "SC", "🌴", 0, SOUTH, 0, 0},
        {18, 50, 6, 5, "Georgia", "Atlanta", "GA", "🍑", 0, SOUTH, 0, 0},
        {15, 55, 8, 6, "Florida", "Tallahassee", "FL", "🌴", 0, SOUTH, 0, 0},
        {10, 55, 8, 6, "Alabama", "Montgomery", "AL", "❤️", 0, SOUTH, 0, 0},
        {6, 55, 8, 6, "Mississippi", "Jackson", "MS", "🎵", 0, SOUTH, 0, 0},
        {2, 55, 8, 6, "Louisiana", "Baton Rouge", "LA", "🎭", 0, SOUTH, 0, 0},
        {0, 50, 8, 6, "Texas", "Austin", "TX", "🤠", 0, SOUTH, 0, 0},
        {0, 44, 8, 6, "Oklahoma", "Oklahoma City", "OK", "🌪️", 0, SOUTH, 0, 0},
        {0, 38, 8, 6, "Arkansas", "Little Rock", "AR", "💎", 0, SOUTH, 0, 0},
        
        // Western Region
        {0, 30, 10, 8, "Colorado", "Denver", "CO", "🏔️", 0, WEST, 0, 0},
        {0, 22, 10, 8, "Wyoming", "Cheyenne", "WY", "🦬", 0, WEST, 0, 0},
        {0, 14, 10, 8, "Montana", "Helena", "MT", "🏔️", 0, WEST, 0, 0},
        {10, 14, 8, 6, "North Dakota", "Bismarck", "ND", "🌻", 0, WEST, 0, 0},
        {10, 20, 8, 6, "South Dakota", "Pierre", "SD", "🏞️", 0, WEST, 0, 0},
        {15, 14, 8, 6, "Nebraska", "Lincoln", "NE", "🌽", 0, WEST, 0, 0},
        {20, 14, 8, 6, "Kansas", "Topeka", "KS", "🌻", 0, WEST, 0, 0},
        {25, 10, 10, 8, "Idaho", "Boise", "ID", "🥔", 0, WEST, 0, 0},
        {30, 14, 10, 8, "Utah", "Salt Lake City", "UT", "⛪", 0, WEST, 0, 0},
        {35, 10, 10, 8, "Nevada", "Carson City", "NV", "🎰", 0, WEST, 0, 0},
        {40, 14, 10, 8, "Arizona", "Phoenix", "AZ", "🌵", 0, WEST, 0, 0},
        {45, 10, 10, 8, "California", "Sacramento", "CA", "🌴", 0, WEST, 0, 0},
        
        // Pacific Region
        {40, 5, 8, 5, "Oregon", "Salem", "OR", "🌲", 0, PACIFIC, 0, 0},
        {45, 2, 8, 5, "Washington", "Olympia", "WA", "🌲", 0, PACIFIC, 0, 0},
        {50, 8, 6, 4, "Hawaii", "Honolulu", "HI", "🌺", 0, PACIFIC, 0, 0},
        {30, 2, 8, 5, "Alaska", "Juneau", "AK", "❄️", 0, PACIFIC, 0, 0}
    };
    
    // Copy states to our array
    for (int i = 0; i < NUM_STATES; i++) {
        states[i] = us_states[i];
    }
    
    // Initialize quizzes
    for (int i = 0; i < 20; i++) {
        quizzes[i].x = 10 + rand() % (MAP_W - 20);
        quizzes[i].y = 10 + rand() % (MAP_H - 20);
        quizzes[i].type = QUIZ;
        quizzes[i].completed = 0;
        
        // Create sample questions (in a real game, these would be more varied)
        int state_idx = rand() % NUM_STATES;
        sprintf(quizzes[i].question, "What is the capital of %s?", states[state_idx].name);
        
        // Create options - one correct, three random
        int correct_idx = rand() % 4;
        for (int j = 0; j < 4; j++) {
            if (j == correct_idx) {
                strcpy(quizzes[i].options[j], states[state_idx].capital);
            } else {
                int random_state = rand() % NUM_STATES;
                strcpy(quizzes[i].options[j], states[random_state].capital);
            }
        }
        quizzes[i].correct_answer = correct_idx;
    }
    
    // Initialize flag challenges
    for (int i = 0; i < 15; i++) {
        flag_challenges[i].x = 15 + rand() % (MAP_W - 30);
        flag_challenges[i].y = 15 + rand() % (MAP_H - 30);
        flag_challenges[i].type = FLAG_CHALLENGE;
        flag_challenges[i].completed = 0;
        
        int state_idx = rand() % NUM_STATES;
        strcpy(flag_challenges[i].state_abbr, states[state_idx].abbreviation);
    }
}

/**
 * Draw the USA map
 */
void draw_usa_map() {
    cls();
    
    // Draw header with player stats
    printf("🇺🇸 USA Explorer: States & Capitals | Level: %d | Knowledge: %d\n\n", 
           current_level, player.knowledge);
    
    printf("States: %d/50 | Capitals: %d/50 | Flags: %d/50 | Streak: %d %s\n\n", 
           player.states_discovered, player.capitals_learned, player.flags_mastered,
           player.streak, streak_emoji[player.streak / 5]);
    
    // Draw the map
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
            
            // Draw ocean/background pattern
            int pattern_val = (wx * 7 + wy * 13) % 20;
            if (pattern_val < 3) c = "~ ";
            else if (pattern_val < 6) c = "≈ ";
            
            // Draw states
            for (int i = 0; i < NUM_STATES; i++) {
                if (wx >= states[i].x && wx < states[i].x + states[i].width &&
                    wy >= states[i].y && wy < states[i].y + states[i].height) {
                    
                    if (states[i].discovered) {
                        c = states[i].flag_emoji;
                    } else {
                        c = "■ "; // Undiscovered state
                    }
                    break;
                }
            }
            
            // Draw quizzes
            for (int i = 0; i < 20; i++) {
                if (quizzes[i].x == wx && quizzes[i].y == wy) {
                    if (quizzes[i].completed) {
                        c = "✅";
                    } else {
                        c = "❓";
                    }
                    break;
                }
            }
            
            // Draw flag challenges
            for (int i = 0; i < 15; i++) {
                if (flag_challenges[i].x == wx && flag_challenges[i].y == wy) {
                    if (flag_challenges[i].completed) {
                        c = "🏁";
                    } else {
                        c = "🏴";
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
    printf("\nControls: WASD to move | SPACE to interact | M to change mode | P for progress | Q to quit\n");
    printf("Mode: %s | Motivation: %d/100 | Learning Intensity: %d\n", 
           mode_emoji[player.game_mode], player.motivation, learning_intensity);
    
    // Show positive affirmations periodically
    if (positive_affirmation_timer <= 0) {
        show_positive_affirmation();
        positive_affirmation_timer = 50 + rand() % 100;
    }
    
    // Show subliminal messages
    if (subliminal_timer <= 0) {
        show_subliminal_message();
        subliminal_timer = 30 + rand() % 50;
    }
}

/**
 * Show positive affirmation
 */
void show_positive_affirmation() {
    int idx = rand() % (sizeof(affirmations) / sizeof(affirmations[0]));
    printf("\n💖 %s\n", affirmations[idx]);
}

/**
 * Show subliminal message
 */
void show_subliminal_message() {
    int idx = rand() % (sizeof(subliminal_messages) / sizeof(subliminal_messages[0]));
    // Display briefly and subtly
    printf("\n   %s   \n", subliminal_messages[idx]);
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
            // Check for state discovery
            for (int i = 0; i < NUM_STATES; i++) {
                if (player.x >= states[i].x && player.x < states[i].x + states[i].width &&
                    player.y >= states[i].y && player.y < states[i].y + states[i].height) {
                    discover_state(i);
                    break;
                }
            }
            
            // Check for quizzes
            for (int i = 0; i < 20; i++) {
                if (abs(quizzes[i].x - player.x) <= 1 && 
                    abs(quizzes[i].y - player.y) <= 1) {
                    start_quiz(i);
                    break;
                }
            }
            
            // Check for flag challenges
            for (int i = 0; i < 15; i++) {
                if (abs(flag_challenges[i].x - player.x) <= 1 && 
                    abs(flag_challenges[i].y - player.y) <= 1) {
                    start_flag_challenge(i);
                    break;
                }
            }
            break;
        case 'm':
            player.game_mode = (player.game_mode + 1) % 4;
            printf("\n🔄 Mode changed to: ");
            switch (player.game_mode) {
                case EXPLORATION: printf("Exploration\n"); break;
                case QUIZ: printf("Quiz Mode\n"); break;
                case FLAG_CHALLENGE: printf("Flag Challenge\n"); break;
                case CAPITAL_MATCH: printf("Capital Match\n"); break;
            }
            usleep(1000000);
            break;
        case 'p':
            show_progress_dashboard();
            break;
        case 'q':
            printf("Thanks for playing USA Explorer!\n");
            printf("Final Knowledge: %d | States Discovered: %d/50\n", 
                   player.knowledge, player.states_discovered);
            restore_terminal();
            exit(0);
    }
}

/**
 * Discover a state and learn about it
 */
void discover_state(int state_index) {
    State *s = &states[state_index];
    
    if (!s->discovered) {
        printf("\n🎉 You discovered %s! (%s)\n", s->name, region_emoji[s->region]);
        printf("Capital: %s\n", s->capital);
        printf("Abbreviation: %s\n", s->abbreviation);
        printf("Flag: %s\n", s->flag_emoji);
        
        s->discovered = 1;
        player.states_discovered++;
        player.capitals_learned++;
        player.flags_mastered++;
        player.knowledge += 10;
        player.exploration_progress++;
        
        update_streak(1);
        unlock_achievement("State Discoverer");
        
        // Check for region completion
        int region_complete = 1;
        for (int i = 0; i < NUM_STATES; i++) {
            if (states[i].region == s->region && !states[i].discovered) {
                region_complete = 0;
                break;
            }
        }
        
        if (region_complete) {
            printf("\n🏆 You've completed the %s region!\n", 
                   s->region == NEW_ENGLAND ? "New England" :
                   s->region == MID_ATLANTIC ? "Mid-Atlantic" :
                   s->region == MIDWEST ? "Midwest" :
                   s->region == SOUTH ? "South" :
                   s->region == WEST ? "West" : "Pacific");
            player.knowledge += 25;
            unlock_achievement("Region Explorer");
        }
        
        learning_intensity += 2;
    } else {
        printf("\n🏠 You're in %s (%s)\n", s->name, s->flag_emoji);
        printf("Capital: %s\n", s->capital);
        
        // Reinforcement learning - show a random fact
        int fact_num = rand() % 3;
        switch (fact_num) {
            case 0: printf("Remember: %s is the capital\n", s->capital); break;
            case 1: printf("Abbreviation: %s\n", s->abbreviation); break;
            case 2: printf("Flag: %s\n", s->flag_emoji); break;
        }
        
        player.knowledge += 2;
        update_streak(1);
    }
    
    usleep(2500000);
}

/**
 * Start a quiz
 */
void start_quiz(int quiz_index) {
    QuizChallenge *q = &quizzes[quiz_index];
    
    if (q->completed) {
        printf("\n✅ You've already completed this quiz!\n");
        usleep(1000000);
        return;
    }
    
    printf("\n📝 GEOGRAPHY QUIZ:\n");
    printf("%s\n", q->question);
    for (int i = 0; i < 4; i++) {
        printf("%d. %s\n", i+1, q->options[i]);
    }
    printf("Enter your answer (1-4): ");
    
    // Switch to blocking mode for input
    restore_terminal();
    
    char answer_str[10];
    fgets(answer_str, 10, stdin);
    int answer = atoi(answer_str) - 1;
    
    // Set back to non-blocking mode
    set_nonblocking_mode();
    
    if (answer == q->correct_answer) {
        printf("✅ Correct! +20 knowledge points\n");
        q->completed = 1;
        player.quizzes_completed++;
        player.knowledge += 20;
        player.capitals_learned++;
        
        update_streak(1);
        unlock_achievement("Quiz Master");
        
        // Show special affirmation for correct answers
        printf("💡 %s\n", affirmations[rand() % (sizeof(affirmations) / sizeof(affirmations[0]))]);
    } else {
        printf("❌ Incorrect. The right answer was %d. %s\n", 
               q->correct_answer + 1, q->options[q->correct_answer]);
        player.knowledge += 5; // Still learn something from mistakes
        update_streak(0);
    }
    
    usleep(2500000);
}

/**
 * Start a flag challenge
 */
void start_flag_challenge(int challenge_index) {
    FlagChallenge *fc = &flag_challenges[challenge_index];
    
    if (fc->completed) {
        printf("\n✅ You've already completed this flag challenge!\n");
        usleep(1000000);
        return;
    }
    
    // Find the state for this abbreviation
    State *target_state = NULL;
    for (int i = 0; i < NUM_STATES; i++) {
        if (strcmp(states[i].abbreviation, fc->state_abbr) == 0) {
            target_state = &states[i];
            break;
        }
    }
    
    if (!target_state) {
        printf("Error: State not found for abbreviation %s\n", fc->state_abbr);
        return;
    }
    
    printf("\n🏴 FLAG CHALLENGE:\n");
    printf("Which state has the flag %s?\n", target_state->flag_emoji);
    printf("Enter the state name: ");
    
    // Switch to blocking mode for input
    restore_terminal();
    
    char answer[50];
    fgets(answer, 50, stdin);
    answer[strcspn(answer, "\n")] = 0;
    
    // Set back to non-blocking mode
    set_nonblocking_mode();
    
    if (strcasecmp(answer, target_state->name) == 0) {
        printf("✅ Correct! %s is right. +15 knowledge points\n", target_state->name);
        fc->completed = 1;
        player.flags_mastered++;
        player.knowledge += 15;
        
        update_streak(1);
        unlock_achievement("Flag Expert");
    } else {
        printf("❌ Incorrect. The answer was %s.\n", target_state->name);
        player.knowledge += 5;
        update_streak(0);
    }
    
    usleep(2500000);
}

/**
 * Update learning streak
 */
void update_streak(int success) {
    if (success) {
        player.streak++;
        player.motivation += 2;
        if (player.motivation > 100) player.motivation = 100;
        
        // Special rewards for streak milestones
        if (player.streak % 5 == 0) {
            printf("\n%s %d answer streak! Keep going!\n", 
                   streak_emoji[player.streak / 5], player.streak);
            player.knowledge += 10;
        }
    } else {
        player.streak = 0;
        player.motivation -= 5;
        if (player.motivation < 0) player.motivation = 0;
        printf("\n💔 Streak broken. You can start a new one!\n");
    }
}

/**
 * Show progress dashboard
 */
void show_progress_dashboard() {
    cls();
    printf("📊 USA EXPLORER PROGRESS DASHBOARD\n\n");
    
    printf("Overall Knowledge: %d/100\n", player.knowledge);
    printf("States Discovered: %d/50\n", player.states_discovered);
    printf("Capitals Learned: %d/50\n", player.capitals_learned);
    printf("Flags Mastered: %d/50\n", player.flags_mastered);
    printf("Quizzes Completed: %d/20\n", player.quizzes_completed);
    printf("Current Streak: %d\n\n", player.streak);
    
    printf("Region Progress:\n");
    int region_counts[6] = {0};
    int region_discovered[6] = {0};
    
    for (int i = 0; i < NUM_STATES; i++) {
        region_counts[states[i].region]++;
        if (states[i].discovered) {
            region_discovered[states[i].region]++;
        }
    }
    
    const char *region_names[] = {"New England", "Mid-Atlantic", "Midwest", "South", "West", "Pacific"};
    for (int i = 0; i < 6; i++) {
        if (region_counts[i] > 0) {
            int percent = (region_discovered[i] * 100) / region_counts[i];
            printf("%s %s: %d/%d (%d%%)\n", 
                   region_emoji[i], region_names[i], 
                   region_discovered[i], region_counts[i], percent);
        }
    }
    
    printf("\nPress any key to continue...");
    char dummy;
    read(STDIN_FILENO, &dummy, 1);
}

/**
 * Unlock an achievement
 */
void unlock_achievement(const char *achievement) {
    printf("\n🏆 Achievement Unlocked: %s!\n", achievement);
    player.motivation += 10;
    if (player.motivation > 100) player.motivation = 100;
    usleep(1500000);
}

/**
 * Update game state
 */
void update_game() {
    game_time++;
    
    // Update timers
    if (positive_affirmation_timer > 0) positive_affirmation_timer--;
    if (subliminal_timer > 0) subliminal_timer--;
    
    // Update motivation
    update_motivation();
    
    // Adjust learning intensity based on performance
    adjust_learning_intensity();
    
    // Check for level advancement
    if (player.knowledge >= current_level * 25) {
        current_level++;
        printf("\n🎉 Level Up! You reached level %d\n", current_level);
        printf("Your geography knowledge is expanding!\n");
        
        // Special reward for leveling up
        player.motivation += 15;
        if (player.motivation > 100) player.motivation = 100;
        
        unlock_achievement("Geography Scholar");
        
        usleep(2000000);
    }
    
    // Check for game completion
    if (player.states_discovered >= 50 && player.capitals_learned >= 50 && player.flags_mastered >= 50) {
        printf("\n🎊 CONGRATULATIONS! You've mastered all 50 US states!\n");
        printf("You're now a USA geography expert!\n");
        restore_terminal();
        exit(0);
    }
}

/**
 * Update motivation
 */
void update_motivation() {
    // Motivation naturally decreases over time but can be maintained with progress
    if (game_time % 50 == 0) {
        player.motivation--;
        if (player.motivation < 0) player.motivation = 0;
    }
    
    // Boost motivation when making progress
    if (player.exploration_progress >= 5) {
        player.motivation += 2;
        player.exploration_progress = 0;
        if (player.motivation > 100) player.motivation = 100;
    }
}

/**
 * Adjust learning intensity based on performance
 */
void adjust_learning_intensity() {
    // Increase intensity with higher knowledge and streak
    int target_intensity = 50 + (player.knowledge / 2) + (player.streak * 2);
    if (target_intensity > 100) target_intensity = 100;
    
    // Gradually adjust toward target intensity
    if (learning_intensity < target_intensity) {
        learning_intensity++;
    } else if (learning_intensity > target_intensity) {
        learning_intensity--;
    }
}

/**
 * Main game loop
 */
int main() {
    set_nonblocking_mode();
    init_game();
    
    printf("🇺🇸 Welcome to USA Explorer: States & Capitals!\n\n");
    printf("Learn all 50 US states, their capitals, and flag emojis in this engaging adventure!\n\n");
    printf("Educational features:\n");
    printf("• All 50 states with accurate geographic positions\n• State capitals\n");
    printf("• State abbreviations\n• Flag emojis\n• Interactive quizzes\n• Positive affirmations\n\n");
    printf("Press any key to begin your USA geography adventure...");
    
    char dummy;
    read(STDIN_FILENO, &dummy, 1);
    
    char input;
    while (1) {
        draw_usa_map();
        
        if (read(STDIN_FILENO, &input, 1) > 0) {
            handle_input(input);
        }
        
        update_game();
        usleep(100000); // 100ms delay
    }
    
    restore_terminal();
    return 0;
}