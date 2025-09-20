#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define WIDTH  50
#define HEIGHT 15
#define NUM_FLOWERS 10
#define SEASON_DURATION 10  // seconds per season

// ANSI colors
const char *colors[] = {
    "\033[31m", // red
    "\033[32m", // green
    "\033[33m", // yellow
    "\033[34m", // blue
    "\033[35m", // magenta
    "\033[36m", // cyan
    "\033[37m"  // white
};

typedef struct {
    int x, y;
    int sway;   // sway offset
    int dir;    // sway direction
    int color;  // base color
} Flower;

Flower meadow[NUM_FLOWERS];

// clear the screen
void clear_screen() {
    printf("\033[2J\033[H");
}

// draw a flower depending on season
void draw_flower(Flower f, int season) {
    for (int i = 0; i < f.y; i++) printf("\n");
    for (int i = 0; i < f.x + f.sway; i++) printf(" ");

    switch (season) {
        case 0: // Spring
            printf("%s  @  \033[0m\n", colors[f.color]);
            for (int i = 0; i < f.x + f.sway; i++) printf(" ");
            printf("%s /|\\ \033[0m\n", colors[1]); // stem green
            break;

        case 1: // Summer (tall & lush)
            printf("%s  @@@  \033[0m\n", colors[f.color]);
            for (int i = 0; i < f.x + f.sway; i++) printf(" ");
            printf("%s  | |  \033[0m\n", colors[1]);
            for (int i = 0; i < f.x + f.sway; i++) printf(" ");
            printf("%s  | |  \033[0m\n", colors[1]);
            break;

        case 2: // Autumn (fewer petals, warm colors)
            printf("\033[31m  *  \033[0m\n"); // red/orange
            for (int i = 0; i < f.x + f.sway; i++) printf(" ");
            printf("\033[33m  |  \033[0m\n"); // yellowish stem
            break;

        case 3: // Winter (bare stem with snowflake)
            printf("  ❄️  \n");
            for (int i = 0; i < f.x + f.sway; i++) printf(" ");
            printf("  |  \n");
            break;
    }

    // common base
    for (int i = 0; i < f.x + f.sway; i++) printf(" ");
    printf("  |  \n");
    for (int i = 0; i < f.x + f.sway; i++) printf(" ");
    printf(" / \\ \n");
}

// sway update
void update_flower(Flower *f) {
    f->sway += f->dir;
    if (f->sway > 2 || f->sway < -2) {
        f->dir *= -1;
    }
    if (rand() % 10 == 0) {
        f->color = rand() % 7;
    }
}

int main() {
    srand(time(NULL));

    // init flowers
    for (int i = 0; i < NUM_FLOWERS; i++) {
        meadow[i].x = rand() % (WIDTH - 6);
        meadow[i].y = rand() % (HEIGHT - 4);
        meadow[i].sway = 0;
        meadow[i].dir = (rand() % 2 == 0) ? 1 : -1;
        meadow[i].color = rand() % 7;
    }

    int season = 0; // start at spring
    int frame = 0;

    while (1) {
        clear_screen();

        switch (season) {
            case 0: printf("🌱 SPRING — Flowers Bloom 🌸\n\n"); break;
            case 1: printf("☀️  SUMMER — Meadow in Full Bloom 🌻\n\n"); break;
            case 2: printf("🍂 AUTUMN — Leaves Falling 🍁\n\n"); break;
            case 3: printf("❄️  WINTER — Silent Snowfall ❄️\n\n"); break;
        }

        for (int i = 0; i < NUM_FLOWERS; i++) {
            draw_flower(meadow[i], season);
            update_flower(&meadow[i]);
        }

        fflush(stdout);
        usleep(300000); // 0.3s per frame
        frame++;

        if (frame % (SEASON_DURATION * 3) == 0) {
            season = (season + 1) % 4; // cycle seasons
        }
    }

    return 0;
}