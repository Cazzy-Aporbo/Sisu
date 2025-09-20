#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

// world size
#define WIDTH  40
#define HEIGHT 15

// player position
int playerX = WIDTH / 2;
int playerY = HEIGHT - 2;

char world[HEIGHT][WIDTH];

// clear screen
void clear_screen() {
    printf("\033[2J\033[H");
}

// random flower/animal placement
void populate_world(int season) {
    // fill with spaces
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            world[y][x] = ' ';
        }
    }

    // place flowers
    for (int i = 0; i < 12; i++) {
        int fx = rand() % WIDTH;
        int fy = HEIGHT - 3 - rand() % 3;
        if (season == 3)
            world[fy][fx] = '*'; // snowflakes
        else
            world[fy][fx] = 'f'; // flower
    }

    // place animals
    if (season == 0) world[HEIGHT - 2][5] = 'R'; // rabbit
    if (season == 1) world[3][WIDTH - 5] = 'B'; // bird
    if (season == 2) world[5][10] = 'L'; // leaf
    if (season == 3) world[2][20] = 'S'; // snow
}

// draw world with player
void draw_world(int season) {
    clear_screen();
    printf("Season: %s\n", (char*[]){"SPRING 🌸", "SUMMER ☀️", "AUTUMN 🍂", "WINTER ❄️"}[season]);

    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            if (x == playerX && y == playerY) {
                printf("🧑"); // player
            } else {
                char cell = world[y][x];
                switch (cell) {
                    case 'f': printf("🌸"); break;
                    case 'R': printf("🐇"); break;
                    case 'B': printf("🐦"); break;
                    case 'L': printf("🍂"); break;
                    case 'S': printf("❄️"); break;
                    default: printf(" ");
                }
            }
        }
        printf("\n");
    }
}

// handle interaction
void interact(int season) {
    char cell = world[playerY][playerX];
    switch (cell) {
        case 'f': printf("🌸 You smell a sweet flower.\n"); break;
        case 'R': printf("🐇 The rabbit hops away!\n"); break;
        case 'B': printf("🐦 Birds soar above you.\n"); break;
        case 'L': printf("🍂 A leaf brushes your shoulder.\n"); break;
        case 'S': printf("❄️ Snowflakes melt on your hand.\n"); break;
        default: break;
    }
}

int main() {
    srand(time(NULL));

    int season = 0;
    int frame = 0;

    while (1) {
        populate_world(season);
        draw_world(season);
        interact(season);

        printf("\nMove with WASD, q to quit: ");
        char c = getchar();
        getchar(); // consume newline

        if (c == 'q') break;
        if (c == 'w' && playerY > 0) playerY--;
        if (c == 's' && playerY < HEIGHT - 1) playerY++;
        if (c == 'a' && playerX > 0) playerX--;
        if (c == 'd' && playerX < WIDTH - 1) playerX++;

        frame++;
        if (frame % 5 == 0) {
            season = (season + 1) % 4; // cycle seasons
        }
    }

    return 0;
}