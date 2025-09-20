#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <fcntl.h>
#include <math.h>

#define MAP_W 80
#define MAP_H 40
#define VIEW_W 50
#define VIEW_H 20

#define NUM_FAIRIES 8
#define NUM_GENIES 3
#define NUM_TREATS 15
#define NUM_PLANTS 20
#define NUM_PORTALS 5

typedef struct {
    int x, y;
    int type;
    int state; // 0=hidden, 1=visible, 2=activated
    int timer;
} Entity;

typedef struct {
    int x, y;
    int health;
    int magic;
    int treats;
    int score;
    int has_wand;
    int has_genie_lamp;
} Player;

Entity fairies[NUM_FAIRIES], genies[NUM_GENIES], treats[NUM_TREATS];
Entity plants[NUM_PLANTS], portals[NUM_PORTALS];
Player player;

int game_time = 0;
int weather = 0; // 0=sunny, 1=rainy, 2=magic showers
int season = 0;  // 0=spring, 1=summer, 2=autumn, 3=winter

// Emoji sets
const char *fairy_emoji[] = {"🧚", "🧚‍♀️", "🧚‍♂️", "✨"};
const char *genie_emoji[] = {"🧞", "🧞‍♀️", "🧞‍♂️"};
const char *treat_emoji[] = {"🍰", "🍬", "🍪", "🍩", "🧁", "🍫", "🍭"};
const char *plant_emoji[] = {"🌷", "🌹", "🌺", "🌸", "🌻", "🍄", "🌲"};
const char *portal_emoji[] = {"🌀", "🌌", "🌈", "🌠", "🔮"};
const char *weather_emoji[] = {"☀️", "🌧️", "🔮"};
const char *season_emoji[] = {"🌱", "🌞", "🍂", "❄️"};

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

// Initialize game world
void init_world() {
    player.x = MAP_W / 2;
    player.y = MAP_H / 2;
    player.health = 100;
    player.magic = 50;
    player.treats = 0;
    player.score = 0;
    player.has_wand = 0;
    player.has_genie_lamp = 0;

    // Initialize fairies
    for (int i = 0; i < NUM_FAIRIES; i++) {
        fairies[i].x = 10 + rand() % (MAP_W - 20);
        fairies[i].y = 10 + rand() % (MAP_H - 20);
        fairies[i].type = rand() % 4;
        fairies[i].state = 1;
        fairies[i].timer = 30 + rand() % 50;
    }

    // Initialize genies
    for (int i = 0; i < NUM_GENIES; i++) {
        genies[i].x = 5 + rand() % (MAP_W - 10);
        genies[i].y = 5 + rand() % (MAP_H - 10);
        genies[i].type = rand() % 3;
        genies[i].state = 0; // Start hidden
        genies[i].timer = 100 + rand() % 100;
    }

    // Initialize treats
    for (int i = 0; i < NUM_TREATS; i++) {
        treats[i].x = 5 + rand() % (MAP_W - 10);
        treats[i].y = 5 + rand() % (MAP_H - 10);
        treats[i].type = rand() % 7;
        treats[i].state = 1;
        treats[i].timer = 0;
    }

    // Initialize magical plants
    for (int i = 0; i < NUM_PLANTS; i++) {
        plants[i].x = 3 + rand() % (MAP_W - 6);
        plants[i].y = 3 + rand() % (MAP_H - 6);
        plants[i].type = rand() % 7;
        plants[i].state = 1;
        plants[i].timer = 0;
    }

    // Initialize portals
    for (int i = 0; i < NUM_PORTALS; i++) {
        portals[i].x = 10 + rand() % (MAP_W - 20);
        portals[i].y = 10 + rand() % (MAP_H - 20);
        portals[i].type = rand() % 5;
        portals[i].state = 0; // Start inactive
        portals[i].timer = 200 + rand() % 100;
    }
}

// Draw the viewport
void draw_view() {
    cls();
    printf("🧁 Enchanted Sweet Treat Garden - %s Season - Weather: %s\n\n",
           season_emoji[season],
           weather_emoji[weather]);
    printf("Health: %d%% Magic: %d%% Treats: %d Score: %d\n\n", 
           player.health, player.magic, player.treats, player.score);

    for (int y = 0; y < VIEW_H; y++) {
        for (int x = 0; x < VIEW_W; x++) {
            int wx = player.x - VIEW_W / 2 + x;
            int wy = player.y - VIEW_H / 2 + y;
            const char *c = "  ";  // Default empty space

            // Check boundaries
            if (wx < 0 || wx >= MAP_W || wy < 0 || wy >= MAP_H) {
                // Create a decorative border
                if (wx == -1 || wx == MAP_W || wy == -1 || wy == MAP_H) c = "🌳";
                else printf("  ");
                continue;
            }

            // Draw garden floor - changes with seasons
            if ((wx + wy) % 4 == 0) {
                if (season == 0) c = "🌱"; // Spring
                else if (season == 1) c = "🌞"; // Summer
                else if (season == 2) c = "🍂"; // Autumn
                else c = "❄️"; // Winter
            } else {
                c = "  ";
            }

            // Check entities in order of priority
            for (int i = 0; i < NUM_PLANTS; i++)
                if (plants[i].x == wx && plants[i].y == wy && plants[i].state) {
                    c = plant_emoji[plants[i].type];
                    break;
                }
            
            for (int i = 0; i < NUM_TREATS; i++)
                if (treats[i].x == wx && treats[i].y == wy && treats[i].state) {
                    c = treat_emoji[treats[i].type];
                    break;
                }
            
            for (int i = 0; i < NUM_PORTALS; i++)
                if (portals[i].x == wx && portals[i].y == wy && portals[i].state) {
                    c = portal_emoji[portals[i].type];
                    break;
                }
            
            for (int i = 0; i < NUM_FAIRIES; i++)
                if (fairies[i].x == wx && fairies[i].y == wy && fairies[i].state) {
                    c = fairy_emoji[fairies[i].type];
                    break;
                }
            
            for (int i = 0; i < NUM_GENIES; i++)
                if (genies[i].x == wx && genies[i].y == wy && genies[i].state) {
                    c = genie_emoji[genies[i].type];
                    break;
                }

            if (wx == player.x && wy == player.y) {
                if (player.has_wand) c = "🧙‍♀️";
                else if (player.has_genie_lamp) c = "🧞‍♂️";
                else c = "👸";
            }

            printf("%s", c);
        }
        printf("\n");
    }
    printf("\nUse WASD to move, E to interact, Q to quit\n");
    printf("Find treats, help fairies, and discover genies!\n");
}

// Handle interactions
void interact() {
    // Check for treat collection
    for (int i = 0; i < NUM_TREATS; i++) {
        if (treats[i].x == player.x && treats[i].y == player.y && treats[i].state) {
            printf("🧁 You found a sweet treat! +10 magic\n");
            treats[i].state = 0;
            player.treats++;
            player.magic += 10;
            if (player.magic > 100) player.magic = 100;
            player.score += 5;
        }
    }

    // Check for fairy interactions
    for (int i = 0; i < NUM_FAIRIES; i++) {
        int dx = abs(fairies[i].x - player.x);
        int dy = abs(fairies[i].y - player.y);
        if (dx <= 1 && dy <= 1 && fairies[i].state) {
            if (player.treats > 0) {
                printf("🧚 A fairy is happy with your treat! +20 magic\n");
                player.treats--;
                player.magic += 20;
                if (player.magic > 100) player.magic = 100;
                player.score += 10;
                fairies[i].timer += 50; // Fairy stays longer
            } else {
                printf("🧚 A fairy needs a treat to help you!\n");
            }
        }
    }

    // Check for genie interactions
    for (int i = 0; i < NUM_GENIES; i++) {
        int dx = abs(genies[i].x - player.x);
        int dy = abs(genies[i].y - player.y);
        if (dx <= 1 && dy <= 1 && genies[i].state) {
            if (!player.has_genie_lamp) {
                printf("🧞 A genie grants you a magic lamp! Special powers unlocked!\n");
                player.has_genie_lamp = 1;
                player.score += 50;
                genies[i].state = 0; // Genie disappears after granting wish
            } else {
                printf("🧞 The genie is impressed with your lamp! +30 magic\n");
                player.magic += 30;
                if (player.magic > 100) player.magic = 100;
            }
        }
    }

    // Check for plant interactions
    for (int i = 0; i < NUM_PLANTS; i++) {
        if (plants[i].x == player.x && plants[i].y == player.y && plants[i].state) {
            if (player.magic >= 10) {
                printf("🌺 You used magic to make the plant grow! +5 score\n");
                player.magic -= 10;
                player.score += 5;
                plants[i].type = (plants[i].type + 1) % 7; // Change plant type
            } else {
                printf("🌺 This plant needs magic to grow!\n");
            }
        }
    }

    // Check for portal interactions
    for (int i = 0; i < NUM_PORTALS; i++) {
        if (portals[i].x == player.x && portals[i].y == player.y && portals[i].state) {
            if (player.magic >= 30) {
                printf("🌀 You activated a magic portal! Teleporting...\n");
                player.magic -= 30;
                player.x = 10 + rand() % (MAP_W - 20);
                player.y = 10 + rand() % (MAP_H - 20);
                player.score += 20;
            } else {
                printf("🌀 This portal needs more magic to activate!\n");
            }
        }
    }
}

// Update game world
void update_world() {
    game_time++;
    
    // Change weather and seasons periodically
    if (game_time % 100 == 0) {
        weather = (weather + 1) % 3;
    }
    if (game_time % 500 == 0) {
        season = (season + 1) % 4;
    }
    
    // Gradually decrease magic
    if (game_time % 50 == 0) {
        player.magic--;
        if (player.magic < 0) player.magic = 0;
    }
    
    // Update fairies
    for (int i = 0; i < NUM_FAIRIES; i++) {
        if (fairies[i].state) {
            fairies[i].timer--;
            if (fairies[i].timer <= 0) {
                fairies[i].x = 10 + rand() % (MAP_W - 20);
                fairies[i].y = 10 + rand() % (MAP_H - 20);
                fairies[i].timer = 30 + rand() % 50;
            }
            
            // Fairies move randomly
            if (rand() % 5 == 0) {
                fairies[i].x += rand() % 3 - 1;
                fairies[i].y += rand() % 3 - 1;
                
                // Keep fairies in bounds
                if (fairies[i].x < 0) fairies[i].x = 0;
                if (fairies[i].x >= MAP_W) fairies[i].x = MAP_W - 1;
                if (fairies[i].y < 0) fairies[i].y = 0;
                if (fairies[i].y >= MAP_H) fairies[i].y = MAP_H - 1;
            }
        }
    }
    
    // Update genies
    for (int i = 0; i < NUM_GENIES; i++) {
        genies[i].timer--;
        if (genies[i].timer <= 0) {
            genies[i].state = !genies[i].state; // Toggle visibility
            genies[i].timer = 100 + rand() % 100;
            
            if (genies[i].state) {
                genies[i].x = 5 + rand() % (MAP_W - 10);
                genies[i].y = 5 + rand() % (MAP_H - 10);
            }
        }
    }
    
    // Regenerate treats occasionally
    if (game_time % 200 == 0) {
        for (int i = 0; i < NUM_TREATS; i++) {
            if (!treats[i].state && rand() % 3 == 0) {
                treats[i].state = 1;
                treats[i].x = 5 + rand() % (MAP_W - 10);
                treats[i].y = 5 + rand() % (MAP_H - 10);
            }
        }
    }
    
    // Update portals
    for (int i = 0; i < NUM_PORTALS; i++) {
        portals[i].timer--;
        if (portals[i].timer <= 0) {
            portals[i].state = !portals[i].state; // Toggle activity
            portals[i].timer = 200 + rand() % 100;
            
            if (portals[i].state) {
                portals[i].x = 10 + rand() % (MAP_W - 20);
                portals[i].y = 10 + rand() % (MAP_H - 20);
            }
        }
    }
    
    // Random events based on weather
    if (weather == 1 && game_time % 30 == 0) { // Rainy weather
        player.health++; // Rain refreshes health
        if (player.health > 100) player.health = 100;
    }
    else if (weather == 2 && game_time % 20 == 0) { // Magic showers
        player.magic += 5;
        if (player.magic > 100) player.magic = 100;
    }
}

int main() {
    srand(time(NULL));
    set_nonblocking_mode();
    init_world();

    char input;
    while (1) {
        draw_view();
        
        // Handle input
        if (read(STDIN_FILENO, &input, 1) > 0) {
            if (input == 'q' || input == 'Q') break;
            if (input == 'w' && player.y > 0) player.y--;
            if (input == 's' && player.y < MAP_H - 1) player.y++;
            if (input == 'a' && player.x > 0) player.x--;
            if (input == 'd' && player.x < MAP_W - 1) player.x++;
            if (input == 'e' || input == 'E') interact();
        }

        update_world();
        usleep(100000);  // 100ms delay
        
        // Check win condition
        if (player.score >= 200) {
            printf("\n🎉 You've mastered the Enchanted Sweet Treat Garden! 🎉\n");
            printf("Final Score: %d\n", player.score);
            break;
        }
    }

    // Restore terminal settings
    struct termios ttystate;
    tcgetattr(STDIN_FILENO, &ttystate);
    ttystate.c_lflag |= (ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &ttystate);

    return 0;
}