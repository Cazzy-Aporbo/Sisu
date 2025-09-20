#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>
#include <math.h>

#define PREDICTION_HISTORY 10
#define MAX_PATTERNS 50
#define REQUEST_TYPES 15
#define TEMPORAL_WINDOWS 5

typedef struct {
    int request_type;
    char content[100];
    long timestamp;
    int complexity;
    int emotional_valence; // -5 to +5
    int urgency;
    int fulfilled;
} UserRequest;

typedef struct {
    int pattern[PREDICTION_HISTORY];
    int frequency;
    int confidence;
    int temporal_pattern[TEMPORAL_WINDOWS];
    int context_sensitivity;
} PredictionModel;

typedef struct {
    int attention_level;
    int curiosity_index;
    int satisfaction_level;
    int predictability_score;
    long last_interaction_time;
    int request_frequency;
    int mood_pattern[24]; // Hourly mood trends
    int cognitive_load;
} UserState;

typedef struct {
    int active;
    char predicted_request[100];
    double confidence;
    char reasoning[200];
    long prediction_time;
    int prediction_model_used;
} PredictionResult;

// Global state
UserRequest request_history[PREDICTION_HISTORY];
PredictionModel prediction_models[MAX_PATTERNS];
UserState current_user;
PredictionResult active_prediction;

int prediction_cycle = 0;
int system_intelligence = 50;
int temporal_awareness = 0;
int contextual_understanding = 0;

// Request type categories
const char *request_types[] = {
    "LEARNING", "ENTERTAINMENT", "CREATIVE", "ANALYTICAL", "PRACTICAL",
    "EMOTIONAL", "SOCIAL", "TECHNICAL", "NOVELTY", "REFERENCE",
    "PROBLEM_SOLVING", "DECISION_MAKING", "MEMORY", "PREDICTION", "META"
};

const char *request_emojis[] = {
    "📚", "🎮", "🎨", "📊", "🛠️", "💖", "👥", "💻", "✨", "🔍",
    "🧩", "🤔", "🧠", "🔮", "🔄"
};

// Function prototypes
void init_system();
void analyze_user_patterns();
void make_prediction();
void update_user_state(int request_type, int complexity, int emotional_valence);
void temporal_analysis();
void contextual_analysis();
void display_prediction();
void execute_predicted_request();
void update_prediction_models(int accuracy);
void calculate_predictability();
void show_system_insights();
void handle_actual_request(char *request);

/**
 * Initialize the prediction system
 */
void init_system() {
    srand(time(NULL));
    
    // Initialize request history
    for (int i = 0; i < PREDICTION_HISTORY; i++) {
        request_history[i].request_type = -1;
        request_history[i].timestamp = 0;
        request_history[i].fulfilled = 0;
    }
    
    // Initialize prediction models
    for (int i = 0; i < MAX_PATTERNS; i++) {
        for (int j = 0; j < PREDICTION_HISTORY; j++) {
            prediction_models[i].pattern[j] = -1;
        }
        for (int j = 0; j < TEMPORAL_WINDOWS; j++) {
            prediction_models[i].temporal_pattern[j] = 0;
        }
        prediction_models[i].frequency = 0;
        prediction_models[i].confidence = 0;
        prediction_models[i].context_sensitivity = 50;
    }
    
    // Initialize user state
    current_user.attention_level = 70;
    current_user.curiosity_index = 60;
    current_user.satisfaction_level = 75;
    current_user.predictability_score = 50;
    current_user.last_interaction_time = time(NULL);
    current_user.request_frequency = 0;
    for (int i = 0; i < 24; i++) {
        current_user.mood_pattern[i] = 50 + rand() % 50;
    }
    current_user.cognitive_load = 40;
    
    // Initialize active prediction
    active_prediction.active = 0;
    active_prediction.confidence = 0.0;
}

/**
 * Analyze user patterns for prediction
 */
void analyze_user_patterns() {
    // Analyze recent request patterns
    int recent_pattern[PREDICTION_HISTORY];
    for (int i = 0; i < PREDICTION_HISTORY; i++) {
        recent_pattern[i] = request_history[i].request_type;
    }
    
    // Find matching pattern or create new one
    int pattern_index = -1;
    int max_similarity = 0;
    
    for (int i = 0; i < MAX_PATTERNS; i++) {
        if (prediction_models[i].frequency > 0) {
            int similarity = 0;
            for (int j = 0; j < PREDICTION_HISTORY; j++) {
                if (recent_pattern[j] != -1 && 
                    prediction_models[i].pattern[j] == recent_pattern[j]) {
                    similarity++;
                }
            }
            
            if (similarity > max_similarity) {
                max_similarity = similarity;
                pattern_index = i;
            }
        }
    }
    
    // If no good match found, find empty slot for new pattern
    if (pattern_index == -1) {
        for (int i = 0; i < MAX_PATTERNS; i++) {
            if (prediction_models[i].frequency == 0) {
                pattern_index = i;
                // Copy the recent pattern
                for (int j = 0; j < PREDICTION_HISTORY; j++) {
                    prediction_models[i].pattern[j] = recent_pattern[j];
                }
                break;
            }
        }
    }
    
    if (pattern_index != -1) {
        // Update pattern frequency and confidence
        prediction_models[pattern_index].frequency++;
        
        // Update temporal pattern
        long current_time = time(NULL);
        int hour = (current_time / 3600) % 24;
        prediction_models[pattern_index].temporal_pattern[hour % TEMPORAL_WINDOWS]++;
        
        // Update context sensitivity based on prediction accuracy
        if (active_prediction.active && active_prediction.confidence > 0.7) {
            prediction_models[pattern_index].context_sensitivity += 5;
            if (prediction_models[pattern_index].context_sensitivity > 100) {
                prediction_models[pattern_index].context_sensitivity = 100;
            }
        }
    }
    
    // Perform temporal analysis
    temporal_analysis();
    
    // Perform contextual analysis
    contextual_analysis();
}

/**
 * Make a prediction about the next request
 */
void make_prediction() {
    if (prediction_cycle++ % 3 != 0) return; // Not every cycle
    
    // Find the most reliable pattern
    int best_pattern = -1;
    int best_score = 0;
    
    for (int i = 0; i < MAX_PATTERNS; i++) {
        if (prediction_models[i].frequency > 0) {
            int score = prediction_models[i].confidence * 
                       prediction_models[i].context_sensitivity *
                       prediction_models[i].frequency;
            
            if (score > best_score) {
                best_score = score;
                best_pattern = i;
            }
        }
    }
    
    if (best_pattern == -1) {
        // No patterns yet, make random prediction
        active_prediction.active = 1;
        int random_type = rand() % REQUEST_TYPES;
        sprintf(active_prediction.predicted_request, "I predict you'll ask for something related to %s", 
                request_types[random_type]);
        active_prediction.confidence = 0.3;
        sprintf(active_prediction.reasoning, "Based on general user behavior patterns");
        active_prediction.prediction_time = time(NULL);
        active_prediction.prediction_model_used = -1;
        return;
    }
    
    // Make prediction based on the best pattern
    active_prediction.active = 1;
    active_prediction.prediction_model_used = best_pattern;
    
    // Predict next request type based on pattern
    int predicted_type = prediction_models[best_pattern].pattern[0]; // Most recent in pattern
    if (predicted_type == -1) {
        predicted_type = rand() % REQUEST_TYPES;
    }
    
    // Adjust prediction based on temporal patterns
    long current_time = time(NULL);
    int hour = (current_time / 3600) % 24;
    int temporal_influence = prediction_models[best_pattern].temporal_pattern[hour % TEMPORAL_WINDOWS];
    
    // Adjust prediction based on user state
    int user_state_influence = (current_user.attention_level + current_user.curiosity_index) / 2;
    
    // Calculate final confidence
    active_prediction.confidence = (prediction_models[best_pattern].confidence * 0.6) +
                                  (temporal_influence * 0.2) +
                                  (user_state_influence * 0.2) / 100.0;
    
    if (active_prediction.confidence > 0.95) active_prediction.confidence = 0.95;
    if (active_prediction.confidence < 0.1) active_prediction.confidence = 0.1;
    
    // Generate prediction message
    sprintf(active_prediction.predicted_request, 
            "I predict you'll want: %s related to %s", 
            request_emojis[predicted_type],
            request_types[predicted_type]);
    
    // Generate reasoning
    sprintf(active_prediction.reasoning,
            "Based on your recent pattern (confidence: %.0f%%, temporal factor: %d%%, attention: %d%%)",
            active_prediction.confidence * 100,
            temporal_influence,
            current_user.attention_level);
    
    active_prediction.prediction_time = time(NULL);
}

/**
 * Update user state based on interaction
 */
void update_user_state(int request_type, int complexity, int emotional_valence) {
    // Update attention level based on request complexity
    current_user.attention_level = (current_user.attention_level * 0.7) + (complexity * 3);
    if (current_user.attention_level > 100) current_user.attention_level = 100;
    
    // Update curiosity index
    if (request_type == 8) { // NOVELTY
        current_user.curiosity_index += 15;
    } else {
        current_user.curiosity_index -= 5;
    }
    if (current_user.curiosity_index > 100) current_user.curiosity_index = 100;
    if (current_user.curiosity_index < 0) current_user.curiosity_index = 0;
    
    // Update satisfaction level
    current_user.satisfaction_level += emotional_valence * 2;
    if (current_user.satisfaction_level > 100) current_user.satisfaction_level = 100;
    if (current_user.satisfaction_level < 0) current_user.satisfaction_level = 0;
    
    // Update mood pattern for current hour
    long current_time = time(NULL);
    int hour = (current_time / 3600) % 24;
    current_user.mood_pattern[hour] = (current_user.mood_pattern[hour] * 0.8) + 
                                     (emotional_valence * 10 + 50) * 0.2;
    
    // Update cognitive load
    current_user.cognitive_load = (current_user.cognitive_load * 0.6) + (complexity * 8);
    if (current_user.cognitive_load > 100) current_user.cognitive_load = 100;
    
    // Update request frequency
    current_user.request_frequency++;
    current_user.last_interaction_time = current_time;
    
    // Update predictability
    calculate_predictability();
}

/**
 * Perform temporal analysis of user patterns
 */
void temporal_analysis() {
    long current_time = time(NULL);
    int hour = (current_time / 3600) % 24;
    int day_of_week = (current_time / 86400) % 7;
    
    // Analyze temporal patterns
    int time_based_requests = 0;
    for (int i = 0; i < PREDICTION_HISTORY; i++) {
        if (request_history[i].timestamp != 0) {
            int request_hour = (request_history[i].timestamp / 3600) % 24;
            if (abs(request_hour - hour) < 2) {
                time_based_requests++;
            }
        }
    }
    
    temporal_awareness = (time_based_requests * 100) / PREDICTION_HISTORY;
}

/**
 * Perform contextual analysis
 */
void contextual_analysis() {
    // Analyze emotional context
    int emotional_consistency = 0;
    for (int i = 1; i < PREDICTION_HISTORY; i++) {
        if (request_history[i].emotional_valence != -100 &&
            abs(request_history[i].emotional_valence - 
                request_history[i-1].emotional_valence) < 2) {
            emotional_consistency++;
        }
    }
    
    // Analyze complexity trends
    int complexity_trend = 0;
    for (int i = 1; i < PREDICTION_HISTORY; i++) {
        if (request_history[i].complexity != -1) {
            complexity_trend += request_history[i].complexity - 
                               request_history[i-1].complexity;
        }
    }
    
    contextual_understanding = (emotional_consistency * 50 / PREDICTION_HISTORY) +
                              (abs(complexity_trend) * 50 / PREDICTION_HISTORY);
    if (contextual_understanding > 100) contextual_understanding = 100;
}

/**
 * Display the current prediction
 */
void display_prediction() {
    if (!active_prediction.active) return;
    
    printf("\n🔮 ORACLE NET PREDICTION:\n");
    printf("   %s\n", active_prediction.predicted_request);
    printf("   Confidence: %.0f%%\n", active_prediction.confidence * 100);
    printf("   Reasoning: %s\n", active_prediction.reasoning);
    printf("   Model: %d | Temporal Awareness: %d | Context: %d\n",
           active_prediction.prediction_model_used,
           temporal_awareness,
           contextual_understanding);
    
    // Show system intelligence level
    printf("   System Intelligence: %d/100\n", system_intelligence);
}

/**
 * Execute the predicted request
 */
void execute_predicted_request() {
    if (!active_prediction.active || active_prediction.confidence < 0.6) return;
    
    printf("\n✨ EXECUTING PREDICTED REQUEST...\n");
    
    // Based on prediction type, execute appropriate action
    if (strstr(active_prediction.predicted_request, "LEARNING")) {
        printf("   Preparing advanced learning materials...\n");
        printf("   Curating personalized educational content...\n");
    } 
    else if (strstr(active_prediction.predicted_request, "CREATIVE")) {
        printf("   Generating creative inspiration...\n");
        printf("   Preparing innovation tools...\n");
    }
    else if (strstr(active_prediction.predicted_request, "ANALYTICAL")) {
        printf("   Compiling data analysis...\n");
        printf("   Preparing insights and visualizations...\n");
    }
    else if (strstr(active_prediction.predicted_request, "PREDICTION")) {
        printf("   Running predictive algorithms...\n");
        printf("   Preparing future insights...\n");
    }
    else {
        printf("   Preparing resources for your predicted need...\n");
    }
    
    printf("   ✓ Prediction executed successfully!\n");
    
    // Update system intelligence based on successful prediction
    system_intelligence += 5;
    if (system_intelligence > 100) system_intelligence = 100;
    
    active_prediction.active = 0;
}

/**
 * Update prediction models based on accuracy
 */
void update_prediction_models(int accuracy) {
    if (active_prediction.prediction_model_used >= 0) {
        PredictionModel *model = &prediction_models[active_prediction.prediction_model_used];
        
        if (accuracy) {
            // Successful prediction
            model->confidence += 10;
            if (model->confidence > 100) model->confidence = 100;
            
            printf("   🎯 Prediction model improved! (+10 confidence)\n");
        } else {
            // Failed prediction
            model->confidence -= 15;
            if (model->confidence < 0) model->confidence = 0;
            
            printf("   🔄 Prediction model adjusting... (-15 confidence)\n");
        }
    }
    
    // Update overall system intelligence
    system_intelligence = (system_intelligence * 0.9) + (accuracy ? 5 : -3);
    if (system_intelligence > 100) system_intelligence = 100;
    if (system_intelligence < 0) system_intelligence = 0;
}

/**
 * Calculate user predictability score
 */
void calculate_predictability() {
    int pattern_consistency = 0;
    int temporal_consistency = 0;
    
    for (int i = 0; i < MAX_PATTERNS; i++) {
        if (prediction_models[i].frequency > 2) {
            pattern_consistency += prediction_models[i].confidence;
        }
    }
    
    long current_time = time(NULL);
    for (int i = 0; i < PREDICTION_HISTORY; i++) {
        if (request_history[i].timestamp != 0) {
            long time_diff = current_time - request_history[i].timestamp;
            if (time_diff < 3600) { // Within last hour
                temporal_consistency += 10;
            }
        }
    }
    
    current_user.predictability_score = (pattern_consistency / (MAX_PATTERNS / 10)) +
                                       (temporal_consistency / PREDICTION_HISTORY);
    if (current_user.predictability_score > 100) current_user.predictability_score = 100;
}

/**
 * Show system insights
 */
void show_system_insights() {
    if (prediction_cycle % 5 == 0) {
        printf("\n📊 SYSTEM INSIGHTS:\n");
        printf("   User Predictability: %d%%\n", current_user.predictability_score);
        printf("   Request Frequency: %d requests tracked\n", current_user.request_frequency);
        printf("   Attention Level: %d%%\n", current_user.attention_level);
        printf("   Curiosity Index: %d%%\n", current_user.curiosity_index);
        
        // Show most common request types
        int type_count[REQUEST_TYPES] = {0};
        for (int i = 0; i < PREDICTION_HISTORY; i++) {
            if (request_history[i].request_type != -1) {
                type_count[request_history[i].request_type]++;
            }
        }
        
        int max_count = 0;
        int most_common = -1;
        for (int i = 0; i < REQUEST_TYPES; i++) {
            if (type_count[i] > max_count) {
                max_count = type_count[i];
                most_common = i;
            }
        }
        
        if (most_common != -1) {
            printf("   Most Common Request: %s %s\n", 
                   request_emojis[most_common], request_types[most_common]);
        }
    }
}

/**
 * Handle actual user request
 */
void handle_actual_request(char *request) {
    printf("\n👤 USER REQUEST: %s\n", request);
    
    // Analyze the request
    int request_type = -1;
    int complexity = 3; // Default medium complexity
    int emotional_valence = 0; // Neutral
    
    // Simple request analysis (in real system, this would use NLP)
    for (int i = 0; i < REQUEST_TYPES; i++) {
        if (strstr(request, request_types[i]) || 
            strstr(request, request_types[i])) {
            request_type = i;
            break;
        }
    }
    
    if (request_type == -1) {
        // Default to NOVELTY for unknown requests
        request_type = 8; // NOVELTY
    }
    
    // Update request history
    for (int i = PREDICTION_HISTORY - 1; i > 0; i--) {
        request_history[i] = request_history[i-1];
    }
    
    request_history[0].request_type = request_type;
    request_history[0].timestamp = time(NULL);
    request_history[0].complexity = complexity;
    request_history[0].emotional_valence = emotional_valence;
    strncpy(request_history[0].content, request, sizeof(request_history[0].content) - 1);
    request_history[0].fulfilled = 1;
    
    // Update user state
    update_user_state(request_type, complexity, emotional_valence);
    
    // Check if prediction was accurate
    int prediction_accurate = 0;
    if (active_prediction.active) {
        if (strstr(active_prediction.predicted_request, request_types[request_type])) {
            prediction_accurate = 1;
            printf("   🎯 PREDICTION ACCURATE! System correctly anticipated your request.\n");
        } else {
            printf("   🔄 Prediction was off target. Learning from this...\n");
        }
        
        update_prediction_models(prediction_accurate);
        active_prediction.active = 0;
    }
    
    // Process the actual request
    printf("   Processing your request...\n");
    printf("   ✓ Request completed successfully!\n");
    
    // Analyze patterns for next prediction
    analyze_user_patterns();
}

/**
 * Main interactive loop
 */
int main() {
    init_system();
    
    printf("🔮 Welcome to OracleNet: The Predictive Request System\n\n");
    printf("This system learns your patterns and predicts your requests before you make them.\n");
    printf("It uses temporal analysis, contextual understanding, and pattern recognition.\n\n");
    
    char input[256];
    int interaction_count = 0;
    
    while (1) {
        printf("\n---\n");
        printf("Cycle: %d | Intelligence: %d | Predictability: %d%%\n", 
               prediction_cycle, system_intelligence, current_user.predictability_score);
        
        // Make predictions periodically
        if (interaction_count > 2) { // Wait for some initial data
            analyze_user_patterns();
            make_prediction();
            display_prediction();
            
            if (active_prediction.confidence > 0.7) {
                execute_predicted_request();
            }
        }
        
        printf("\nEnter your request (or 'quit' to exit): ");
        
        if (fgets(input, sizeof(input), stdin) == NULL) {
            break;
        }
        
        // Remove newline
        input[strcspn(input, "\n")] = 0;
        
        if (strcmp(input, "quit") == 0) {
            break;
        }
        
        if (strlen(input) > 0) {
            handle_actual_request(input);
            interaction_count++;
        }
        
        // Show insights periodically
        show_system_insights();
        
        // Add some delay for readability
        sleep(1);
    }
    
    printf("\n📊 Final System Report:\n");
    printf("   Total Interactions: %d\n", interaction_count);
    printf("   Final Intelligence: %d/100\n", system_intelligence);
    printf("   User Predictability: %d%%\n", current_user.predictability_score);
    printf("   Thanks for using OracleNet!\n");
    
    return 0;
}