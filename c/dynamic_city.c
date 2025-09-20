#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <fcntl.h>

#define MAP_W 120
#define MAP_H 40
#define VIEW_W 50
#define VIEW_H 20

#define NUM_PEOPLE 20
#define NUM_DOGS 8
#define NUM_CATS 8
#define NUM_BIRDS 10
#define NUM_CARS 10
#define NUM_BUSES 3
#define NUM_TRAINS 2
#define NUM_BUILDINGS 20
#define NUM_TREES 15
#define NUM_CLOUDS 6

typedef struct {
    int x, y;
    int type;  // For variety in appearance
    int direction;  // For movement direction
} Entity;

Entity people[NUM_PEOPLE], dogs[NUM_DOGS], cats[NUM_CATS], birds[NUM_BIRDS];
Entity cars[NUM_CARS], buses[NUM_BUSES], trains[NUM_TRAINS];
Entity buildings[NUM_BUILDINGS], trees[NUM_TREES], clouds[NUM_CLOUDS];

int playerX = MAP_W / 2, playerY = MAP_H / 2;
int timeOfDay = 0;  // 0=day,1=night
int weather = 0;     // 0=sunny,1=rain,2=snow
int frameCounter = 0;

// Emoji sets
const char *people_emoji[] = {"🧑", "🧍", "🧑‍🦱", "🧑‍🦰", "🧑‍🦳"};
const char *dogs_emoji[] = {"🐕", "🐶", "🐕‍🦺"};
const char *cats_emoji[] = {"🐈", "🐱", "🐈‍⬛"};
const char *birds_emoji[] = {"🐦", "🕊️", "🦅"};
const char *cars_emoji[] = {"🚗", "🚕", "🚙", "🚓", "🛻"};
const char *buses_emoji[] = {"🚌", "🚍"};
const char *trains_emoji[] = {"🚆", "🚄"};
const char *buildings_emoji[] = {"🏢", "🏬", "🏣", "🏤", "🏦"};
const char *trees_emoji[] = {"🌳", "🌴", "🌿"};
const char *clouds_emoji[] = {"☁️", "🌥️", "⛅"};
const char *weather_emoji[] = {"☀️", "🌧️", "❄️"};

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

// Initialize world entities
void init_world() {
    for (int i = 0; i < NUM_PEOPLE; i++) {
        people[i].x = rand() % MAP_W;
        people[i].y = rand() % MAP_H;
        people[i].type = rand() % 5;
        people[i].direction = rand() % 4;
    }
    for (int i = 0; i < NUM_DOGS; i++) {
        dogs[i].x = rand() % MAP_W;
        dogs[i].y = rand() % MAP_H;
        dogs[i].type = rand() % 3;
        dogs[i].direction = rand() % 4;
    }
    for (int i = 0; i < NUM_CATS; i++) {
        cats[i].x = rand() % MAP_W;
        cats[i].y = rand() % MAP_H;
        cats[i].type = rand() % 3;
        cats[i].direction = rand() % 4;
    }
    for (int i = 0; i < NUM_BIRDS; i++) {
        birds[i].x = rand() % MAP_W;
        birds[i].y = rand() % (MAP_H / 2);
        birds[i].type = rand() % 3;
        birds[i].direction = rand() % 4;
    }
    for (int i = 0; i < NUM_CARS; i++) {
        cars[i].x = rand() % MAP_W;
        cars[i].y = MAP_H - 3;
        cars[i].type = rand() % 5;
        cars[i].direction = 1;  // Right by default
    }
    for (int i = 0; i < NUM_BUSES; i++) {
        buses[i].x = rand() % MAP_W;
        buses[i].y = MAP_H - 4;
        buses[i].type = rand() % 2;
        buses[i].direction = 1;
    }
    for (int i = 0; i < NUM_TRAINS; i++) {
        trains[i].x = rand() % MAP_W;
        trains[i].y = MAP_H - 2;
        trains[i].type = rand() % 2;
        trains[i].direction = 1;
    }
    for (int i = 0; i < NUM_BUILDINGS; i++) {
        buildings[i].x = rand() % MAP_W;
        buildings[i].y = rand() % (MAP_H - 5);
        buildings[i].type = rand() % 5;
    }
    for (int i = 0; i < NUM_TREES; i++) {
        trees[i].x = rand() % MAP_W;
        trees[i].y = rand() % (MAP_H - 3);
        trees[i].type = rand() % 3;
    }
    for (int i = 0; i < NUM_CLOUDS; i++) {
        clouds[i].x = rand() % MAP_W;
        clouds[i].y = rand() % 5;
        clouds[i].type = rand() % 3;
        clouds[i].direction = 1;
    }
}

// Draw the viewport
void draw_view() {
    cls();
    printf("🌆 Emoji City - %s - Weather: %s - Pos: %d,%d\n\n",
           timeOfDay == 0 ? "Day" : "Night",
           weather_emoji[weather],
           playerX, playerY);

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
            for (int i = 0; i < NUM_CLOUDS; i++)
                if (clouds[i].x == wx && clouds[i].y == wy) {
                    c = clouds_emoji[clouds[i].type];
                    break;
                }
            for (int i = 0; i < NUM_BUILDINGS; i++)
                if (buildings[i].x == wx && buildings[i].y == wy) {
                    c = buildings_emoji[buildings[i].type];
                    break;
                }
            for (int i = 0; i < NUM_TREES; i++)
                if (trees[i].x == wx && trees[i].y == wy) {
                    c = trees_emoji[trees[i].type];
                    break;
                }
            for (int i = 0; i < NUM_TRAINS; i++)
                if (trains[i].x == wx && trains[i].y == wy) {
                    c = trains_emoji[trains[i].type];
                    break;
                }
            for (int i = 0; i < NUM_BUSES; i++)
                if (buses[i].x == wx && buses[i].y == wy) {
                    c = buses_emoji[buses[i].type];
                    break;
                }
            for (int i = 0; i < NUM_CARS; i++)
                if (cars[i].x == wx && cars[i].y == wy) {
                    c = cars_emoji[cars[i].type];
                    break;
                }
            for (int i = 0; i < NUM_PEOPLE; i++)
                if (people[i].x == wx && people[i].y == wy) {
                    c = people_emoji[people[i].type];
                    break;
                }
            for (int i = 0; i < NUM_DOGS; i++)
                if (dogs[i].x == wx && dogs[i].y == wy) {
                    c = dogs_emoji[dogs[i].type];
                    break;
                }
            for (int i = 0; i < NUM_CATS; i++)
                if (cats[i].x == wx && cats[i].y == wy) {
                    c = cats_emoji[cats[i].type];
                    break;
                }
            for (int i = 0; i < NUM_BIRDS; i++)
                if (birds[i].x == wx && birds[i].y == wy) {
                    c = birds_emoji[birds[i].type];
                    break;
                }

            if (wx == playerX && wy == playerY) c = "🧑‍🚀";

            printf("%s", c);
        }
        printf("\n");
    }
    printf("\nUse WASD to move, Q to quit\n");
}

// Handle interactions
void interact() {
    for (int i = 0; i < NUM_PEOPLE; i++)
        if (people[i].x == playerX && people[i].y == playerY)
            printf("🧑 A pedestrian waves!\n");
    for (int i = 0; i < NUM_DOGS; i++)
        if (dogs[i].x == playerX && dogs[i].y == playerY)
            printf("🐕 A dog barks!\n");
    for (int i = 0; i < NUM_CATS; i++)
        if (cats[i].x == playerX && cats[i].y == playerY)
            printf("🐈 A cat crosses your path!\n");
    for (int i = 0; i < NUM_BIRDS; i++)
        if (birds[i].x == playerX && birds[i].y == playerY)
            printf("🐦 A bird flies above!\n");
    for (int i = 0; i < NUM_CARS; i++)
        if (cars[i].x == playerX && cars[i].y == playerY)
            printf("🚗 A car honks!\n");
    for (int i = 0; i < NUM_BUSES; i++)
        if (buses[i].x == playerX && buses[i].y == playerY)
            printf("🚌 The bus stops nearby!\n");
    for (int i = 0; i < NUM_TRAINS; i++)
        if (trains[i].x == playerX && trains[i].y == playerY)
            printf("🚆 The train speeds past!\n");
    for (int i = 0; i < NUM_TREES; i++)
        if (trees[i].x == playerX && trees[i].y == playerY)
            printf("🌳 The tree shades you.\n");
    for (int i = 0; i < NUM_BUILDINGS; i++)
        if (buildings[i].x == playerX && buildings[i].y == playerY)
            printf("🏢 You admire the building.\n");
}

// Update world entities
void update_world() {
    frameCounter++;

    // Change time and weather periodically
    if (frameCounter % 100 == 0) {
        timeOfDay = 1 - timeOfDay;
        weather = (weather + 1) % 3;
    }

    // Move entities
    for (int i = 0; i < NUM_PEOPLE; i++) {
        people[i].x += rand() % 3 - 1;
        people[i].y += rand() % 3 - 1;
        if (people[i].x < 0) people[i].x = 0;
        if (people[i].x >= MAP_W) people[i].x = MAP_W - 1;
        if (people[i].y < 0) people[i].y = 0;
        if (people[i].y >= MAP_H) people[i].y = MAP_H - 1;
    }

    for (int i = 0; i < NUM_DOGS; i++) {
        dogs[i].x += rand() % 3 - 1;
        dogs[i].y += rand() % 3 - 1;
        if (dogs[i].x < 0) dogs[i].x = 0;
        if (dogs[i].x >= MAP_W) dogs[i].x = MAP_W - 1;
        if (dogs[i].y < 0) dogs[i].y = 0;
        if (dogs[i].y >= MAP_H) dogs[i].y = MAP_H - 1;
    }

    for (int i = 0; i < NUM_CATS; i++) {
        cats[i].x += rand() % 3 - 1;
        cats[i].y += rand() % 3 - 1;
        if (cats[i].x < 0) cats[i].x = 0;
        if (cats[i].x >= MAP_W) cats[i].x = MAP_W - 1;
        if (cats[i].y < 0) cats[i].y = 0;
        if (cats[i].y >= MAP_H) cats[i].y = MAP_H - 1;
    }

    for (int i = 0; i < NUM_BIRDS; i++) {
        birds[i].x += rand() % 3 - 1;
        birds[i].y += rand() % 3 - 1;
        if (birds[i].x < 0) birds[i].x = MAP_W - 1;
        if (birds[i].x >= MAP_W) birds[i].x = 0;
        if (birds[i].y < 0) birds[i].y = 0;
        if (birds[i].y >= MAP_H / 2) birds[i].y = (MAP_H / 2) - 1;
    }

    for (int i = 0; i < NUM_CARS; i++) {
        cars[i].x += cars[i].direction;
        if (cars[i].x >= MAP_W) cars[i].x = 0;
        if (cars[i].x < 0) cars[i].x = MAP_W - 1;
    }

    for (int i = 0; i < NUM_BUSES; i++) {
        buses[i].x += buses[i].direction;
        if (buses[i].x >= MAP_W) buses[i].x = 0;
        if (buses[i].x < 0) buses[i].x = MAP_W - 1;
    }

    for (int i = 0; i < NUM_TRAINS; i++) {
        trains[i].x += 2 * trains[i].direction;
        if (trains[i].x >= MAP_W) trains[i].x = 0;
        if (trains[i].x < 0) trains[i].x = MAP_W - 1;
    }

    for (int i = 0; i < NUM_CLOUDS; i++) {
        clouds[i].x += clouds[i].direction;
        if (clouds[i].x >= MAP_W) clouds[i].x = 0;
        if (clouds[i].x < 0) clouds[i].x = MAP_W - 1;
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
        }

        update_world();
        usleep(100000);  // 100ms delay
    }

    // Restore terminal settings
    struct termios ttystate;
    tcgetattr(STDIN_FILENO, &ttystate);
    ttystate.c_lflag |= (ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &ttystate);

    return 0;
}