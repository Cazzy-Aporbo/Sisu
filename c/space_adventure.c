#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

// screen clear (ANSI escape)
void clear_screen() {
    printf("\033[2J\033[H");
}

// draw stars randomly
void draw_starry_sky() {
    int width = 40, height = 15;
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            if (rand() % 20 == 0) {
                printf("*");
            } else {
                printf(" ");
            }
        }
        printf("\n");
    }
}

// rocket ASCII art
void draw_ship(int x, int y) {
    for (int i = 0; i < y; i++) printf("\n");
    for (int i = 0; i < x; i++) printf(" ");
    printf("   ^   \n");
    for (int i = 0; i < x; i++) printf(" ");
    printf("  /|\\  \n");
    for (int i = 0; i < x; i++) printf(" ");
    printf("  |||  \n");
    for (int i = 0; i < x; i++) printf(" ");
    printf(" /===\\ \n");
}

// asteroid danger alert
void asteroid_alert() {
    clear_screen();
    printf("⚠️  ALERT! ASTEROID FIELD AHEAD! ⚠️\n");
    for (int i = 0; i < 3; i++) {
        printf("💥💥💥 CRASH IMMINENT 💥💥💥\n");
        sleep(1);
    }
    printf("Phew... you narrowly escaped!\n");
    sleep(2);
}

// warp sequence
void warp_drive() {
    clear_screen();
    printf("⚡ Engaging Warp Drive ⚡\n\n");
    for (int i = 0; i < 5; i++) {
        printf(">>> ZOOM >>>\n");
        sleep(1);
    }
    printf("\n🌍 Destination Reached!\n");
    sleep(2);
}

int main() {
    srand(time(NULL));
    int choice;

    clear_screen();
    printf("=====================================\n");
    printf("        🚀 Welcome to SISU-1 🚀      \n");
    printf("  Interstellar Adventure Simulation  \n");
    printf("=====================================\n\n");

    sleep(1);
    printf("You are the captain of the starship SISU.\n");
    printf("Where do you want to go?\n");
    printf("1. Mars 🌕\n");
    printf("2. Andromeda 🌌\n");
    printf("3. Random Wormhole 🌀\n");
    printf("Choose your mission (1-3): ");
    scanf("%d", &choice);

    clear_screen();
    printf("Preparing launch...\n");
    sleep(2);

    // liftoff animation
    for (int i = 5; i >= 0; i--) {
        clear_screen();
        printf("T-minus %d...\n\n", i);
        draw_ship(10, i);
        sleep(1);
    }

    printf("\n🚀 Liftoff! You are in space...\n");
    sleep(2);

    // fly through stars
    for (int i = 0; i < 5; i++) {
        clear_screen();
        draw_starry_sky();
        draw_ship(15, 5);
        sleep(1);
    }

    // random asteroid encounter
    if (rand() % 2 == 0) {
        asteroid_alert();
    }

    // warp to destination
    warp_drive();

    switch (choice) {
        case 1:
            printf("🪐 You landed safely on Mars!\n");
            break;
        case 2:
            printf("🌌 Welcome to the Andromeda Galaxy!\n");
            break;
        case 3:
            printf("🌀 You got sucked into a wormhole and found...\n");
            printf("A dimension made entirely of 🍕 PIZZA PLANETS 🍕\n");
            break;
        default:
            printf("🤔 Invalid choice, so you drifted endlessly in space.\n");
    }

    printf("\nMission Complete. Good job, Captain!\n");
    return 0;
}