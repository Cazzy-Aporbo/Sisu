#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define MAP_W  100
#define MAP_H  30
#define VIEW_W 40
#define VIEW_H 15

#define NUM_FLOWERS 25
#define NUM_RABBITS 5
#define NUM_BIRDS 5
#define NUM_CLOUDS 5
#define NUM_STARS 20

typedef struct{int x,y;} Entity;
Entity flowers[NUM_FLOWERS], rabbits[NUM_RABBITS], birds[NUM_BIRDS];
Entity clouds[NUM_CLOUDS], stars[NUM_STARS];

int playerX=MAP_W/2, playerY=MAP_H/2;
int season=0, frame=0;

// clear screen
void cls(){printf("\033[2J\033[H");}

// init entities
void init_world(){
    for(int i=0;i<NUM_FLOWERS;i++){flowers[i].x=rand()%MAP_W; flowers[i].y=MAP_H-3-rand()%3;}
    for(int i=0;i<NUM_RABBITS;i++){rabbits[i].x=rand()%MAP_W; rabbits[i].y=MAP_H-2-rand()%2;}
    for(int i=0;i<NUM_BIRDS;i++){birds[i].x=rand()%MAP_W; birds[i].y=rand()%3;}
    for(int i=0;i<NUM_CLOUDS;i++){clouds[i].x=rand()%MAP_W; clouds[i].y=rand()%5;}
    for(int i=0;i<NUM_STARS;i++){stars[i].x=rand()%MAP_W; stars[i].y=rand()%6;}
}

// draw viewport
void draw_view(){
    cls();
    printf("Season: %s\n\n",(char*[]){"SPRING 🌸","SUMMER ☀️","AUTUMN 🍂","WINTER ❄️"}[season]);

    for(int y=0;y<VIEW_H;y++){
        for(int x=0;x<VIEW_W;x++){
            int wx=playerX-VIEW_W/2+x;
            int wy=playerY-VIEW_H/2+y;
            char c=' ';

            if(wx==playerX && wy==playerY)c='@';
            for(int i=0;i<NUM_FLOWERS;i++) if(flowers[i].x==wx && flowers[i].y==wy)c='f';
            for(int i=0;i<NUM_RABBITS;i++) if(rabbits[i].x==wx && rabbits[i].y==wy)c='R';
            for(int i=0;i<NUM_BIRDS;i++) if(birds[i].x==wx && birds[i].y==wy)c='B';
            for(int i=0;i<NUM_CLOUDS;i++) if(clouds[i].x==wx && clouds[i].y==wy)c='C';
            for(int i=0;i<NUM_STARS;i++) if(stars[i].x==wx && stars[i].y==wy)c='*';

            switch(c){
                case '@': printf("🧑"); break;
                case 'f': printf("🌸"); break;
                case 'R': printf("🐇"); break;
                case 'B': printf("🐦"); break;
                case 'C': printf("☁️"); break;
                case '*': printf("⭐"); break;
                default: printf(" "); break;
            }
        }
        printf("\n");
    }
}

// interactions
void interact(){
    for(int i=0;i<NUM_FLOWERS;i++) if(flowers[i].x==playerX && flowers[i].y==playerY) printf("🌸 You smell a sweet flower!\n");
    for(int i=0;i<NUM_RABBITS;i++) if(rabbits[i].x==playerX && rabbits[i].y==playerY) printf("🐇 The rabbit hops away!\n");
    for(int i=0;i<NUM_BIRDS;i++) if(birds[i].x==playerX && birds[i].y==playerY) printf("🐦 Birds fly above!\n");
    for(int i=0;i<NUM_STARS;i++) if(stars[i].x==playerX && stars[i].y==playerY) printf("⭐ Stars twinkle!\n");
    for(int i=0;i<NUM_CLOUDS;i++) if(clouds[i].x==playerX && clouds[i].y==playerY) printf("☁️ Shade from a cloud.\n");
}

// move animals and clouds
void update_world(){
    for(int i=0;i<NUM_RABBITS;i++){rabbits[i].x+=rand()%3-1; rabbits[i].y+=rand()%3-1;}
    for(int i=0;i<NUM_BIRDS;i++){birds[i].x+=rand()%3-1; birds[i].y+=rand()%2-1;}
    for(int i=0;i<NUM_CLOUDS;i++){clouds[i].x+=1; if(clouds[i].x>MAP_W) clouds[i].x=-5; }
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
        frame++;
        if(frame%15==0) season=(season+1)%4;
    }
    return 0;
}