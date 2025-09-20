#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define WIDTH  50
#define HEIGHT 15
#define NUM_FLOWERS 12

// ANSI color palette
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
    int sway;   // current sway offset
    int dir;    // sway direction
    int color;  // flower color
} Flower;

Flower meadow[NUM_FLOWERS];

// clear the screen
void clear_screen() {
    printf("\033[2J\033[H");
}

// draw one flower at (x,y)
void draw_flower(Flower f) {
    int i;
    for (i = 0; i < f.y; i++) printf("\n");
    for (i = 0; i < f.x + f.sway; i++) printf(" ");

    // bloom top
    printf("%s  @  \033[0m\n", colors[f.color]);

    for (i = 0; i < f.x + f.sway; i++) printf(" ");
    printf("%s /|\\ \033[0m\n", colors[f.color]);

    for (i = 0; i < f.x + f.sway; i++) printf(" ");
    printf("%s  |  \033[0m\n", colors[f.color]);

    for (i = 0; i < f.x + f.sway; i++) printf(" ");
    printf("%s / \\ \033[0m\n", colors[f.color]);
}

// animate sway + color shimmer
void update_flower(Flower *f) {
    f->sway += f->dir;
    if (f->sway > 2 || f->sway < -2) {
        f->dir *= -1; // reverse direction
    }
    if (rand() % 10 == 0) {
        f->color = rand() % 7; // random color shimmer
    }
}

int main() {
    srand(time(NULL));

    // initialize flowers in random places
    for (int i = 0; i < NUM_FLOWERS; i++) {
        meadow[i].x = rand() % (WIDTH - 6);
        meadow[i].y = rand() % (HEIGHT - 4);
        meadow[i].sway = 0;
        meadow[i].dir = (rand() % 2 == 0) ? 1 : -1;
        meadow[i].color = rand() % 7;
    }

    // infinite animation
    while (1) {
        clear_screen();
        printf("=====================================\n");
        printf("     🌸🌼 Wildflowers in the Wind 🌻   \n");
        printf("=====================================\n\n");

        for (int i = 0; i < NUM_FLOWERS; i++) {
            draw_flower(meadow[i]);
            update_flower(&meadow[i]);
        }

        fflush(stdout);
        usleep(300000); // ~0.3 sec delay
    }

    return 0;
}