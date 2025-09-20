#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define MAP_W 100
#define MAP_H 30
#define VIEW_W 40
#define VIEW_H 15

#define NUM_PEOPLE 15
#define NUM_ANIMALS 15
#define NUM_VEHICLES 10
#define NUM_BUILDINGS 12
#define NUM_CLOUDS 6
#define NUM_SURR 5  // surreal entities

typedef struct { int x, y; } Entity;

Entity player = {MAP_W/2, MAP_H/2};
Entity people[NUM_PEOPLE], animals[NUM_ANIMALS], vehicles[NUM_VEHICLES];
Entity buildings[NUM_BUILDINGS], clouds[NUM_CLOUDS], surreal[NUM_SURR];

const char *people_emoji[5] = {"🧑","🧍","🧑‍🦱","🧑‍🦰","🧑‍🦳"};
const char *animals_emoji[5] = {"🐕","🐈","🐦","🦄","🐿️"};
const char *vehicles_emoji[5] = {"🚗","🚕","🚌","🚓","🚙"};
const char *buildings_emoji[5] = {"🏢","🏬","🏣","🏤","🏦"};
const char *clouds_emoji[3] = {"☁️","🌥️","⛅"};
const char *surreal_emoji[5] = {"🛸","💃","🌈","🪼","🌌"};

void cls(){ printf("\033[2J\033[H"); }
void color(int c){ printf("\033[38;5;%dm",c); }

int rand_range(int min,int max){ return rand()%(max-min+1)+min; }

void init_world(){
    for(int i=0;i<NUM_PEOPLE;i++){ people[i].x=rand_range(0,MAP_W-1); people[i].y=rand_range(0,MAP_H-1); }
    for(int i=0;i<NUM_ANIMALS;i++){ animals[i].x=rand_range(0,MAP_W-1); animals[i].y=rand_range(0,MAP_H-1); }
    for(int i=0;i<NUM_VEHICLES;i++){ vehicles[i].x=rand_range(0,MAP_W-1); vehicles[i].y=rand_range(0,MAP_H-1); }
    for(int i=0;i<NUM_BUILDINGS;i++){ buildings[i].x=rand_range(0,MAP_W-1); buildings[i].y=rand_range(0,MAP_H-1); }
    for(int i=0;i<NUM_CLOUDS;i++){ clouds[i].x=rand_range(0,MAP_W-1); clouds[i].y=rand_range(0,5); }
    for(int i=0;i<NUM_SURR;i++){ surreal[i].x=rand_range(0,MAP_W-1); surreal[i].y=rand_range(0,MAP_H/2); }
}

void draw_view(){
    cls();
    printf("🌆 TRIPPY HOLOGRAPHIC CITY 🌌\n\n");
    for(int y=0;y<VIEW_H;y++){
        for(int x=0;x<VIEW_W;x++){
            int wx=player.x-VIEW_W/2+x;
            int wy=player.y-VIEW_H/2+y;
            char *c="  ";
            int col=rand_range(160,231); // rainbow color

            if(wx==player.x && wy==player.y){ c="🧑‍🚀"; color(col); printf("%s",c); continue; }

            // Surreal entities (top layer)
            for(int i=0;i<NUM_SURR;i++)
                if(surreal[i].x==wx && surreal[i].y==wy){ c=(char*)surreal_emoji[rand()%5]; color(rand_range(160,231)); printf("%s",c); goto printed; }

            for(int i=0;i<NUM_BUILDINGS;i++)
                if(buildings[i].x==wx && buildings[i].y==wy){ c=(char*)buildings_emoji[rand()%5]; color(rand_range(160,231)); printf("%s",c); goto printed; }

            for(int i=0;i<NUM_PEOPLE;i++)
                if(people[i].x==wx && people[i].y==wy){ c=(char*)people_emoji[rand()%5]; color(rand_range(160,231)); printf("%s",c); goto printed; }

            for(int i=0;i<NUM_ANIMALS;i++)
                if(animals[i].x==wx && animals[i].y==wy){ c=(char*)animals_emoji[rand()%5]; color(rand_range(160,231)); printf("%s",c); goto printed; }

            for(int i=0;i<NUM_VEHICLES;i++)
                if(vehicles[i].x==wx && vehicles[i].y==wy){ c=(char*)vehicles_emoji[rand()%5]; color(rand_range(160,231)); printf("%s",c); goto printed; }

            for(int i=0;i<NUM_CLOUDS;i++)
                if(clouds[i].x==wx && clouds[i].y==wy){ c=(char*)clouds_emoji[rand()%3]; color(rand_range(160,231)); printf("%s",c); goto printed; }

            printf("  "); // empty space
            printed:
            printf("\033[0m"); // reset color
        }
        printf("\n");
    }
}

void interact(){
    for(int i=0;i<NUM_PEOPLE;i++)
        if(people[i].x==player.x && people[i].y==player.y)
            printf("🧑 A pedestrian waves in rainbow shimmer!\n");
    for(int i=0;i<NUM_ANIMALS;i++)
        if(animals[i].x==player.x && animals[i].y==player.y)
            printf("🦄 An animal glows and twirls!\n");
    for(int i=0;i<NUM_VEHICLES;i++)
        if(vehicles[i].x==player.x && vehicles[i].y==player.y)
            printf("🚗 A vehicle leaves a trail of colors!\n");
    for(int i=0;i<NUM_SURR;i++)
        if(surreal[i].x==player.x && surreal[i].y==player.y)
            printf("%s Something surreal passes by!\n",surreal_emoji[rand()%5]);
}

void update_world(){
    for(int i=0;i<NUM_PEOPLE;i++){ people[i].x+=rand_range(-1,1); people[i].y+=rand_range(-1,1); }
    for(int i=0;i<NUM_ANIMALS;i++){ animals[i].x+=rand_range(-1,1); animals[i].y+=rand_range(-1,1); }
    for(int i=0;i<NUM_VEHICLES;i++){ vehicles[i].x+=1; if(vehicles[i].x>=MAP_W) vehicles[i].x=0; }
    for(int i=0;i<NUM_SURR;i++){ surreal[i].x+=rand_range(-1,1); surreal[i].y+=rand_range(-1,1); }
    for(int i=0;i<NUM_CLOUDS;i++){ clouds[i].x+=1; if(clouds[i].x>=MAP_W) clouds[i].x=0; }
}

int main(){
    srand(time(NULL));
    init_world();
    while(1){
        draw_view();
        interact();
        printf("\nMove WASD, q to quit: ");
        char c=getchar(); getchar();
        if(c=='q') break;
        if(c=='w' && player.y>0) player.y--;
        if(c=='s' && player.y<MAP_H-1) player.y++;
        if(c=='a' && player.x>0) player.x--;
        if(c=='d' && player.x<MAP_W-1) player.x++;
        update_world();
        usleep(150000);
    }
    return 0;
}