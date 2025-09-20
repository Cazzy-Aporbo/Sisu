#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define MAP_W  100
#define MAP_H  30
#define VIEW_W 40
#define VIEW_H 15

#define NUM_FISH 15
#define NUM_JELLY 8
#define NUM_OCTOPUS 3
#define NUM_SEAWEED 20
#define NUM_BUBBLES 30

typedef struct{int x,y;} Entity;

Entity fish[NUM_FISH], jelly[NUM_JELLY], octopus[NUM_OCTOPUS], seaweed[NUM_SEAWEED], bubbles[NUM_BUBBLES];
int playerX=MAP_W/2, playerY=MAP_H/2;

// emoji sets
const char *fish_emoji[5]={"🐠","🐟","🐡","🦈","🐋"};
const char *jelly_emoji[3]={"🪼","🦀","🦑"};
const char *octopus_emoji[3]={"🐙","🐳","🫧"};
const char *seaweed_emoji[5]={"🌿","🌪️","🪸","🪸","🌱"};
const char *bubble_emoji[3]={"💨","💧","⚪"};

// clear screen
void cls(){printf("\033[2J\033[H");}

// init entities
void init_world(){
    for(int i=0;i<NUM_FISH;i++){fish[i].x=rand()%MAP_W; fish[i].y=rand()%MAP_H;}
    for(int i=0;i<NUM_JELLY;i++){jelly[i].x=rand()%MAP_W; jelly[i].y=rand()%MAP_H;}
    for(int i=0;i<NUM_OCTOPUS;i++){octopus[i].x=rand()%MAP_W; octopus[i].y=MAP_H-2;}
    for(int i=0;i<NUM_SEAWEED;i++){seaweed[i].x=rand()%MAP_W; seaweed[i].y=MAP_H-3;}
    for(int i=0;i<NUM_BUBBLES;i++){bubbles[i].x=rand()%MAP_W; bubbles[i].y=rand()%MAP_H;}
}

// draw viewport
void draw_view(){
    cls();
    printf("Underwater World 🌊\n\n");

    for(int y=0;y<VIEW_H;y++){
        for(int x=0;x<VIEW_W;x++){
            int wx=playerX-VIEW_W/2+x;
            int wy=playerY-VIEW_H/2+y;
            char *c=" ";

            if(wx==playerX && wy==playerY)c="🧑‍🚀";
            for(int i=0;i<NUM_FISH;i++) if(fish[i].x==wx && fish[i].y==wy)c=fish_emoji[rand()%5];
            for(int i=0;i<NUM_JELLY;i++) if(jelly[i].x==wx && jelly[i].y==wy)c=jelly_emoji[rand()%3];
            for(int i=0;i<NUM_OCTOPUS;i++) if(octopus[i].x==wx && octopus[i].y==wy)c=octopus_emoji[rand()%3];
            for(int i=0;i<NUM_SEAWEED;i++) if(seaweed[i].x==wx && seaweed[i].y==wy)c=seaweed_emoji[rand()%5];
            for(int i=0;i<NUM_BUBBLES;i++) if(bubbles[i].x==wx && bubbles[i].y==wy)c=bubble_emoji[rand()%3];

            printf("%s",c);
        }
        printf("\n");
    }
}

// interactions
void interact(){
    for(int i=0;i<NUM_FISH;i++) if(fish[i].x==playerX && fish[i].y==playerY) printf("🐠 A school of fish swims by!\n");
    for(int i=0;i<NUM_JELLY;i++) if(jelly[i].x==playerX && jelly[i].y==playerY) printf("🪼 A jellyfish drifts!\n");
    for(int i=0;i<NUM_OCTOPUS;i++) if(octopus[i].x==playerX && octopus[i].y==playerY) printf("🐙 The octopus waves a tentacle!\n");
    for(int i=0;i<NUM_SEAWEED;i++) if(seaweed[i].x==playerX && seaweed[i].y==playerY) printf("🌿 The seaweed sways.\n");
}

// update entity positions
void update_world(){
    for(int i=0;i<NUM_FISH;i++){fish[i].x+=rand()%3-1; fish[i].y+=rand()%3-1;}
    for(int i=0;i<NUM_JELLY;i++){jelly[i].x+=rand()%3-1; jelly[i].y+=rand()%3-1;}
    for(int i=0;i<NUM_OCTOPUS;i++){octopus[i].x+=rand()%3-1;}
    for(int i=0;i<NUM_BUBBLES;i++){bubbles[i].y-=1; if(bubbles[i].y<0){bubbles[i].y=MAP_H-1; bubbles[i].x=rand()%MAP_W;}}
}

// main
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
        if(c=='s' && playerY<MAP_H-1) playerY++;
        if(c=='a' && playerX>0) playerX--;
        if(c=='d' && playerX<MAP_W-1) playerX++;

        update_world();
        usleep(200000);
    }

    return 0;
}