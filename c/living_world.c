#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define WIDTH  80
#define HEIGHT 24
#define NUM_FLOWERS 15
#define NUM_CLOUDS 5
#define NUM_STARS 20

typedef struct {
    int x, y;
    int sway;
    int dir;
    int color;
} Flower;

typedef struct {
    int x, y;
    int speed;
} Cloud;

typedef struct {
    int x, y;
} Star;

Flower meadow[NUM_FLOWERS];
Cloud clouds[NUM_CLOUDS];
Star stars[NUM_STARS];

const char *colors[] = {
    "\033[31m", // red
    "\033[32m", // green
    "\033[33m", // yellow
    "\033[34m", // blue
    "\033[35m", // magenta
    "\033[36m", // cyan
    "\033[37m"  // white
};

void clear_screen() {
    printf("\033[2J\033[H");
}

// --- Flowers ---
void draw_flower(Flower f, int season) {
    for (int i = 0; i < f.x + f.sway; i++) printf(" ");

    switch (season) {
        case 0: printf("%s@ \033[0m", colors[f.color]); break; // Spring
        case 1: printf("%s@@\033[0m", colors[f.color]); break; // Summer
        case 2: printf("\033[33m*\033[0m", colors[f.color]); break; // Autumn
        case 3: printf("❄️"); break; // Winter
    }
}

void update_flower(Flower *f) {
    f->sway += f->dir;
    if (f->sway > 2 || f->sway < -2) {
        f->dir *= -1;
    }
    if (rand() % 12 == 0) {
        f->color = rand() % 7;
    }
}

// --- Clouds ---
void draw_clouds() {
    for (int i = 0; i < NUM_CLOUDS; i++) {
        for (int j = 0; j < clouds[i].y; j++) printf("\n");
        for (int j = 0; j < clouds[i].x; j++) printf(" ");
        printf("☁️☁️");
    }
    printf("\n");
}

void update_clouds() {
    for (int i = 0; i < NUM_CLOUDS; i++) {
        clouds[i].x += clouds[i].speed;
        if (clouds[i].x > WIDTH) {
            clouds[i].x = -5;
            clouds[i].y = rand() % 5;
        }
    }
}

// --- Stars ---
void draw_stars() {
    for (int i = 0; i < NUM_STARS; i++) {
        for (int j = 0; j < stars[i].y; j++) printf("\n");
        for (int j = 0; j < stars[i].x; j++) printf(" ");
        if (rand() % 3 == 0) printf("⭐");
    }
    printf("\n");
}

// --- Animals ---
void draw_animals(int season, int frame) {
    if (season == 0 && frame % 10 == 0) {
        printf("🐇 A rabbit hops by!\n");
    }
    if (season == 1 && frame % 15 == 0) {
        printf("🐦 Birds soar across the sky!\n");
    }
    if (season == 2 && rand() % 4 == 0) {
        printf("🍂 Leaves drift down...\n");
    }
    if (season == 3 && rand() % 3 == 0) {
        printf("❄️ Snowflakes fall gently...\n");
    }
}

// --- Main ---
int main() {
    srand(time(NULL));

    // init flowers
    for (int i = 0; i < NUM_FLOWERS; i++) {
        meadow[i].x = rand() % (WIDTH - 6);
        meadow[i].y = HEIGHT - 5 + rand() % 3;
        meadow[i].sway = 0;
        meadow[i].dir = (rand() % 2 == 0) ? 1 : -1;
        meadow[i].color = rand() % 7;
    }

    // init clouds
    for (int i = 0; i < NUM_CLOUDS; i++) {
        clouds[i].x = rand() % WIDTH;
        clouds[i].y = rand() % 5;
        clouds[i].speed = 1;
    }

    // init stars
    for (int i = 0; i < NUM_STARS; i++) {
        stars[i].x = rand() % WIDTH;
        stars[i].y = rand() % 6;
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

        // draw sky
        if (season == 3) draw_stars();
        draw_clouds();

        // draw meadow
        for (int i = 0; i < NUM_FLOWERS; i++) {
            draw_flower(meadow[i], season);
            update_flower(&meadow[i]);
            printf("\n");
        }

        draw_animals(season, frame);

        fflush(stdout);
        usleep(300000); // 0.3s delay
        frame++;

        update_clouds();

        if (frame % 30 == 0) {
            season = (season + 1) % 4;
        }
    }

    return 0;
}