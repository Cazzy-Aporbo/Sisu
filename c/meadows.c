#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define WIDTH  60
#define HEIGHT 20
#define NUM_FLOWERS 12
#define SEASON_DURATION 10 // seconds per season

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
    int sway;
    int dir;
    int color;
} Flower;

Flower meadow[NUM_FLOWERS];

// clear screen
void clear_screen() {
    printf("\033[2J\033[H");
}

// draw flower depending on season
void draw_flower(Flower f, int season) {
    for (int i = 0; i < f.y; i++) printf("\n");
    for (int i = 0; i < f.x + f.sway; i++) printf(" ");

    switch (season) {
        case 0: // Spring
            printf("%s  @  \033[0m\n", colors[f.color]);
            break;
        case 1: // Summer
            printf("%s  @@@  \033[0m\n", colors[f.color]);
            break;
        case 2: // Autumn
            printf("\033[33m  *  \033[0m\n"); // orange/golden
            break;
        case 3: // Winter
            printf("  ❄️  \n");
            break;
    }

    for (int i = 0; i < f.x + f.sway; i++) printf(" ");
    printf("%s  |  \033[0m\n", colors[1]); // stem
    for (int i = 0; i < f.x + f.sway; i++) printf(" ");
    printf(" / \\ \n");
}

// update flower animation
void update_flower(Flower *f) {
    f->sway += f->dir;
    if (f->sway > 2 || f->sway < -2) {
        f->dir *= -1;
    }
    if (rand() % 10 == 0) {
        f->color = rand() % 7;
    }
}

// animals and extras
void draw_animals(int season) {
    if (season == 0) { // Spring
        if (rand() % 5 == 0) printf("🐇  A rabbit hops across the meadow!\n");
        if (rand() % 5 == 0) printf("🐝  A bee buzzes around the flowers.\n");
        if (rand() % 8 == 0) printf("🦋  A butterfly flutters by.\n");
    }
    if (season == 1) { // Summer
        if (rand() % 5 == 0) printf("🐦  Birds soar across the sky.\n");
        if (rand() % 6 == 0) printf("🐝  Bees are busy gathering nectar.\n");
        if (rand() % 8 == 0) printf("🦋  A bright butterfly dances in the air.\n");
    }
    if (season == 2) { // Autumn
        if (rand() % 3 == 0) printf("🍂  Leaves drift gently to the ground...\n");
    }
    if (season == 3) { // Winter
        if (rand() % 3 == 0) printf("❄️  Snowflakes fall silently...\n");
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

    int season = 0;
    int frame = 0;

    while (1) {
        clear_screen();

        switch (season) {
            case 0: printf("🌱 SPRING — Rabbits, Bees, and Butterflies 🌸\n\n"); break;
            case 1: printf("☀️  SUMMER — Birds, Bees, and Butterflies 🌻\n\n"); break;
            case 2: printf("🍂 AUTUMN — Falling Leaves 🍁\n\n"); break;
            case 3: printf("❄️  WINTER — Silent Snowfall ❄️\n\n"); break;
        }

        for (int i = 0; i < NUM_FLOWERS; i++) {
            draw_flower(meadow[i], season);
            update_flower(&meadow[i]);
        }

        printf("\n");
        draw_animals(season);

        fflush(stdout);
        usleep(400000); // ~0.4s delay per frame
        frame++;

        if (frame % (SEASON_DURATION * 2) == 0) {
            season = (season + 1) % 4;
        }
    }

    return 0;
}