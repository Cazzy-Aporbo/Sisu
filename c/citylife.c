#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define MAP_W  100
#define MAP_H  30
#define VIEW_W 40
#define VIEW_H 15

#define NUM_PEOPLE 10
#define NUM_CARS 8
#define NUM_DOGS 5
#define NUM_CATS 5
#define NUM_BIRDS 5
#define NUM_BUILDINGS 15
#define NUM_TREES 8
#define NUM_BUSES 3
#define NUM_TRAINS 2
#define NUM_CLOUDS 5

typedef struct{int x,y;} Entity;

Entity people[NUM_PEOPLE], cars[NUM_CARS], dogs[NUM_DOGS], cats[NUM_CATS], birds[NUM_BIRDS];
Entity buildings[NUM_BUILDINGS], trees[NUM_TREES], buses[NUM_BUSES], trains[NUM_TRAINS], clouds[NUM_CLOUDS];

int playerX=MAP_W/2, playerY=MAP_H/2;

// emoji sets
const char *people_emoji[5]={"🧑","🧍","🧑‍🦱","🧑‍🦰","🧑‍🦳"};
const char *cars_emoji[5]={"🚗","🚕","🚙","🚓","🛻"};
const char *dogs_emoji[3]={"🐕","🐕‍🦺","🐶"};
const char *cats_emoji[3]={"🐈","🐱","🐈‍⬛"};
const char *birds_emoji[3]={"🐦","🕊️","🦅"};
const char *buildings_emoji[5]={"🏢","🏬","🏣","🏤","🏦"};
const char *trees_emoji[3]={"🌳","🌴","🌿"};
const char *buses_emoji[2]={"🚌","🚍"};
const char *trains_emoji[2]={"🚆","🚄"};
const char *clouds_emoji[3]={"☁️","🌥️","⛅"};

// clear screen
void cls(){printf("\033[2J\033[H");}

// initialize entities
void init_world(){
    for(int i=0;i<NUM_PEOPLE;i++){people[i].x=rand()%MAP_W; people[i].y=rand()%MAP_H;}
    for(int i=0;i<NUM_CARS;i++){cars[i].x=rand()%MAP_W; cars[i].y=rand()%MAP_H;}
    for(int i=0;i<NUM_DOGS;i++){dogs[i].x=rand()%MAP_W; dogs[i].y=rand()%MAP_H;}
    for(int i=0;i<NUM_CATS;i++){cats[i].x=rand()%MAP_W; cats[i].y=rand()%MAP_H;}
    for(int i=0;i<NUM_BIRDS;i++){birds[i].x=rand()%MAP_W; birds[i].y=rand()%MAP_H/2;}
    for(int i=0;i<NUM_BUILDINGS;i++){buildings[i].x=rand()%MAP_W; buildings[i].y=rand()%MAP_H-4;}
    for(int i=0;i<NUM_TREES;i++){trees[i].x=rand()%MAP_W; trees[i].y=rand()%MAP_H-3;}
    for(int i=0;i<NUM_BUSES;i++){buses[i].x=rand()%MAP_W; buses[i].y=rand()%MAP_H;}
    for(int i=0;i<NUM_TRAINS;i++){trains[i].x=rand()%MAP_W; trains[i].y=MAP_H-1;}
    for(int i=0;i<NUM_CLOUDS;i++){clouds[i].x=rand()%MAP_W; clouds[i].y=rand()%5;}
}

// draw viewport
void draw_view(){
    cls();
    printf("Emoji City 🌆\n\n");
    for(int y=0;y<VIEW_H;y++){
        for(int x=0;x<VIEW_W;x++){
            int wx=playerX-VIEW_W/2+x;
            int wy=playerY-VIEW_H/2+y;
            char *c=" ";

            if(wx==playerX && wy==playerY)c="🧑‍🚀";
            for(int i=0;i<NUM_BUILDINGS;i++) if(buildings[i].x==wx && buildings[i].y==wy)c=buildings_emoji[rand()%5];
            for(int i=0;i<NUM_TREES;i++) if(trees[i].x==wx && trees[i].y==wy)c=trees_emoji[rand()%3];
            for(int i=0;i<NUM_PEOPLE;i++) if(people[i].x==wx && people[i].y==wy)c=people_emoji[rand()%5];
            for(int i=0;i<NUM_CARS;i++) if(cars[i].x==wx && cars[i].y==wy)c=cars_emoji[rand()%5];
            for(int i=0;i<NUM_DOGS;i++) if(dogs[i].x==wx && dogs[i].y==wy)c=dogs_emoji[rand()%3];
            for(int i=0;i<NUM_CATS;i++) if(cats[i].x==wx && cats[i].y==wy)c=cats_emoji[rand()%3];
            for(int i=0;i<NUM_BIRDS;i++) if(birds[i].x==wx && birds[i].y==wy)c=birds_emoji[rand()%3];
            for(int i=0;i<NUM_BUSES;i++) if(buses[i].x==wx && buses[i].y==wy)c=buses_emoji[rand()%2];
            for(int i=0;i<NUM_TRAINS;i++) if(trains[i].x==wx && trains[i].y==wy)c=trains_emoji[rand()%2];
            for(int i=0;i<NUM_CLOUDS;i++) if(clouds[i].x==wx && clouds[i].y==wy)c=clouds_emoji[rand()%3];

            printf("%s",c);
        }
        printf("\n");
    }
}

// interactions
void interact(){
    for(int i=0;i<NUM_PEOPLE;i++) if(people[i].x==playerX && people[i].y==playerY) printf("🧑 A pedestrian waves!\n");
    for(int i=0;i<NUM_CARS;i++) if(cars[i].x==playerX && cars[i].y==playerY) printf("🚗 A car honks as it passes!\n");
    for(int i=0;i<NUM_DOGS;i++) if(dogs[i].x==playerX && dogs[i].y==playerY) printf("🐕 A dog barks happily!\n");
    for(int i=0;i<NUM_CATS;i++) if(cats[i].x==playerX && cats[i].y==playerY) printf("🐈 A cat crosses your path!\n");
    for(int i=0;i<NUM_BIRDS;i++) if(birds[i].x==playerX && birds[i].y==playerY) printf("🐦 A bird flies above!\n");
    for(int i=0;i<NUM_TREES;i++) if(trees[i].x==playerX && trees[i].y==playerY) printf("🌳 The tree shades you.\n");
    for(int i=0;i<NUM_BUILDINGS;i++) if(buildings[i].x==playerX && buildings[i].y==playerY) printf("🏢 You admire the building.\n");
    for(int i=0;i<NUM_BUSES;i++) if(buses[i].x==playerX && buses[i].y==playerY) printf("🚌 The bus stops nearby.\n");
    for(int i=0;i<NUM_TRAINS;i++) if(trains[i].x==playerX && trains[i].y==playerY) printf("🚆 The train speeds past.\n");
    for(int i=0;i<NUM_CLOUDS;i++) if(clouds[i].x==playerX && clouds[i].y==playerY) printf("☁️ Clouds drift above.\n");
}

// update entities
void update_world(){
    for(int i=0;i<NUM_PEOPLE;i++){people[i].x+=rand()%3-1; people[i].y+=rand()%3-1;}
    for(int i=0;i<NUM_CARS;i++){cars[i].x+=1; if(cars[i].x>MAP_W) cars[i].x=0;}
    for(int i=0;i<NUM_DOGS;i++){dogs[i].x+=rand()%3-1;}
    for(int i=0;i<NUM_CATS;i++){cats[i].x+=rand()%3-1;}
    for(int i=0;i<NUM_BIRDS;i++){birds[i].x+=rand()%3-1; birds[i].y+=rand()%3-1;}
    for(int i=0;i<NUM_BUSES;i++){buses[i].x+=1; if(buses[i].x>MAP_W) buses[i].x=0;}
    for(int i=0;i<NUM_TRAINS;i++){trains[i].x+=1; if(trains[i].x>MAP_W) trains[i].x=0;}
    for(int i=0;i<NUM_CLOUDS;i++){clouds[i].x+=1; if(clouds[i].x>MAP_W) clouds[i].x=0;}
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
        usleep(200000); // slows loop for visibility
    }
    return 0;
}