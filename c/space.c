#include <stdio.h>
#include <unistd.h>  // for sleep() on Linux/macOS. On Windows use <windows.h> and Sleep(ms).

int main(void) {
    int countdown = 5;

    printf("=====================================\n");
    printf("         🚀 Welcome to SISU 🚀       \n");
    printf("        Space Exploration Demo       \n");
    printf("=====================================\n\n");

    printf("Mission Control: All systems go!\n");
    printf("Starting countdown...\n\n");

    while (countdown > 0) {
        printf("T-minus %d...\n", countdown);
        sleep(1);   // pause for dramatic effect
        countdown--;
    }

    printf("\nIgnition sequence start...\n");
    sleep(1);

    // ASCII Rocket Launch
    for (int i = 0; i < 10; i++) {
        printf("       ^\n");
        printf("      / \\\n");
        printf("     /   \\\n");
        printf("    |     |\n");
        printf("    | NASA|\n");
        printf("    |     |\n");
        printf("     \\___/\n");
        printf("     /|||\\\n");
        printf("      |||\n");
        printf("      |||\n");
        printf("      |||\n");
        printf("     (===)\n");
        printf("      ( )\n\n");

        sleep(1);
        printf("\033[2J\033[H"); // clear screen (ANSI escape)
    }

    printf("🌌 The rocket has launched into space! 🌌\n");
    printf("Mission accomplished.\n");

    return 0;
}