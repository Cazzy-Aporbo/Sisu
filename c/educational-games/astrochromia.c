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
#define NUM_CONSTELLATIONS 12
#define NUM_COLOR_SPHERES 7
#define NUM_WIZARD_TOWERS 5
#define MAX_STARDUST 1000

// Color theory concepts
#define COLOR_WHEEL 0
#define PRIMARY_COLORS 1
#define SECONDARY_COLORS 2
#define COMPLEMENTARY 3
#define ANALOGOUS 4
#define TRIADIC 5
#define WARM_COOL 6

// Astrology elements
#define FIRE 0
#define EARTH 1
#define AIR 2
#define WATER 3

// Wizard specializations
#define COLOR_MAGIC 0
#define LIGHT_WIZARDRY 1
#define SPECTRUM_MASTERY 2
#define PRISM_ARTISTRY 3
#define RAINBOW_SORCERY 4

typedef struct {
    int x, y;
    int radius;
    int color_type;
    char name[20];
    char color_principle[50];
    int intensity;
    int active;
} ColorSphere;

typedef struct {
    int x, y;
    int stars;
    char name[20];
    char element[10];
    char emoji[5];
    int discovered;
    int color_relationship;
} Constellation;

typedef struct {
    int x, y;
    int specialization;
    char name[30];
    char lesson[100];
    int knowledge_level;
    int active;
} WizardTower;

typedef struct {
    int x, y;
    int color_knowledge;
    int light_understanding;
    int spectral_power;
    int stardust;
    int constellations_mapped;
    int color_spheres_activated;
    int current_element;
    int wizard_level;
    int rainbow_energy;
} PlayerWizard;

// Game state
ColorSphere color_spheres[NUM_COLOR_SPHERES];
Constellation constellations[NUM_CONSTELLATIONS];
WizardTower towers[NUM_WIZARD_TOWERS];
PlayerWizard player;

int game_time = 0;
int cosmic_alignment = 50;
int color_harmony = 60;
int light_spectrum = 40;
int magic_energy = 75;

// Visual elements
const char *color_emojis[] = {"🔴", "🟠", "🟡", "🟢", "🔵", "🟣", "⚪"};
const char *element_emojis[] = {"🔥", "🌍", "💨", "💧"};
const char *wizard_emojis[] = {"🎨", "💡", "🌈", "🔮", "✨"};
const char *theory_emojis[] = {"🎡", "🔴🟡🔵", "🟠🟢🟣", "⚫⚪", "🟠🟡🟢", "🔴🟢🔵", "🔥❄️"};

// Function prototypes
void set_nonblocking_mode();
void restore_terminal();
void cls();
void init_game();
void draw_magical_world();
void handle_input(char input);
void update_game();
void discover_constellation(int index);
void activate_color_sphere(int index);
void visit_wizard_tower(int index);
void update_wizard_abilities();
void show_color_theory_lesson(int concept);
void cast_color_magic(int spell_type);
void create_rainbow_effect();
void update_cosmic_alignment();
void adjust_color_harmony();
void show_magical_insight();
void unlock_wizard_ability(const char *ability);

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
 * Initialize the magical world
 */
void init_game() {
    srand(time(NULL));
    
    // Initialize player wizard
    player.x = WIDTH / 2;
    player.y = HEIGHT / 2;
    player.color_knowledge = 50;
    player.light_understanding = 40;
    player.spectral_power = 30;
    player.stardust = 100;
    player.constellations_mapped = 0;
    player.color_spheres_activated = 0;
    player.current_element = FIRE;
    player.wizard_level = 1;
    player.rainbow_energy = 25;
    
    // Initialize color spheres (primary and secondary colors)
    ColorSphere spheres[] = {
        {20, 10, 3, 0, "Red Sphere", "Primary Color - Cannot be created by mixing", 80, 1},
        {40, 8, 3, 1, "Yellow Sphere", "Primary Color - Cannot be created by mixing", 80, 1},
        {60, 10, 3, 2, "Blue Sphere", "Primary Color - Cannot be created by mixing", 80, 1},
        {30, 20, 3, 3, "Orange Sphere", "Secondary Color - Mix of Red and Yellow", 70, 0},
        {50, 20, 3, 4, "Green Sphere", "Secondary Color - Mix of Yellow and Blue", 70, 0},
        {40, 30, 3, 5, "Violet Sphere", "Secondary Color - Mix of Red and Blue", 70, 0},
        {40, 15, 4, 6, "White Sphere", "All colors combined - Contains full spectrum", 90, 0}
    };
    
    for (int i = 0; i < NUM_COLOR_SPHERES; i++) {
        color_spheres[i] = spheres[i];
    }
    
    // Initialize constellations (zodiac with color relationships)
    Constellation zodiac[] = {
        {10, 5, 5, "Aries", "Fire", "♈", 0, 0},       // Red
        {25, 8, 5, "Taurus", "Earth", "♉", 0, 1},     // Orange
        {15, 20, 5, "Gemini", "Air", "♊", 0, 2},      // Yellow
        {30, 25, 5, "Cancer", "Water", "♋", 0, 3},    // Green
        {45, 20, 5, "Leo", "Fire", "♌", 0, 0},        // Red
        {55, 25, 5, "Virgo", "Earth", "♍", 0, 4},     // Blue
        {65, 20, 5, "Libra", "Air", "♎", 0, 5},       // Indigo
        {70, 10, 5, "Scorpio", "Water", "♏", 0, 5},   // Violet
        {55, 5, 5, "Sagittarius", "Fire", "♐", 0, 0}, // Red
        {35, 5, 5, "Capricorn", "Earth", "♑", 0, 1},  // Orange
        {20, 30, 5, "Aquarius", "Air", "♒", 0, 2},    // Yellow
        {40, 35, 5, "Pisces", "Water", "♓", 0, 3}     // Green
    };
    
    for (int i = 0; i < NUM_CONSTELLATIONS; i++) {
        constellations[i] = zodiac[i];
    }
    
    // Initialize wizard towers
    WizardTower wizard_towers[] = {
        {15, 15, COLOR_MAGIC, "Tower of Hue", "Learn about primary and secondary colors", 1, 1},
        {35, 25, LIGHT_WIZARDRY, "Tower of Light", "Discover how light creates color", 1, 1},
        {55, 15, SPECTRUM_MASTERY, "Tower of Spectrum", "Understand the visible light spectrum", 1, 1},
        {25, 35, PRISM_ARTISTRY, "Tower of Prisms", "Learn how prisms separate white light", 1, 1},
        {45, 35, RAINBOW_SORCERY, "Tower of Rainbows", "Master rainbow creation and color harmony", 1, 1}
    };
    
    for (int i = 0; i < NUM_WIZARD_TOWERS; i++) {
        towers[i] = wizard_towers[i];
    }
}

/**
 * Draw the magical world
 */
void draw_magical_world() {
    cls();
    
    // Draw header with wizard stats
    printf("✨ AstroChromia: The Wizard's Color Universe | Wizard Level: %d | Stardust: %d\n\n", 
           player.wizard_level, player.stardust);
    
    printf("Color Knowledge: %d | Light Understanding: %d | Spectral Power: %d | Rainbow Energy: %d\n\n", 
           player.color_knowledge, player.light_understanding, 
           player.spectral_power, player.rainbow_energy);
    
    // Draw the magical realm
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            const char *c = "  "; // Default space (night sky)
            
            // Create starry background
            if ((x + y + game_time) % 10 == 0 && rand() % 100 < 5) {
                c = "✨";
            }
            
            // Draw color spheres
            for (int i = 0; i < NUM_COLOR_SPHERES; i++) {
                int dx = x - color_spheres[i].x;
                int dy = y - color_spheres[i].y;
                int distance = sqrt(dx*dx + dy*dy);
                
                if (distance < color_spheres[i].radius) {
                    if (color_spheres[i].active) {
                        c = color_emojis[color_spheres[i].color_type];
                    } else {
                        c = "⚫";
                    }
                    break;
                }
            }
            
            // Draw constellations
            for (int i = 0; i < NUM_CONSTELLATIONS; i++) {
                if (x == constellations[i].x && y == constellations[i].y) {
                    if (constellations[i].discovered) {
                        c = constellations[i].emoji;
                    } else {
                        c = "⭐";
                    }
                    break;
                }
            }
            
            // Draw wizard towers
            for (int i = 0; i < NUM_WIZARD_TOWERS; i++) {
                if (x == towers[i].x && y == towers[i].y) {
                    c = wizard_emojis[towers[i].specialization];
                    break;
                }
            }
            
            // Draw player wizard
            if (x == player.x && y == player.y) {
                c = "🧙";
            }
            
            printf("%s", c);
        }
        printf("\n");
    }
    
    // Draw footer with controls
    printf("\nControls: WASD to move | SPACE to interact | C to cast color magic | R to create rainbow\n");
    printf("Cosmic Alignment: %d%% | Color Harmony: %d%% | Light Spectrum: %d%% | Magic Energy: %d%%\n", 
           cosmic_alignment, color_harmony, light_spectrum, magic_energy);
    
    // Show magical insights periodically
    if (game_time % 120 == 0) {
        show_magical_insight();
    }
}

/**
 * Handle user input
 */
void handle_input(char input) {
    switch (input) {
        case 'w': if (player.y > 0) player.y--; break;
        case 's': if (player.y < HEIGHT - 1) player.y++; break;
        case 'a': if (player.x > 0) player.x--; break;
        case 'd': if (player.x < WIDTH - 1) player.x++; break;
        case ' ': 
            // Check for constellation discovery
            for (int i = 0; i < NUM_CONSTELLATIONS; i++) {
                if (player.x == constellations[i].x && player.y == constellations[i].y) {
                    discover_constellation(i);
                    break;
                }
            }
            
            // Check for color sphere activation
            for (int i = 0; i < NUM_COLOR_SPHERES; i++) {
                int dx = player.x - color_spheres[i].x;
                int dy = player.y - color_spheres[i].y;
                int distance = sqrt(dx*dx + dy*dy);
                
                if (distance <= color_spheres[i].radius + 1) {
                    activate_color_sphere(i);
                    break;
                }
            }
            
            // Check for wizard tower visits
            for (int i = 0; i < NUM_WIZARD_TOWERS; i++) {
                if (player.x == towers[i].x && player.y == towers[i].y) {
                    visit_wizard_tower(i);
                    break;
                }
            }
            break;
        case 'c':
            cast_color_magic(rand() % 7);
            break;
        case 'r':
            create_rainbow_effect();
            break;
        case '1': case '2': case '3': case '4':
            player.current_element = input - '1';
            printf("\n%s Element changed to: %s\n", 
                   element_emojis[player.current_element],
                   player.current_element == FIRE ? "Fire" :
                   player.current_element == EARTH ? "Earth" :
                   player.current_element == AIR ? "Air" : "Water");
            usleep(1000000);
            break;
        case 'q':
            printf("Exiting AstroChromia. Final Wizard Level: %d\n", player.wizard_level);
            restore_terminal();
            exit(0);
    }
}

/**
 * Discover a constellation and learn its color relationship
 */
void discover_constellation(int index) {
    Constellation *c = &constellations[index];
    
    if (!c->discovered) {
        printf("\n🌌 You discovered the %s constellation! (%s %s)\n", 
               c->name, element_emojis[player.current_element], c->emoji);
        printf("Element: %s\n", c->element);
        
        // Teach color relationship based on constellation
        switch (c->color_relationship) {
            case 0: 
                printf("Color Association: Red - Energy, passion, and action\n");
                show_color_theory_lesson(PRIMARY_COLORS);
                break;
            case 1:
                printf("Color Association: Orange - Creativity, warmth, and enthusiasm\n");
                show_color_theory_lesson(SECONDARY_COLORS);
                break;
            case 2:
                printf("Color Association: Yellow - Intellect, happiness, and energy\n");
                show_color_theory_lesson(PRIMARY_COLORS);
                break;
            case 3:
                printf("Color Association: Green - Growth, harmony, and nature\n");
                show_color_theory_lesson(SECONDARY_COLORS);
                break;
            case 4:
                printf("Color Association: Blue - Calm, trust, and stability\n");
                show_color_theory_lesson(PRIMARY_COLORS);
                break;
            case 5:
                printf("Color Association: Violet - Spirituality, luxury, and mystery\n");
                show_color_theory_lesson(SECONDARY_COLORS);
                break;
        }
        
        c->discovered = 1;
        player.constellations_mapped++;
        player.stardust += 50;
        player.spectral_power += 5;
        
        // Update cosmic alignment
        cosmic_alignment += 5;
        if (cosmic_alignment > 100) cosmic_alignment = 100;
        
        unlock_wizard_ability("Constellation Mapping");
    } else {
        printf("\n🌌 You're visiting the %s constellation again.\n", c->name);
        printf("Element: %s\n", c->element);
        
        player.stardust += 10;
        player.spectral_power += 1;
    }
    
    usleep(2500000);
}

/**
 * Activate a color sphere and learn color theory
 */
void activate_color_sphere(int index) {
    ColorSphere *s = &color_spheres[index];
    
    if (!s->active) {
        printf("\n%s Activating the %s!\n", color_emojis[s->color_type], s->name);
        printf("Color Principle: %s\n", s->color_principle);
        
        s->active = 1;
        player.color_spheres_activated++;
        player.stardust += 30;
        player.color_knowledge += 10;
        
        // Teach specific color theory based on sphere type
        switch (s->color_type) {
            case 0: case 1: case 2: // Primary colors
                show_color_theory_lesson(PRIMARY_COLORS);
                break;
            case 3: case 4: case 5: // Secondary colors
                show_color_theory_lesson(SECONDARY_COLORS);
                break;
            case 6: // White light
                show_color_theory_lesson(COLOR_WHEEL);
                player.light_understanding += 15;
                break;
        }
        
        // Update color harmony
        color_harmony += 8;
        if (color_harmony > 100) color_harmony = 100;
        
        unlock_wizard_ability("Color Sphere Activation");
    } else {
        printf("\n%s The %s is already active.\n", color_emojis[s->color_type], s->name);
        printf("Color Principle: %s\n", s->color_principle);
        
        player.stardust += 5;
        player.color_knowledge += 2;
    }
    
    usleep(2500000);
}

/**
 * Visit a wizard tower and learn advanced color magic
 */
void visit_wizard_tower(int index) {
    WizardTower *t = &towers[index];
    
    printf("\n🏰 Visiting the %s\n", t->name);
    printf("Lesson: %s\n", t->lesson);
    
    // Teach advanced color theory based on tower specialization
    switch (t->specialization) {
        case COLOR_MAGIC:
            show_color_theory_lesson(COLOR_WHEEL);
            player.color_knowledge += 15;
            break;
        case LIGHT_WIZARDRY:
            printf("💡 Light is made of different colors combined together!\n");
            printf("💡 When light hits objects, some colors are absorbed and others reflected.\n");
            player.light_understanding += 20;
            break;
        case SPECTRUM_MASTERY:
            printf("🌈 The visible spectrum: Red, Orange, Yellow, Green, Blue, Indigo, Violet\n");
            printf("🌈 Each color has a different wavelength and energy level.\n");
            player.spectral_power += 15;
            light_spectrum += 10;
            break;
        case PRISM_ARTISTRY:
            printf("🔮 Prisms separate white light into its component colors through refraction.\n");
            printf("🔮 Different colors bend at different angles when passing through a prism.\n");
            player.light_understanding += 10;
            player.spectral_power += 10;
            break;
        case RAINBOW_SORCERY:
            printf("✨ Rainbows form when sunlight is refracted through water droplets.\n");
            printf("✨ The colors always appear in the same order: ROYGBIV.\n");
            player.rainbow_energy += 25;
            color_harmony += 15;
            break;
    }
    
    t->knowledge_level++;
    player.stardust += 40;
    magic_energy += 10;
    if (magic_energy > 100) magic_energy = 100;
    
    // Check for wizard level up
    if (player.color_knowledge >= 70 && player.light_understanding >= 60 && 
        player.spectral_power >= 50 && player.rainbow_energy >= 40) {
        player.wizard_level++;
        printf("\n🎉 Wizard Level Up! You are now a Level %d Color Wizard!\n", player.wizard_level);
        unlock_wizard_ability("Advanced Color Magic");
    }
    
    usleep(3000000);
}

/**
 * Show a color theory lesson
 */
void show_color_theory_lesson(int concept) {
    printf("\n🎨 COLOR THEORY LESSON:\n");
    
    switch (concept) {
        case COLOR_WHEEL:
            printf("   The color wheel shows how colors relate to each other.\n");
            printf("   Primary colors: Red, Yellow, Blue - cannot be created by mixing\n");
            printf("   Secondary colors: Orange, Green, Violet - created by mixing primaries\n");
            break;
        case PRIMARY_COLORS:
            printf("   Primary colors are the foundation of all other colors.\n");
            printf("   Red, Yellow, and Blue cannot be created by mixing other colors.\n");
            printf("   All other colors are derived from these three primaries.\n");
            break;
        case SECONDARY_COLORS:
            printf("   Secondary colors are created by mixing two primary colors.\n");
            printf("   Red + Yellow = Orange, Yellow + Blue = Green, Blue + Red = Violet\n");
            break;
        case COMPLEMENTARY:
            printf("   Complementary colors are opposite each other on the color wheel.\n");
            printf("   Red & Green, Blue & Orange, Yellow & Violet are complements.\n");
            printf("   They create strong contrast when placed next to each other.\n");
            break;
        case ANALOGOUS:
            printf("   Analogous colors are next to each other on the color wheel.\n");
            printf("   They create harmonious and pleasing color schemes.\n");
            printf("   Examples: Red, Orange, Yellow or Blue, Green, Violet\n");
            break;
        case TRIADIC:
            printf("   Triadic colors are evenly spaced around the color wheel.\n");
            printf("   Primary triad: Red, Yellow, Blue\n");
            printf("   Secondary triad: Orange, Green, Violet\n");
            printf("   They create vibrant and balanced color schemes.\n");
            break;
        case WARM_COOL:
            printf("   Colors are divided into warm and cool temperatures.\n");
            printf("   Warm colors: Red, Orange, Yellow - evoke energy and warmth\n");
            printf("   Cool colors: Green, Blue, Violet - evoke calm and coolness\n");
            break;
    }
    
    player.color_knowledge += 8;
    if (player.color_knowledge > 100) player.color_knowledge = 100;
}

/**
 * Cast color magic
 */
void cast_color_magic(int spell_type) {
    if (magic_energy < 20) {
        printf("\n💤 Not enough magic energy! Visit a wizard tower to recharge.\n");
        return;
    }
    
    printf("\n✨ Casting %s Color Magic!\n", theory_emojis[spell_type]);
    
    switch (spell_type) {
        case 0: // Color wheel
            printf("   Revealing the relationships between all colors...\n");
            player.color_knowledge += 5;
            color_harmony += 5;
            break;
        case 1: // Primary colors
            printf("   Channeling the power of primary colors...\n");
            player.color_knowledge += 3;
            player.spectral_power += 2;
            break;
        case 2: // Secondary colors
            printf("   Mixing magical energies to create new colors...\n");
            player.color_knowledge += 4;
            player.spectral_power += 3;
            break;
        case 3: // Complementary
            printf("   Creating powerful color contrasts...\n");
            color_harmony += 8;
            break;
        case 4: // Analogous
            printf("   Harmonizing nearby colors...\n");
            color_harmony += 6;
            player.rainbow_energy += 3;
            break;
        case 5: // Triadic
            printf("   Balancing three color energies...\n");
            color_harmony += 7;
            player.spectral_power += 4;
            break;
        case 6: // Warm/cool
            printf("   Controlling color temperature...\n");
            player.color_knowledge += 2;
            player.rainbow_energy += 5;
            break;
    }
    
    magic_energy -= 20;
    player.stardust += 15;
    
    usleep(1500000);
}

/**
 * Create rainbow effect
 */
void create_rainbow_effect() {
    if (player.rainbow_energy < 30) {
        printf("\n💤 Not enough rainbow energy! Visit the Rainbow Tower to learn more.\n");
        return;
    }
    
    printf("\n🌈 Creating a magical rainbow!\n");
    printf("   Red, Orange, Yellow, Green, Blue, Indigo, Violet\n");
    printf("   Rainbows form through refraction and reflection of light in water droplets.\n");
    
    player.rainbow_energy -= 30;
    color_harmony += 12;
    player.stardust += 25;
    player.light_understanding += 5;
    
    // Visual effect would be implemented with terminal colors in a real game
    printf("   ✨ The rainbow illuminates the sky with color magic!\n");
    
    usleep(2000000);
}

/**
 * Show magical insight about color and light
 */
void show_magical_insight() {
    if (player.color_knowledge < 40) return;
    
    printf("\n🔮 MAGICAL INSIGHT:\n");
    
    // Different insights based on player knowledge
    if (player.light_understanding > 50) {
        printf("   Did you know? The human eye can see about 7 million different colors!\n");
        printf("   This is possible because of special cells called cones in our eyes.\n");
    } else if (player.spectral_power > 40) {
        printf("   Fun fact: Sir Isaac Newton discovered the color spectrum using a prism in 1666.\n");
        printf("   He originally identified 5 colors, but added 2 more to match the musical scale.\n");
    } else {
        printf("   Magical fact: In color theory, black is the absence of light and white is all colors combined.\n");
        printf("   This is different from mixing paints, where black is all colors and white is absence!\n");
    }
    
    player.color_knowledge += 2;
    player.light_understanding += 3;
    
    usleep(2500000);
}

/**
 * Unlock a wizard ability
 */
void unlock_wizard_ability(const char *ability) {
    printf("\n🔓 Wizard Ability Unlocked: %s!\n", ability);
    magic_energy += 15;
    if (magic_energy > 100) magic_energy = 100;
    
    usleep(1500000);
}

/**
 * Update game state
 */
void update_game() {
    game_time++;
    
    // Update wizard abilities
    update_wizard_abilities();
    
    // Update cosmic alignment
    update_cosmic_alignment();
    
    // Adjust color harmony
    adjust_color_harmony();
    
    // Check for mastery
    if (player.wizard_level >= 5 && player.color_spheres_activated >= NUM_COLOR_SPHERES && 
        player.constellations_mapped >= NUM_CONSTELLATIONS) {
        printf("\n🎉 MASTERY ACHIEVED! You are now a Grand Master of Color Magic!\n");
        printf("You have mastered the secrets of light, color, and the cosmos!\n");
        restore_terminal();
        exit(0);
    }
}

/**
 * Update wizard abilities based on progress
 */
void update_wizard_abilities() {
    // Gradually increase abilities through exposure
    if (color_harmony > 50) {
        player.color_knowledge += 0.1;
    }
    
    if (light_spectrum > 40) {
        player.light_understanding += 0.1;
    }
    
    if (cosmic_alignment > 60) {
        player.spectral_power += 0.1;
    }
    
    if (magic_energy > 30) {
        player.rainbow_energy += 0.05;
    }
    
    // Cap values
    if (player.color_knowledge > 100) player.color_knowledge = 100;
    if (player.light_understanding > 100) player.light_understanding = 100;
    if (player.spectral_power > 100) player.spectral_power = 100;
    if (player.rainbow_energy > 100) player.rainbow_energy = 100;
}

/**
 * Update cosmic alignment based on constellation mapping
 */
void update_cosmic_alignment() {
    // Cosmic alignment increases with constellation discovery
    int target_alignment = player.constellations_mapped * 8;
    if (target_alignment > 100) target_alignment = 100;
    
    // Smoothly adjust toward target alignment
    if (cosmic_alignment < target_alignment) {
        cosmic_alignment++;
    } else if (cosmic_alignment > target_alignment) {
        cosmic_alignment--;
    }
}

/**
 * Adjust color harmony based on activated spheres
 */
void adjust_color_harmony() {
    // Color harmony increases with sphere activation
    int target_harmony = player.color_spheres_activated * 14;
    if (target_harmony > 100) target_harmony = 100;
    
    // Smoothly adjust toward target harmony
    if (color_harmony < target_harmony) {
        color_harmony++;
    } else if (color_harmony > target_harmony) {
        color_harmony--;
    }
    
    // Light spectrum is related to color harmony
    light_spectrum = color_harmony * 0.8;
}

/**
 * Main game loop
 */
int main() {
    set_nonblocking_mode();
    init_game();
    
    printf("✨ Welcome to AstroChromia: The Wizard's Color Universe!\n\n");
    printf("Embark on a magical journey to master the secrets of color and light!\n");
    printf("Explore constellations, activate color spheres, and learn from wise wizards.\n\n");
    printf("Educational concepts you'll discover:\n");
    printf("• Color Theory & Color Wheel • Primary and Secondary Colors •\n");
    printf("• Light Spectrum & Prisms • How Rainbows Form •\n");
    printf("• Complementary & Analogous Colors • Warm and Cool Colors •\n");
    printf("• The Science of Vision and Color Perception •\n\n");
    printf("Press any key to begin your magical color adventure...");
    
    char dummy;
    read(STDIN_FILENO, &dummy, 1);
    
    char input;
    while (1) {
        draw_magical_world();
        
        if (read(STDIN_FILENO, &input, 1) > 0) {
            handle_input(input);
        }
        
        update_game();
        usleep(100000); // 100ms delay
    }
    
    restore_terminal();
    return 0;
}