#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

// clear screen
void clear_screen() {
    printf("\033[2J\033[H");
}

// draw random stars
void draw_stars(int width, int height) {
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            if (rand() % 30 == 0) printf("*");
            else printf(" ");
        }
        printf("\n");
    }
}

// ASCII spaceman in different poses
void draw_spaceman(int pose, int x, int y) {
    for (int i = 0; i < y; i++) printf("\n");
    for (int i = 0; i < x; i++) printf(" ");

    switch (pose % 3) {
        case 0:
            printf("  o  \n");
            for (int i = 0; i < x; i++) printf(" ");
            printf(" /|\\ \n");
            for (int i = 0; i < x; i++) printf(" ");
            printf(" / \\ \n");
            break;
        case 1:
            printf("  o/ \n");
            for (int i = 0; i < x; i++) printf(" ");
            printf(" <|  \n");
            for (int i = 0; i < x; i++) printf(" ");
            printf(" / > \n");
            break;
        case 2:
            printf("\\o/  \n");
            for (int i = 0; i < x; i++) printf(" ");
            printf(" |   \n");
            for (int i = 0; i < x; i++) printf(" ");
            printf("/ \\  \n");
            break;
    }
}

// asteroid encounter
void asteroid_event() {
    clear_screen();
    printf("💥 SPACEMAN HIT BY ASTEROID 💥\n");
    sleep(1);
    printf("But his suit is strong... he drifts onward.\n");
    sleep(2);
}

// warp event
void warp_event() {
    clear_screen();
    printf("⚡ The spaceman falls into a cosmic wormhole ⚡\n\n");
    for (int i = 0; i < 5; i++) {
        printf(">>> WARPING >>>\n");
        sleep(1);
    }
    printf("\n🪐 He emerges somewhere new in the galaxy...\n");
    sleep(2);
}

int main() {
    srand(time(NULL));

    clear_screen();
    printf("=====================================\n");
    printf("      🧑‍🚀 SPACEMAN ADVENTURE v1.0    \n");
    printf("=====================================\n\n");
    printf("You are an astronaut drifting through space...\n");
    sleep(2);

    // drifting animation
    for (int i = 0; i < 15; i++) {
        clear_screen();
        draw_stars(40, 10);
        draw_spaceman(i, rand() % 20, rand() % 5);
        sleep(1);

        if (rand() % 10 == 0) asteroid_event();
        if (rand() % 15 == 0) warp_event();
    }

    clear_screen();
    printf("The spaceman waves goodbye 👋 and continues drifting...\n");
    printf("Mission over. But space never ends. 🌌\n");

    return 0;
}