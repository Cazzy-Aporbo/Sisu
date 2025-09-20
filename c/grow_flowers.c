#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

// ANSI escape for colors
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

// draw a flower at random position
void draw_flower(int x, int y, int c) {
    for (int i = 0; i < y; i++) printf("\n");
    for (int i = 0; i < x; i++) printf(" ");
    printf("%s  @  \033[0m\n", colors[c]);
    for (int i = 0; i < x; i++) printf(" ");
    printf("%s /|\\ \033[0m\n", colors[c]);
    for (int i = 0; i < x; i++) printf(" ");
    printf("%s  |  \033[0m\n", colors[c]);
    for (int i = 0; i < x; i++) printf(" ");
    printf("%s / \\ \033[0m\n", colors[c]);
}

// blooming animation
void bloom_flower(int x, int y, int c) {
    clear_screen();
    for (int stage = 0; stage < 3; stage++) {
        for (int i = 0; i < y; i++) printf("\n");
        for (int i = 0; i < x; i++) printf(" ");
        if (stage == 0) printf("%s  .  \033[0m\n", colors[c]);
        else if (stage == 1) printf("%s (o) \033[0m\n", colors[c]);
        else printf("%s  @  \033[0m\n", colors[c]);

        for (int i = 0; i < x; i++) printf(" ");
        printf("%s /|\\ \033[0m\n", colors[c]);
        for (int i = 0; i < x; i++) printf(" ");
        printf("%s  |  \033[0m\n", colors[c]);
        for (int i = 0; i < x; i++) printf(" ");
        printf("%s / \\ \033[0m\n", colors[c]);
        sleep(1);
        clear_screen();
    }
    draw_flower(x, y, c);
}

int main() {
    srand(time(NULL));

    clear_screen();
   