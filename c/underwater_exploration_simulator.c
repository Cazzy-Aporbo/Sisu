#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>

#define MAP_W 120
#define MAP_H 40
#define VIEW_W 50
#define VIEW_H 20

#define NUM_FISH 25
#define NUM_DOLPHINS 5
#define NUM_SHARKS 3
#define NUM_WHALES 2
#define NUM_OCTOPUS 4
#define NUM_SEA_TURTLES 3
#define NUM_CORAL 20
#define NUM_SEAWEED 15
#define NUM_RUINS 8
#define NUM_TREASURE 5

typedef struct {
    int x, y;
    int type;
    int direction;
    int speed;
} Entity;

Entity fish[NUM_FISH], dolphins[NUM_DOLPHINS], sharks[NUM_SHARKS], whales[NUM_WHALES];
Entity octopus[NUM_OCTOPUS], sea_turtles[NUM_SEA_TURTLES];
Entity coral[NUM_CORAL], seaweed[NUM_SEAWEED], ruins[NUM_RUINS], treasure[NUM_TREASURE];

int playerX = MAP_W / 2, playerY = MAP_H / 2;
int depth = 0; // 0=shallow, 1=medium, 2=deep
int water_current = 0; // 0=calm, 1=medium, 2=strong
int oxygen = 100;
int score = 0;
int frameCounter = 0;

// Emoji sets for underwater theme
const char *fish_emoji[] = {"🐠", "🐟", "🐡", "🦈", "🐋"};
const char *dolphins_emoji[] = {"🐬", "🐬‍➡️", "🐬‍⬅️"};
const char *sharks_emoji[] = {"🦈", "🦈‍➡️", "🦈‍⬅️"};
const char *whales_emoji[] = {"🐋", "🐋‍➡️", "🐋‍⬅️"};
const char *octopus_emoji[] = {"🐙", "🐙‍⬇️", "🐙‍⬆️"};
const char *turtles_emoji[] = {"🐢", "🐢‍➡️", "🐢‍⬅️"};
const char *coral_emoji[] = {"🪸", "🍄", "⭐"};
const char *seaweed_emoji[] = {"🌿", "🌱", "🌾"};
const char *ruins_emoji[] = {"🏛️", "🗿", "🪦", "🧱", "🪨"};
const char *treasure_emoji[] = {"💎", "🗝️", "🔱", "🏺", "🗿"};
const char *depth_emoji[] = {"💧", "🌊", "🌀"};
const char *current_emoji[] = {"◎", "◍", "●"};

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

// Initialize underwater world
void init_world() {
    for (int i = 0; i < NUM_FISH; i++) {
        fish[i].x = rand() % MAP_W;
        fish[i].y = rand() % MAP_H;
        fish[i].type = rand() % 5;
        fish[i].direction = rand() % 4;
        fish[i].speed = 1 + rand() % 2;
    }
    for (int i = 0; i < NUM_DOLPHINS; i++) {
        dolphins[i].x = rand() % MAP_W;
        dolphins[i].y = rand() % (MAP_H / 3);
        dolphins[i].type = rand() % 3;
        dolphins[i].direction = 1;
        dolphins[i].speed = 2;
    }
    for (int i = 0; i < NUM_SHARKS; i++) {
        sharks[i].x = rand() % MAP_W;
        sharks[i].y = rand() % MAP_H;
        sharks[i].type = rand() % 3;
        sharks[i].direction = rand() % 2;
        sharks[i].speed = 1 + rand() % 2;
    }
    for (int i = 0; i < NUM_WHALES; i++) {
        whales[i].x = rand() % MAP_W;
        whales[i].y = 10 + rand() % (MAP_H - 10);
        whales[i].type = rand() % 3;
        whales[i].direction = 1;
        whales[i].speed = 1;
    }
    for (int i = 0; i < NUM_OCTOPUS; i++) {
        octopus[i].x = rand() % MAP_W;
        octopus[i].y = MAP_H - 5 + rand() % 5;
        octopus[i].type = rand() % 3;
        octopus[i].direction = rand() % 2;
        octopus[i].speed = 1;
    }
    for (int i = 0; i < NUM_SEA_TURTLES; i++) {
        sea_turtles[i].x = rand() % MAP_W;
        sea_turtles[i].y = rand() % MAP_H;
        sea_turtles[i].type = rand() % 3;
        sea_turtles[i].direction = 1;
        sea_turtles[i].speed = 1;
    }
    for (int i = 0; i < NUM_CORAL; i++) {
        coral[i].x = rand() % MAP_W;
        coral[i].y = MAP_H - 1 - rand() % 10;
        coral[i].type = rand() % 3;
    }
    for (int i = 0; i < NUM_SEAWEED; i++) {
        seaweed[i].x = rand() % MAP_W;
        seaweed[i].y = MAP_H - 1 - rand() % 8;
        seaweed[i].type = rand() % 3;
    }
    for (int i = 0; i < NUM_RUINS; i++) {
        ruins[i].x = rand() % MAP_W;
        ruins[i].y = MAP_H - 1 - rand() % 15;
        ruins[i].type = rand() % 5;
    }
    for (int i = 0; i < NUM_TREASURE; i++) {
        treasure[i].x = rand() % MAP_W;
        treasure[i].y = MAP_H - 1 - rand() % 20;
        treasure[i].type = rand() % 5;
    }
}

// Draw the viewport
void draw_view() {
    cls();
    printf("🌊 Underwater Explorer - Depth: %s - Current: %s - Oxygen: %d%% - Score: %d\n\n",
           depth_emoji[depth],
           current_emoji[water_current],
           oxygen,
           score);

    for (int y = 0; y < VIEW_H; y++) {
        for (int x = 0; x < VIEW_W; x++) {
            int wx = playerX - VIEW_W / 2 + x;
            int wy = playerY - VIEW_H / 2 + y;
            const char *c = "  ";  // Default empty space

            // Check boundaries
            if (wx < 0 || wx >= MAP_W || wy < 0 || wy >= MAP_H) {
                printf("  ");
                continue;
            }

            // Check entities in order of priority
            for (int i = 0; i < NUM_CORAL; i++)
                if (coral[i].x == wx && coral[i].y == wy) {
                    c = coral_emoji[coral[i].type];
                    break;
                }
            for (int i = 0; i < NUM_SEAWEED; i++)
                if (seaweed[i].x == wx && seaweed[i].y == wy) {
                    c = seaweed_emoji[seaweed[i].type];
                    break;
                }
            for (int i = 0; i < NUM_RUINS; i++)
                if (ruins[i].x == wx && ruins[i].y == wy) {
                    c = ruins_emoji[ruins[i].type];
                    break;
                }
            for (int i = 0; i < NUM_TREASURE; i++)
                if (treasure[i].x == wx && treasure[i].y == wy) {
                    c = treasure_emoji[treasure[i].type];
                    break;
                }
            for (int i = 0; i < NUM_WHALES; i++)
                if (whales[i].x == wx && whales[i].y == wy) {
                    c = whales_emoji[whales[i].type];
                    break;
                }
            for (int i = 0; i < NUM_SHARKS; i++)
                if (sharks[i].x == wx && sharks[i].y == wy) {
                    c = sharks_emoji[sharks[i].type];
                    break;
                }
            for (int i = 0; i < NUM_OCTOPUS; i++)
                if (octopus[i].x == wx && octopus[i].y == wy) {
                    c = octopus_emoji[octopus[i].type];
                    break;
                }
            for (int i = 0; i < NUM_SEA_TURTLES; i++)
                if (sea_turtles[i].x == wx && sea_turtles[i].y == wy) {
                    c = turtles_emoji[sea_turtles[i].type];
                    break;
                }
            for (int i = 0; i < NUM_DOLPHINS; i++)
                if (dolphins[i].x == wx && dolphins[i].y == wy) {
                    c = dolphins_emoji[dolphins[i].type];
                    break;
                }
            for (int i = 0; i < NUM_FISH; i++)
                if (fish[i].x == wx && fish[i].y == wy) {
                    c = fish_emoji[fish[i].type];
                    break;
                }

            if (wx == playerX && wy == playerY) c = "🤿";

            printf("%s", c);
        }
        printf("\n");
    }
    printf("\nUse WASD to move, Q to quit, Space to ascend, C to descend\n");
}

// Handle interactions
void interact() {
    for (int i = 0; i < NUM_FISH; i++)
        if (fish[i].x == playerX && fish[i].y == playerY)
            printf("🐠 A colorful fish swims by!\n");
    for (int i = 0; i < NUM_DOLPHINS; i++)
        if (dolphins[i].x == playerX && dolphins[i].y == playerY)
            printf("🐬 A dolphin playfully circles you!\n");
    for (int i = 0; i < NUM_SHARKS; i++)
        if (sharks[i].x == playerX && sharks[i].y == playerY) {
            printf("🦈 A shark approaches! Be careful!\n");
            oxygen -= 5;
        }
    for (int i = 0; i < NUM_WHALES; i++)
        if (whales[i].x == playerX && whales[i].y == playerY)
            printf("🐋 A majestic whale passes in the distance!\n");
    for (int i = 0; i < NUM_OCTOPUS; i++)
        if (octopus[i].x == playerX && octopus[i].y == playerY)
            printf("🐙 An octopus camouflages into the surroundings!\n");
    for (int i = 0; i < NUM_SEA_TURTLES; i++)
        if (sea_turtles[i].x == playerX && sea_turtles[i].y == playerY)
            printf("🐢 A sea turtle glides peacefully!\n");
    for (int i = 0; i < NUM_TREASURE; i++)
        if (treasure[i].x == playerX && treasure[i].y == playerY) {
            printf("💎 You found treasure! +10 points\n");
            treasure[i].x = -1; // Hide the treasure
            treasure[i].y = -1;
            score += 10;
        }
    for (int i = 0; i < NUM_RUINS; i++)
        if (ruins[i].x == playerX && ruins[i].y == playerY)
            printf("🏛️ You explore ancient underwater ruins!\n");
}

// Update world entities
void update_world() {
    frameCounter++;
    
    // Oxygen depletion
    if (frameCounter % 20 == 0) {
        oxygen -= depth + 1;
        if (oxygen <= 0) {
            printf("You ran out of oxygen! Game over.\n");
            exit(0);
        }
    }
    
    // Change water current and depth periodically
    if (frameCounter % 100 == 0) {
        water_current = (water_current + 1) % 3;
        if (rand() % 5 == 0) {
            depth = (depth + 1) % 3;
        }
    }

    // Move entities with water current effect
    int current_effect = water_current - 1; // -1, 0, or 1

    for (int i = 0; i < NUM_FISH; i++) {
        fish[i].x += (rand() % 3 - 1) * fish[i].speed + current_effect;
        fish[i].y += (rand() % 3 - 1) * fish[i].speed;
        if (fish[i].x < 0) fish[i].x = MAP_W - 1;
        if (fish[i].x >= MAP_W) fish[i].x = 0;
        if (fish[i].y < 0) fish[i].y = 0;
        if (fish[i].y >= MAP_H) fish[i].y = MAP_H - 1;
    }

    for (int i = 0; i < NUM_DOLPHINS; i++) {
        dolphins[i].x += dolphins[i].direction * dolphins[i].speed + current_effect;
        if (dolphins[i].x >= MAP_W) dolphins[i].x = 0;
        if (dolphins[i].x < 0) dolphins[i].x = MAP_W - 1;
    }

    for (int i = 0; i < NUM_SHARKS; i++) {
        sharks[i].x += sharks[i].direction * sharks[i].speed + current_effect;
        if (sharks[i].x >= MAP_W) sharks[i].x = 0;
        if (sharks[i].x < 0) sharks[i].x = MAP_W - 1;
    }

    for (int i = 0; i < NUM_WHALES; i++) {
        whales[i].x += whales[i].direction * whales[i].speed + current_effect;
        if (whales[i].x >= MAP_W) whales[i].x = 0;
        if (whales[i].x < 0) whales[i].x = MAP_W - 1;
    }

    for (int i = 0; i < NUM_OCTOPUS; i++) {
        octopus[i].x += (rand() % 3 - 1) + current_effect;
        if (octopus[i].x < 0) octopus[i].x = 0;
        if (octopus[i].x >= MAP_W) octopus[i].x = MAP_W - 1;
    }

    for (int i = 0; i < NUM_SEA_TURTLES; i++) {
        sea_turtles[i].x += sea_turtles[i].direction * sea_turtles[i].speed + current_effect;
        if (sea_turtles[i].x >= MAP_W) sea_turtles[i].x = 0;
        if (sea_turtles[i].x < 0) sea_turtles[i].x = MAP_W - 1;
    }
}

int main() {
    srand(time(NULL));
    set_nonblocking_mode();
    init_world();

    char input;
    while (1) {
        draw_view();
        interact();

        // Handle input
        if (read(STDIN_FILENO, &input, 1) > 0) {
            if (input == 'q' || input == 'Q') break;
            if (input == 'w' && playerY > 0) playerY--;
            if (input == 's' && playerY < MAP_H - 1) playerY++;
            if (input == 'a' && playerX > 0) playerX--;
            if (input == 'd' && playerX < MAP_W - 1) playerX++;
            if (input == ' ') playerY = playerY > 0 ? playerY - 1 : 0; // Ascend
            if (input == 'c') playerY = playerY < MAP_H - 1 ? playerY + 1 : MAP_H - 1; // Descend
        }

        update_world();
        usleep(100000);  // 100ms delay
    }

    // Restore terminal settings
    struct termios ttystate;
    tcgetattr(STDIN_FILENO, &ttystate);
    ttystate.c_lflag |= (ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &ttystate);

    printf("Final Score: %d\n", score);
    return 0;
}