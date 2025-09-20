#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <string.h>

#define MAP_WIDTH  100
#define MAP_HEIGHT 30
#define VIEW_WIDTH  40
#define VIEW_HEIGHT 15
#define NUM_FLOWERS 30
#define NUM_RABBITS 5
#define NUM_BIRDS 5

typedef struct { int x, y; } Entity;

Entity flowers[NUM_FLOWERS];
Entity rabbits[NUM_RABBITS];
Entity birds[NUM_BIRDS];

int playerX = MAP_WIDTH / 2;
int playerY = MAP_HEIGHT / 2;
int season = 0;
int frame = 0;

// clear screen
void clear_screen() { printf("\033[2J\033[H"); }

// initialize entities randomly
void init_world() {
    for(int i=0;i<NUM_FLOWERS;i++){flowers[i].x=rand()%MAP_WIDTH; flowers[i].y=rand()%MAP_HEIGHT;}
    for(int i=0;i<NUM_RABBITS;i++){rabbits[i].x=rand()%MAP_WIDTH; rabbits[i].y=rand()%MAP_HEIGHT;}
    for(int i=0;i<NUM_BIRDS;i++){birds[i].x=rand()%MAP_WIDTH; birds[i].y=rand()%MAP_HEIGHT/2;}
}

// draw viewport
void draw_view() {
    clear_screen();
    printf("Season: %s\n\n", (char*[]){"SPRING 🌸","SUMMER ☀️","AUTUMN 🍂","WINTER ❄️"}[season]);

    for(int y=0;y<VIEW_HEIGHT;y++){
        for(int x=0;x<VIEW_WIDTH;x++){
            int worldX = playerX - VIEW_WIDTH/2 + x;
            int worldY = playerY - VIEW_HEIGHT/2 + y;

            char c = ' ';
            if(worldX==playerX && worldY==playerY){c='@';} // player
            for(int i=0;i<NUM_FLOWERS;i++) if(flowers[i].x==worldX && flowers[i].y==worldY) c='f';
            for(int i=0;i<NUM_RABBITS;i++) if(rabbits[i].x==worldX && rabbits[i].y==worldY) c='R';
            for(int i=0;i<NUM_BIRDS;i++) if(birds[i].x==worldX && birds[i].y==worldY) c='B';

            switch(c){
                case '@': printf("🧑"); break;
                case 'f': printf("🌸"); break;
                case 'R': printf("🐇"); break;
                case 'B': printf("🐦"); break;
                default: printf(" "); break;
            }
        }
        printf("\n");
    }
}

// interaction with entities
void interact(){
    for(int i=0;i<NUM_FLOWERS;i++) if(flowers[i].x==playerX && flowers[i].y==playerY) printf("🌸 You smell a sweet flower!\n");
    for(int i=0;i<NUM_RABBITS;i++) if(rabbits[i].x==playerX && rabbits[i].y==playerY) printf("🐇 The rabbit hops away!\n");
    for(int i=0;i<NUM_BIRDS;i++) if(birds[i].x==playerX && birds[i].y==playerY) printf("🐦 A bird flies above you!\n");
}

// move animals randomly
void move_animals(){
    for(int i=0;i<NUM_RABBITS;i++){rabbits[i].x+=rand()%3-1; rabbits[i].y+=rand()%3-1;}
    for(int i=0;i<NUM_BIRDS;i++){birds[i].x+=rand()%3-1; birds[i].y+=rand()%2-1;}
}

// main loop
int main(){
    srand(time(NULL));
    init_world();

    while(1){
        draw_view();
        interact();
        printf("\nMove WASD, q to quit: ");
        char c=getchar(); getchar();
        if(c=='q') break;
        if(c=='w' && playerY>0) playerY--;
        if(c=='s' && playerY<MAP_HEIGHT-1) playerY++;
        if(c=='a' && playerX>0) playerX--;
        if(c=='d' && playerX<MAP_WIDTH-1) playerX++;

        move_animals();
        frame++;
        if(frame % 10==0) season=(season+1)%4;
    }

    return 0;
}