#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>
#include <math.h>

#define NUM_SUBJECTS 10
#define PREDICTION_HISTORY 5
#define MAX_PATTERNS 20

// Learning subjects
#define MATH 0
#define GEOGRAPHY 1
#define SCIENCE 2
#define HISTORY 3
#define LANGUAGE 4
#define ART 5
#define MUSIC 6
#define TECHNOLOGY 7
#define HEALTH 8
#define CURRENT_EVENTS 9

typedef struct {
    int subject;
    char topic[50];
    char question[100];
    char options[4][50];
    int correct_answer;
    int difficulty;
    int engagement;
} LearningModule;

typedef struct {
    int pattern[NUM_SUBJECTS];
    int frequency;
    int confidence;
} PredictionPattern;

typedef struct {
    int subject_preferences[NUM_SUBJECTS];
    int learning_style; // 0=visual, 1=auditory, 2=kinesthetic
    int attention_span;
    int recent_subjects[PREDICTION_HISTORY];
    int recent_answers[PREDICTION_HISTORY];
    int prediction_accuracy;
    int engagement_level;
    int learning_momentum;
} UserProfile;

typedef struct {
    int x, y;
    int subject;
    char symbol[10];
    int value;
    int active;
} ThoughtBubble;

// Game state
LearningModule modules[50];
PredictionPattern patterns[MAX_PATTERNS];
UserProfile user;
ThoughtBubble thoughts[15];

int game_time = 0;
int prediction_mode = 0;
int current_prediction = -1;
int learning_intensity = 50;
int insight_level = 0;
int surprise_factor = 0;

// Subject emojis
const char *subject_emoji[] = {"📊", "🌎", "🔬", "📜", "🔤", "🎨", "🎵", "💻", "❤️", "📰"};
const char *style_emoji[] = {"👀", "👂", "✋"};
const char *prediction_emoji[] = {"🔮", "🧠", "✨", "🌟"};

// Function prototypes
void set_nonblocking_mode();
void restore_terminal();
void cls();
void init_game();
void draw_game();
void handle_input(char input);
void update_game();
void generate_learning_module(int subject);
void make_prediction();
void update_user_profile(int subject, int engagement, int correct);
void analyze_learning_patterns();
void show_insight();
void adjust_difficulty();
void create_thought_bubble(int subject, int x, int y);
void update_thoughts();
void show_prediction_result();
void provide_feedback();
void unlock_achievement(const char *achievement);

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
    
    // Initialize user profile
    for (int i = 0; i < NUM_SUBJECTS; i++) {
        user.subject_preferences[i] = 50;
    }
    user.learning_style = rand() % 3;
    user.attention_span = 70;
    user.prediction_accuracy = 0;
    user.engagement_level = 75;
    user.learning_momentum = 0;
    
    for (int i = 0; i < PREDICTION_HISTORY; i++) {
        user.recent_subjects[i] = -1;
        user.recent_answers[i] = -1;
    }
    
    // Initialize prediction patterns
    for (int i = 0; i < MAX_PATTERNS; i++) {
        for (int j = 0; j < NUM_SUBJECTS; j++) {
            patterns[i].pattern[j] = 0;
        }
        patterns[i].frequency = 0;
        patterns[i].confidence = 0;
    }
    
    // Generate initial learning modules
    for (int i = 0; i < 50; i++) {
        generate_learning_module(rand() % NUM_SUBJECTS);
    }
    
    // Initialize thought bubbles
    for (int i = 0; i < 15; i++) {
        thoughts[i].active = 0;
    }
    
    // Create initial thought bubbles
    for (int i = 0; i < 5; i++) {
        create_thought_bubble(rand() % NUM_SUBJECTS, 10 + rand() % 80, 5 + rand() % 30);
    }
}

/**
 * Generate a learning module for a subject
 */
void generate_learning_module(int subject) {
    static int module_count = 0;
    if (module_count >= 50) return;
    
    LearningModule *m = &modules[module_count];
    m->subject = subject;
    m->difficulty = 1 + rand() % 5;
    m->engagement = 30 + rand() % 70;
    
    // Set topic and question based on subject and difficulty
    switch (subject) {
        case MATH:
            strcpy(m->topic, "Mathematics");
            if (m->difficulty == 1) {
                strcpy(m->question, "What is 7 + 5?");
                strcpy(m->options[0], "10");
                strcpy(m->options[1], "11");
                strcpy(m->options[2], "12");
                strcpy(m->options[3], "13");
                m->correct_answer = 2;
            } else if (m->difficulty == 2) {
                strcpy(m->question, "What is 15 × 3?");
                strcpy(m->options[0], "35");
                strcpy(m->options[1], "40");
                strcpy(m->options[2], "45");
                strcpy(m->options[3], "50");
                m->correct_answer = 2;
            } else {
                strcpy(m->question, "Solve for x: 2x + 5 = 15");
                strcpy(m->options[0], "x = 3");
                strcpy(m->options[1], "x = 4");
                strcpy(m->options[2], "x = 5");
                strcpy(m->options[3], "x = 6");
                m->correct_answer = 2;
            }
            break;
            
        case GEOGRAPHY:
            strcpy(m->topic, "Geography");
            if (m->difficulty == 1) {
                strcpy(m->question, "What is the capital of France?");
                strcpy(m->options[0], "London");
                strcpy(m->options[1], "Berlin");
                strcpy(m->options[2], "Paris");
                strcpy(m->options[3], "Madrid");
                m->correct_answer = 2;
            } else if (m->difficulty == 2) {
                strcpy(m->question, "Which ocean is the largest?");
                strcpy(m->options[0], "Atlantic");
                strcpy(m->options[1], "Indian");
                strcpy(m->options[2], "Arctic");
                strcpy(m->options[3], "Pacific");
                m->correct_answer = 3;
            } else {
                strcpy(m->question, "Which country has the most population?");
                strcpy(m->options[0], "India");
                strcpy(m->options[1], "USA");
                strcpy(m->options[2], "China");
                strcpy(m->options[3], "Russia");
                m->correct_answer = 2;
            }
            break;
            
        // Add cases for other subjects...
        default:
            strcpy(m->topic, "General Knowledge");
            strcpy(m->question, "What is the chemical symbol for water?");
            strcpy(m->options[0], "O2");
            strcpy(m->options[1], "CO2");
            strcpy(m->options[2], "H2O");
            strcpy(m->options[3], "N2");
            m->correct_answer = 2;
            break;
    }
    
    module_count++;
}

/**
 * Draw the game interface
 */
void draw_game() {
    cls();
    
    // Draw header
    printf("🧠 MindReader: Educational Prediction Game | Insight: %d | Prediction Accuracy: %d%%\n\n", 
           insight_level, user.prediction_accuracy);
    
    printf("Learning Style: %s | Attention: %d%% | Engagement: %d%% | Momentum: %d\n\n", 
           style_emoji[user.learning_style], user.attention_span, 
           user.engagement_level, user.learning_momentum);
    
    // Draw the thought space
    for (int y = 0; y < 20; y++) {
        for (int x = 0; x < 60; x++) {
            const char *c = "  "; // Default empty space
            
            // Draw thought bubbles
            for (int i = 0; i < 15; i++) {
                if (thoughts[i].active && thoughts[i].x == x && thoughts[i].y == y) {
                    c = subject_emoji[thoughts[i].subject];
                    break;
                }
            }
            
            // Draw prediction center
            if (x == 30 && y == 10) {
                if (prediction_mode) {
                    c = prediction_emoji[rand() % 4];
                } else {
                    c = "🧠";
                }
            }
            
            printf("%s", c);
        }
        printf("\n");
    }
    
    // Draw footer
    printf("\nControls: SPACE to interact | P to make prediction | I for insights | Q to quit\n");
    printf("Prediction Mode: %s | Learning Intensity: %d | Surprise Factor: %d\n", 
           prediction_mode ? "Active" : "Inactive", learning_intensity, surprise_factor);
    
    // Show current prediction if active
    if (prediction_mode && current_prediction >= 0) {
        printf("\n🔮 I predict you want to learn about: %s\n", 
               subject_emoji[current_prediction]);
    }
    
    // Show insights periodically
    if (game_time % 100 == 0) {
        show_insight();
    }
}

/**
 * Make a prediction about what the user wants to learn
 */
void make_prediction() {
    if (prediction_mode) {
        printf("\n🎯 Already in prediction mode!\n");
        return;
    }
    
    prediction_mode = 1;
    printf("\n🔮 Activating prediction mode...\n");
    
    // Analyze patterns to make prediction
    analyze_learning_patterns();
    
    // Choose prediction based on user preferences and patterns
    int max_preference = 0;
    int predicted_subject = 0;
    
    for (int i = 0; i < NUM_SUBJECTS; i++) {
        if (user.subject_preferences[i] > max_preference) {
            max_preference = user.subject_preferences[i];
            predicted_subject = i;
        }
    }
    
    // Add some randomness based on patterns
    for (int i = 0; i < MAX_PATTERNS; i++) {
        if (patterns[i].frequency > 3 && patterns[i].confidence > 60) {
            for (int j = 0; j < NUM_SUBJECTS; j++) {
                if (patterns[i].pattern[j] > 0 && rand() % 100 < patterns[i].confidence) {
                    predicted_subject = j;
                    break;
                }
            }
        }
    }
    
    current_prediction = predicted_subject;
    printf("I predict you're interested in %s learning right now!\n", 
           subject_emoji[predicted_subject]);
    
    // Create thought bubbles related to prediction
    for (int i = 0; i < 3; i++) {
        create_thought_bubble(predicted_subject, 15 + rand() % 45, 5 + rand() % 15);
    }
    
    usleep(2000000);
}

/**
 * Analyze learning patterns to improve predictions
 */
void analyze_learning_patterns() {
    // Simple pattern analysis based on recent subjects
    for (int i = 0; i < PREDICTION_HISTORY - 2; i++) {
        if (user.recent_subjects[i] != -1 && 
            user.recent_subjects[i+1] != -1 &&
            user.recent_subjects[i+2] != -1) {
            
            // Look for existing pattern or create new one
            int pattern_index = -1;
            for (int j = 0; j < MAX_PATTERNS; j++) {
                if (patterns[j].pattern[0] == user.recent_subjects[i] &&
                    patterns[j].pattern[1] == user.recent_subjects[i+1] &&
                    patterns[j].pattern[2] == user.recent_subjects[i+2]) {
                    pattern_index = j;
                    break;
                }
            }
            
            if (pattern_index == -1) {
                // Find empty pattern slot
                for (int j = 0; j < MAX_PATTERNS; j++) {
                    if (patterns[j].frequency == 0) {
                        pattern_index = j;
                        patterns[j].pattern[0] = user.recent_subjects[i];
                        patterns[j].pattern[1] = user.recent_subjects[i+1];
                        patterns[j].pattern[2] = user.recent_subjects[i+2];
                        break;
                    }
                }
            }
            
            if (pattern_index != -1) {
                patterns[pattern_index].frequency++;
                
                // Increase confidence if answers were correct
                int correct_answers = 0;
                for (int k = i; k < i + 3; k++) {
                    if (user.recent_answers[k] == 1) {
                        correct_answers++;
                    }
                }
                
                patterns[pattern_index].confidence = (correct_answers * 100) / 3;
            }
        }
    }
}

/**
 * Update user profile based on interaction
 */
void update_user_profile(int subject, int engagement, int correct) {
    // Update subject preferences
    if (correct) {
        user.subject_preferences[subject] += 10;
        user.learning_momentum += 5;
    } else {
        user.subject_preferences[subject] += 5;
        user.learning_momentum -= 3;
    }
    
    // Cap values
    if (user.subject_preferences[subject] > 100) {
        user.subject_preferences[subject] = 100;
    }
    if (user.subject_preferences[subject] < 0) {
        user.subject_preferences[subject] = 0;
    }
    
    // Update engagement
    user.engagement_level = (user.engagement_level * 0.7) + (engagement * 0.3);
    
    // Update attention span based on engagement
    if (engagement > 70) {
        user.attention_span += 5;
    } else {
        user.attention_span -= 3;
    }
    
    if (user.attention_span > 100) user.attention_span = 100;
    if (user.attention_span < 0) user.attention_span = 0;
    
    // Update learning momentum
    if (correct && engagement > 60) {
        user.learning_momentum += 10;
    } else {
        user.learning_momentum -= 5;
    }
    
    if (user.learning_momentum > 100) user.learning_momentum = 100;
    if (user.learning_momentum < 0) user.learning_momentum = 0;
    
    // Update recent history
    for (int i = PREDICTION_HISTORY - 1; i > 0; i--) {
        user.recent_subjects[i] = user.recent_subjects[i-1];
        user.recent_answers[i] = user.recent_answers[i-1];
    }
    user.recent_subjects[0] = subject;
    user.recent_answers[0] = correct;
    
    // Update prediction accuracy if in prediction mode
    if (prediction_mode && current_prediction == subject) {
        user.prediction_accuracy = (user.prediction_accuracy * 0.9) + 10;
        surprise_factor += 5;
        unlock_achievement("Accurate Prediction");
    } else if (prediction_mode) {
        user.prediction_accuracy = (user.prediction_accuracy * 0.9);
        surprise_factor -= 3;
    }
    
    if (user.prediction_accuracy > 100) user.prediction_accuracy = 100;
    if (user.prediction_accuracy < 0) user.prediction_accuracy = 0;
    
    if (surprise_factor > 100) surprise_factor = 100;
    if (surprise_factor < 0) surprise_factor = 0;
}

/**
 * Show learning insights
 */
void show_insight() {
    // Find strongest subject preference
    int max_preference = 0;
    int best_subject = 0;
    
    for (int i = 0; i < NUM_SUBJECTS; i++) {
        if (user.subject_preferences[i] > max_preference) {
            max_preference = user.subject_preferences[i];
            best_subject = i;
        }
    }
    
    // Find learning patterns
    int strongest_pattern = -1;
    int pattern_strength = 0;
    
    for (int i = 0; i < MAX_PATTERNS; i++) {
        if (patterns[i].frequency > pattern_strength && patterns[i].confidence > 70) {
            pattern_strength = patterns[i].frequency;
            strongest_pattern = i;
        }
    }
    
    // Show insights based on analysis
    if (max_preference > 70) {
        printf("\n💡 Insight: You seem to really enjoy %s topics!\n", 
               subject_emoji[best_subject]);
        insight_level += 5;
    }
    
    if (strongest_pattern != -1) {
        printf("💡 Pattern detected: You often study %s after %s and %s\n",
               subject_emoji[patterns[strongest_pattern].pattern[0]],
               subject_emoji[patterns[strongest_pattern].pattern[1]],
               subject_emoji[patterns[strongest_pattern].pattern[2]]);
        insight_level += 10;
    }
    
    if (user.learning_momentum > 70) {
        printf("💡 You're in a learning flow state! Momentum is high.\n");
    }
    
    if (insight_level > 100) insight_level = 100;
    
    usleep(2500000);
}

/**
 * Create a thought bubble
 */
void create_thought_bubble(int subject, int x, int y) {
    for (int i = 0; i < 15; i++) {
        if (!thoughts[i].active) {
            thoughts[i].subject = subject;
            thoughts[i].x = x;
            thoughts[i].y = y;
            thoughts[i].value = 10 + rand() % 40;
            thoughts[i].active = 1;
            strcpy(thoughts[i].symbol, subject_emoji[subject]);
            break;
        }
    }
}

/**
 * Update thought bubbles
 */
void update_thoughts() {
    for (int i = 0; i < 15; i++) {
        if (thoughts[i].active) {
            // Move thought bubbles slightly
            thoughts[i].x += rand() % 3 - 1;
            thoughts[i].y += rand() % 3 - 1;
            
            // Keep in bounds
            if (thoughts[i].x < 0) thoughts[i].x = 0;
            if (thoughts[i].x >= 60) thoughts[i].x = 59;
            if (thoughts[i].y < 0) thoughts[i].y = 0;
            if (thoughts[i].y >= 20) thoughts[i].y = 19;
            
            // Occasionally deactivate thoughts
            if (rand() % 50 == 0) {
                thoughts[i].active = 0;
            }
        } else if (rand() % 100 == 0) {
            // Create new thought bubble
            create_thought_bubble(rand() % NUM_SUBJECTS, rand() % 60, rand() % 20);
        }
    }
}

/**
 * Handle user interaction with thought bubbles
 */
void handle_thought_interaction() {
    for (int i = 0; i < 15; i++) {
        if (thoughts[i].active) {
            // Simple interaction check (in real game, would use proper coordinates)
            if (rand() % 5 == 0) {
                printf("\n💭 You encountered a %s thought!\n", subject_emoji[thoughts[i].subject]);
                
                // Present learning module for this subject
                int module_index = -1;
                for (int j = 0; j < 50; j++) {
                    if (modules[j].subject == thoughts[i].subject) {
                        module_index = j;
                        break;
                    }
                }
                
                if (module_index != -1) {
                    LearningModule *m = &modules[module_index];
                    
                    printf("\n%s %s\n", subject_emoji[m->subject], m->topic);
                    printf("Question: %s\n", m->question);
                    for (int k = 0; k < 4; k++) {
                        printf("%d. %s\n", k+1, m->options[k]);
                    }
                    
                    printf("Enter your answer (1-4): ");
                    
                    // Switch to blocking mode for input
                    restore_terminal();
                    
                    char answer_str[10];
                    fgets(answer_str, 10, stdin);
                    int answer = atoi(answer_str) - 1;
                    
                    // Set back to non-blocking mode
                    set_nonblocking_mode();
                    
                    if (answer == m->correct_answer) {
                        printf("✅ Correct! +%d knowledge\n", m->difficulty * 10);
                        update_user_profile(m->subject, m->engagement, 1);
                    } else {
                        printf("❌ Incorrect. The answer was %d. %s\n", 
                               m->correct_answer + 1, m->options[m->correct_answer]);
                        update_user_profile(m->subject, m->engagement / 2, 0);
                    }
                    
                    thoughts[i].active = 0;
                    usleep(2500000);
                    return;
                }
            }
        }
    }
    
    printf("\n💭 No active thoughts to interact with. Try moving around.\n");
    usleep(1500000);
}

/**
 * Unlock an achievement
 */
void unlock_achievement(const char *achievement) {
    printf("\n🏆 Achievement Unlocked: %s!\n", achievement);
    user.engagement_level += 10;
    if (user.engagement_level > 100) user.engagement_level = 100;
    usleep(1500000);
}

/**
 * Handle user input
 */
void handle_input(char input) {
    switch (input) {
        case ' ':
            handle_thought_interaction();
            break;
        case 'p':
            make_prediction();
            break;
        case 'i':
            show_insight();
            break;
        case 'q':
            printf("Thanks for playing MindReader!\n");
            printf("Final Insight Level: %d | Prediction Accuracy: %d%%\n", 
                   insight_level, user.prediction_accuracy);
            restore_terminal();
            exit(0);
    }
}

/**
 * Update game state
 */
void update_game() {
    game_time++;
    
    // Update thought bubbles
    update_thoughts();
    
    // Adjust learning intensity based on engagement
    learning_intensity = (user.engagement_level + user.attention_span) / 2;
    
    // Occasionally make automatic predictions
    if (!prediction_mode && game_time % 150 == 0) {
        make_prediction();
    }
    
    // Adjust difficulty based on performance
    adjust_difficulty();
    
    // Provide feedback periodically
    if (game_time % 120 == 0) {
        provide_feedback();
    }
    
    // Check for special achievements
    if (user.prediction_accuracy >= 80) {
        unlock_achievement("Mind Reader Expert");
    }
    if (insight_level >= 90) {
        unlock_achievement("Deep Insight");
    }
    if (user.learning_momentum >= 90) {
        unlock_achievement("Learning Flow Master");
    }
}

/**
 * Adjust difficulty based on user performance
 */
void adjust_difficulty() {
    // Increase difficulty if user is performing well
    if (user.learning_momentum > 70) {
        for (int i = 0; i < 50; i++) {
            if (modules[i].difficulty < 5 && rand() % 10 == 0) {
                modules[i].difficulty++;
                modules[i].engagement += 10;
                if (modules[i].engagement > 100) modules[i].engagement = 100;
            }
        }
    }
    
    // Decrease difficulty if user is struggling
    if (user.learning_momentum < 30) {
        for (int i = 0; i < 50; i++) {
            if (modules[i].difficulty > 1 && rand() % 10 == 0) {
                modules[i].difficulty--;
                modules[i].engagement -= 5;
                if (modules[i].engagement < 10) modules[i].engagement = 10;
            }
        }
    }
}

/**
 * Provide feedback to the user
 */
void provide_feedback() {
    if (user.learning_momentum > 70) {
        printf("\n🌟 You're doing great! Your learning momentum is strong.\n");
    } else if (user.learning_momentum < 30) {
        printf("\n💪 Keep going! Learning gets easier with practice.\n");
    }
    
    if (user.prediction_accuracy > 75) {
        printf("🔮 My predictions are getting more accurate! I'm learning how you think.\n");
    }
    
    usleep(2000000);
}

/**
 * Main game loop
 */
int main() {
    set_nonblocking_mode();
    init_game();
    
    printf("🧠 Welcome to MindReader: The Educational Prediction Game!\n\n");
    printf("This game learns how you think and predicts what you want to learn before you know it yourself!\n\n");
    printf("Features:\n");
    printf("• Adaptive learning that responds to your preferences\n");
    printf("• Pattern recognition that predicts your learning interests\n");
    printf("• Psychological insights about your learning style\n");
    printf("• Progressive difficulty that matches your ability\n\n");
    printf("Press any key to begin this mind-reading educational experience...");
    
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