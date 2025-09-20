#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <SDL2/SDL.h>

#define WIDTH 800
#define HEIGHT 600
#define MAX_ITEMS 50
#define MAX_CUSTOMERS 10
#define MAX_DESIGNS 20
#define DAY_LENGTH 120 // seconds

typedef enum {
    CASUAL,
    FORMAL,
    SPORTS,
    PARTY,
    ACCESSORY
} ClothingType;

typedef enum {
    LOW,
    MEDIUM,
    HIGH
} PriceRange;

typedef struct {
    char name[50];
    ClothingType type;
    PriceRange price;
    int popularity;
    int stock;
    int price_value;
    SDL_Color color;
    int designed; // 0 for premade, 1 for player-designed
} ClothingItem;

typedef struct {
    int patience; // How long they'll wait
    ClothingType preferred_style;
    PriceRange budget;
    int x, y;
    int target_x, target_y;
    int state; // 0: entering, 1: browsing, 2: waiting, 3: leaving
    int desired_item;
    int satisfaction; // 0-100
    Uint32 wait_start;
    SDL_Color color;
} Customer;

typedef struct {
    char name[50];
    ClothingType type;
    SDL_Color color;
    int popularity_boost;
    int production_cost;
} FashionDesign;

typedef struct {
    int day;
    int money;
    int reputation;
    int satisfaction;
    ClothingItem inventory[MAX_ITEMS];
    int item_count;
    FashionDesign designs[MAX_DESIGNS];
    int design_count;
    Customer customers[MAX_CUSTOMERS];
    int customer_count;
    int store_layout; // 0: basic, 1: standard, 2: premium
    Uint32 day_start_time;
    int day_progress; // 0-100
} GameState;

// Global variables
SDL_Window* window = NULL;
SDL_Renderer* renderer = NULL;
GameState game;
int running = 1;
int current_screen = 0; // 0: main menu, 1: store, 2: design studio, 3: inventory

// Function declarations
void init_sdl();
void cleanup();
void init_game();
void handle_input();
void update_game();
void render_game();
void render_main_menu();
void render_store();
void render_design_studio();
void render_inventory();
void add_customer();
void update_customers();
void draw_button(int x, int y, int w, int h, const char* text, int hover);
void draw_text(const char* text, int x, int y, SDL_Color color);
void draw_item(int x, int y, ClothingItem item);
void draw_customer(int x, int y, Customer customer);
int check_button_hover(int x, int y, int w, int h);

int main(int argc, char* argv[]) {
    printf("Fashion Store Tycoon: Mobile Boutique Simulator\n");
    printf("===============================================\n");
    
    init_sdl();
    init_game();
    
    Uint32 last_time = SDL_GetTicks();
    
    // Main loop
    while (running) {
        Uint32 current_time = SDL_GetTicks();
        float dt = (current_time - last_time) / 1000.0f;
        last_time = current_time;
        
        handle_input();
        update_game();
        
        // Clear screen
        SDL_SetRenderDrawColor(renderer, 240, 240, 240, 255);
        SDL_RenderClear(renderer);
        
        // Render current screen
        switch (current_screen) {
            case 0: render_main_menu(); break;
            case 1: render_store(); break;
            case 2: render_design_studio(); break;
            case 3: render_inventory(); break;
        }
        
        // Present renderer
        SDL_RenderPresent(renderer);
        
        // Cap frame rate
        SDL_Delay(16); // ~60 FPS
    }
    
    cleanup();
    return 0;
}

void init_sdl() {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("SDL could not initialize! SDL_Error: %s\n", SDL_GetError());
        exit(1);
    }
    
    window = SDL_CreateWindow("Fashion Store Tycoon", 
                             SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 
                             WIDTH, HEIGHT, SDL_WINDOW_SHOWN);
    if (window == NULL) {
        printf("Window could not be created! SDL_Error: %s\n", SDL_GetError());
        exit(1);
    }
    
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (renderer == NULL) {
        printf("Renderer could not be created! SDL_Error: %s\n", SDL_GetError());
        exit(1);
    }
    
    // Seed random number generator
    srand(time(NULL));
}

void cleanup() {
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

void init_game() {
    game.day = 1;
    game.money = 1000;
    game.reputation = 50;
    game.satisfaction = 50;
    game.item_count = 0;
    game.design_count = 0;
    game.customer_count = 0;
    game.store_layout = 0;
    game.day_start_time = SDL_GetTicks();
    game.day_progress = 0;
    
    // Add some initial items
    ClothingItem item1 = {"T-Shirt", CASUAL, MEDIUM, 70, 10, 25, {255, 100, 100, 255}, 0};
    game.inventory[game.item_count++] = item1;
    
    ClothingItem item2 = {"Jeans", CASUAL, MEDIUM, 80, 8, 45, {100, 100, 255, 255}, 0};
    game.inventory[game.item_count++] = item2;
    
    ClothingItem item3 = {"Evening Gown", FORMAL, HIGH, 60, 3, 120, {255, 100, 255, 255}, 0};
    game.inventory[game.item_count++] = item3;
    
    ClothingItem item4 = {"Sneakers", SPORTS, MEDIUM, 90, 12, 65, {200, 200, 200, 255}, 0};
    game.inventory[game.item_count++] = item4;
    
    ClothingItem item5 = {"Necklace", ACCESSORY, LOW, 85, 15, 15, {255, 215, 0, 255}, 0};
    game.inventory[game.item_count++] = item5;
}

void handle_input() {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT) {
            running = 0;
        } else if (event.type == SDL_MOUSEBUTTONDOWN) {
            int mx, my;
            SDL_GetMouseState(&mx, &my);
            
            // Handle button clicks based on current screen
            if (current_screen == 0) { // Main menu
                if (check_button_hover(300, 200, 200, 50)) {
                    current_screen = 1; // Open store
                } else if (check_button_hover(300, 270, 200, 50)) {
                    current_screen = 2; // Design studio
                } else if (check_button_hover(300, 340, 200, 50)) {
                    current_screen = 3; // Inventory
                }
            } else if (current_screen == 1) { // Store
                if (check_button_hover(20, 20, 100, 30)) {
                    current_screen = 0; // Back to menu
                }
                
                // Check if clicking on customers
                for (int i = 0; i < game.customer_count; i++) {
                    if (game.customers[i].state == 2 && // Waiting
                        mx > game.customers[i].x - 20 && mx < game.customers[i].x + 20 &&
                        my > game.customers[i].y - 40 && my < game.customers[i].y) {
                        // Serve this customer
                        ClothingItem item = game.inventory[game.customers[i].desired_item];
                        game.money += item.price_value;
                        game.satisfaction += game.customers[i].satisfaction / 10;
                        game.reputation = fmin(100, game.reputation + 1);
                        
                        // Remove customer
                        for (int j = i; j < game.customer_count - 1; j++) {
                            game.customers[j] = game.customers[j + 1];
                        }
                        game.customer_count--;
                        break;
                    }
                }
            } else if (current_screen == 2 || current_screen == 3) {
                if (check_button_hover(20, 20, 100, 30)) {
                    current_screen = 0; // Back to menu
                }
            }
        }
    }
}

void update_game() {
    if (current_screen == 1) { // Store screen
        // Update day progress
        Uint32 current_time = SDL_GetTicks();
        game.day_progress = ((current_time - game.day_start_time) * 100) / (DAY_LENGTH * 1000);
        
        if (game.day_progress >= 100) {
            // End of day
            game.day++;
            game.day_start_time = current_time;
            game.day_progress = 0;
        }
        
        // Add customers periodically
        if (game.customer_count < MAX_CUSTOMERS && rand() % 100 < 5) {
            add_customer();
        }
        
        // Update customers
        update_customers();
    }
}

void render_game() {
    // This function is now handled by the individual render functions
}

void render_main_menu() {
    // Draw background
    SDL_SetRenderDrawColor(renderer, 255, 225, 255, 255);
    SDL_RenderClear(renderer);
    
    // Draw title
    SDL_Color title_color = {100, 50, 150, 255};
    draw_text("Fashion Store Tycoon", 250, 100, title_color);
    
    // Draw buttons
    int hover;
    
    // Open Store button
    hover = check_button_hover(300, 200, 200, 50);
    draw_button(300, 200, 200, 50, "Open Store", hover);
    
    // Design Studio button
    hover = check_button_hover(300, 270, 200, 50);
    draw_button(300, 270, 200, 50, "Design Studio", hover);
    
    // Inventory button
    hover = check_button_hover(300, 340, 200, 50);
    draw_button(300, 340, 200, 50, "Inventory", hover);
    
    // Draw stats
    char money_text[50];
    snprintf(money_text, 50, "Money: $%d", game.money);
    draw_text(money_text, 20, 20, (SDL_Color){0, 0, 0, 255});
    
    char rep_text[50];
    snprintf(rep_text, 50, "Reputation: %d/100", game.reputation);
    draw_text(rep_text, 20, 50, (SDL_Color){0, 0, 0, 255});
    
    char day_text[50];
    snprintf(day_text, 50, "Day: %d", game.day);
    draw_text(day_text, 20, 80, (SDL_Color){0, 0, 0, 255});
}

void render_store() {
    // Draw background based on store layout
    switch (game.store_layout) {
        case 0:
            SDL_SetRenderDrawColor(renderer, 255, 240, 240, 255);
            break;
        case 1:
            SDL_SetRenderDrawColor(renderer, 240, 255, 240, 255);
            break;
        case 2:
            SDL_SetRenderDrawColor(renderer, 240, 240, 255, 255);
            break;
    }
    SDL_RenderClear(renderer);
    
    // Draw back button
    int hover = check_button_hover(20, 20, 100, 30);
    draw_button(20, 20, 100, 30, "Menu", hover);
    
    // Draw store layout
    SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255);
    SDL_Rect floor_rect = {100, 200, WIDTH - 200, HEIGHT - 300};
    SDL_RenderFillRect(renderer, &floor_rect);
    
    // Draw clothing racks
    SDL_SetRenderDrawColor(renderer, 150, 100, 50, 255);
    for (int i = 0; i < 5; i++) {
        SDL_Rect rack = {150 + i * 120, 250, 80, 150};
        SDL_RenderFillRect(renderer, &rack);
        
        // Draw clothes on racks
        if (i < game.item_count) {
            draw_item(150 + i * 120 + 40, 220, game.inventory[i]);
        }
    }
    
    // Draw customers
    for (int i = 0; i < game.customer_count; i++) {
        draw_customer(game.customers[i].x, game.customers[i].y, game.customers[i]);
    }
    
    // Draw UI elements
    draw_text("STORE", WIDTH/2 - 40, 20, (SDL_Color){0, 0, 0, 255});
    
    // Draw day progress bar
    SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255);
    SDL_Rect progress_bg = {WIDTH/2 - 100, HEIGHT - 40, 200, 20};
    SDL_RenderFillRect(renderer, &progress_bg);
    
    SDL_SetRenderDrawColor(renderer, 100, 200, 100, 255);
    SDL_Rect progress_fg = {WIDTH/2 - 100, HEIGHT - 40, game.day_progress * 2, 20};
    SDL_RenderFillRect(renderer, &progress_fg);
    
    char progress_text[50];
    snprintf(progress_text, 50, "Day %d - %d%%", game.day, game.day_progress);
    draw_text(progress_text, WIDTH/2 - 40, HEIGHT - 60, (SDL_Color){0, 0, 0, 255});
}

void render_design_studio() {
    // Draw background
    SDL_SetRenderDrawColor(renderer, 240, 240, 255, 255);
    SDL_RenderClear(renderer);
    
    // Draw back button
    int hover = check_button_hover(20, 20, 100, 30);
    draw_button(20, 20, 100, 30, "Menu", hover);
    
    // Draw title
    draw_text("DESIGN STUDIO", WIDTH/2 - 80, 60, (SDL_Color){0, 0, 0, 255});
    
    // Draw design workspace
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    SDL_Rect workspace = {100, 100, WIDTH - 200, HEIGHT - 200};
    SDL_RenderFillRect(renderer, &workspace);
    SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255);
    SDL_RenderDrawRect(renderer, &workspace);
    
    // Draw design tools
    draw_text("Design new clothing items here!", 150, 120, (SDL_Color){0, 0, 0, 255});
    
    // Draw existing designs
    for (int i = 0; i < game.design_count; i++) {
        int x = 120 + (i % 4) * 150;
        int y = 160 + (i / 4) * 80;
        
        SDL_SetRenderDrawColor(renderer, 
                              game.designs[i].color.r, 
                              game.designs[i].color.g, 
                              game.designs[i].color.b, 
                              255);
        SDL_Rect design_rect = {x, y, 60, 60};
        SDL_RenderFillRect(renderer, &design_rect);
        
        draw_text(game.designs[i].name, x, y + 65, (SDL_Color){0, 0, 0, 255});
    }
    
    // Draw new design button
    hover = check_button_hover(WIDTH/2 - 75, HEIGHT - 80, 150, 40);
    draw_button(WIDTH/2 - 75, HEIGHT - 80, 150, 40, "New Design", hover);
}

void render_inventory() {
    // Draw background
    SDL_SetRenderDrawColor(renderer, 255, 255, 240, 255);
    SDL_RenderClear(renderer);
    
    // Draw back button
    int hover = check_button_hover(20, 20, 100, 30);
    draw_button(20, 20, 100, 30, "Menu", hover);
    
    // Draw title
    draw_text("INVENTORY MANAGEMENT", WIDTH/2 - 120, 60, (SDL_Color){0, 0, 0, 255});
    
    // Draw inventory items
    for (int i = 0; i < game.item_count; i++) {
        int row = i / 4;
        int col = i % 4;
        int x = 100 + col * 150;
        int y = 100 + row * 120;
        
        draw_item(x, y, game.inventory[i]);
        
        // Draw item info
        char info_text[100];
        snprintf(info_text, 100, "%s ($%d) x%d", 
                 game.inventory[i].name, 
                 game.inventory[i].price_value,
                 game.inventory[i].stock);
        draw_text(info_text, x, y + 70, (SDL_Color){0, 0, 0, 255});
        
        // Draw popularity
        char pop_text[50];
        snprintf(pop_text, 50, "Popularity: %d", game.inventory[i].popularity);
        draw_text(pop_text, x, y + 90, (SDL_Color){0, 0, 0, 255});
    }
    
    // Draw restock button
    hover = check_button_hover(WIDTH/2 - 75, HEIGHT - 80, 150, 40);
    draw_button(WIDTH/2 - 75, HEIGHT - 80, 150, 40, "Restock Items", hover);
}

void add_customer() {
    if (game.customer_count >= MAX_CUSTOMERS) return;
    
    Customer customer;
    customer.patience = 5000 + rand() % 10000; // 5-15 seconds
    customer.preferred_style = rand() % 5;
    customer.budget = rand() % 3;
    customer.x = WIDTH;
    customer.y = 400;
    customer.target_x = 150 + rand() % (WIDTH - 300);
    customer.target_y = 300 + rand() % 100;
    customer.state = 0; // Entering
    customer.desired_item = rand() % game.item_count;
    customer.satisfaction = 50 + rand() % 50;
    customer.wait_start = 0;
    
    // Assign a random color to the customer
    customer.color.r = 100 + rand() % 155;
    customer.color.g = 100 + rand() % 155;
    customer.color.b = 100 + rand() % 155;
    customer.color.a = 255;
    
    game.customers[game.customer_count++] = customer;
}

void update_customers() {
    for (int i = 0; i < game.customer_count; i++) {
        Customer *c = &game.customers[i];
        
        if (c->state == 0) { // Entering
            // Move toward target
            if (c->x > c->target_x) c->x -= 2;
            if (c->y > c->target_y) c->y -= 1;
            if (c->y < c->target_y) c->y += 1;
            
            // Check if reached target
            if (abs(c->x - c->target_x) < 5 && abs(c->y - c->target_y) < 5) {
                c->state = 1; // Start browsing
                c->wait_start = SDL_GetTicks();
            }
        } else if (c->state == 1) { // Browsing
            // After some time, decide to wait for service
            if (SDL_GetTicks() - c->wait_start > 2000 + rand() % 3000) {
                c->state = 2; // Waiting for service
                c->wait_start = SDL_GetTicks();
            }
        } else if (c->state == 2) { // Waiting for service
            // Check if patience runs out
            if (SDL_GetTicks() - c->wait_start > c->patience) {
                c->state = 3; // Leaving
                c->target_x = WIDTH + 50;
                game.satisfaction -= 5;
                game.reputation = fmax(0, game.reputation - 2);
            }
        } else if (c->state == 3) { // Leaving
            // Move toward exit
            c->x += 3;
            
            // Remove if off screen
            if (c->x > WIDTH + 50) {
                for (int j = i; j < game.customer_count - 1; j++) {
                    game.customers[j] = game.customers[j + 1];
                }
                game.customer_count--;
                i--;
            }
        }
    }
}

void draw_button(int x, int y, int w, int h, const char* text, int hover) {
    // Draw button background
    if (hover) {
        SDL_SetRenderDrawColor(renderer, 100, 150, 255, 255);
    } else {
        SDL_SetRenderDrawColor(renderer, 70, 130, 230, 255);
    }
    SDL_Rect button_rect = {x, y, w, h};
    SDL_RenderFillRect(renderer, &button_rect);
    
    // Draw button border
    SDL_SetRenderDrawColor(renderer, 50, 100, 200, 255);
    SDL_RenderDrawRect(renderer, &button_rect);
    
    // Draw button text
    draw_text(text, x + w/2 - strlen(text)*4, y + h/2 - 8, (SDL_Color){255, 255, 255, 255});
}

void draw_text(const char* text, int x, int y, SDL_Color color) {
    // This is a simplified text drawing function
    // In a real implementation, you would use SDL_ttf or texture-based rendering
    
    // For this example, we'll just print to console and draw a simple representation
    printf("UI: %s\n", text);
    
    SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
    
    // Draw a simple line to represent text
    SDL_Rect text_rect = {x, y, strlen(text) * 8, 2};
    SDL_RenderFillRect(renderer, &text_rect);
}

void draw_item(int x, int y, ClothingItem item) {
    // Draw a simple representation of a clothing item
    SDL_SetRenderDrawColor(renderer, item.color.r, item.color.g, item.color.b, 255);
    
    // Different shapes for different clothing types
    switch (item.type) {
        case CASUAL:
            // T-shirt shape
            SDL_Rect shirt = {x - 15, y - 10, 30, 30};
            SDL_RenderFillRect(renderer, &shirt);
            break;
        case FORMAL:
            // Dress shape (triangle)
            SDL_RenderDrawLine(renderer, x, y - 20, x - 15, y + 10);
            SDL_RenderDrawLine(renderer, x, y - 20, x + 15, y + 10);
            SDL_RenderDrawLine(renderer, x - 15, y + 10, x + 15, y + 10);
            break;
        case SPORTS:
            // Sneaker shape (ellipse approximation)
            for (int i = -10; i <= 10; i++) {
                SDL_RenderDrawLine(renderer, x + i, y - 5, x + i, y + 5);
            }
            break;
        case PARTY:
            // Sparkly shape (star)
            SDL_RenderDrawLine(renderer, x, y - 10, x, y + 10);
            SDL_RenderDrawLine(renderer, x - 10, y, x + 10, y);
            SDL_RenderDrawLine(renderer, x - 7, y - 7, x + 7, y + 7);
            SDL_RenderDrawLine(renderer, x - 7, y + 7, x + 7, y - 7);
            break;
        case ACCESSORY:
            // Circle for accessories
            for (int i = -8; i <= 8; i++) {
                SDL_RenderDrawLine(renderer, x + i, y - 8, x + i, y + 8);
            }
            break;
    }
}

void draw_customer(int x, int y, Customer customer) {
    // Draw customer as a simple person shape
    SDL_SetRenderDrawColor(renderer, customer.color.r, customer.color.g, customer.color.b, 255);
    
    // Head
    for (int i = -5; i <= 5; i++) {
        SDL_RenderDrawLine(renderer, x + i, y - 20, x + i, y - 10);
    }
    
    // Body
    SDL_RenderDrawLine(renderer, x, y - 10, x, y + 10);
    
    // Arms
    SDL_RenderDrawLine(renderer, x, y - 5, x - 10, y);
    SDL_RenderDrawLine(renderer, x, y - 5, x + 10, y);
    
    // Legs
    SDL_RenderDrawLine(renderer, x, y + 10, x - 8, y + 20);
    SDL_RenderDrawLine(renderer, x, y + 10, x + 8, y + 20);
    
    // Draw patience bar if waiting
    if (customer.state == 2) {
        Uint32 wait_time = SDL_GetTicks() - customer.wait_start;
        float patience_ratio = 1.0 - (float)wait_time / customer.patience;
        
        SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255);
        SDL_Rect patience_bg = {x - 15, y - 35, 30, 5};
        SDL_RenderFillRect(renderer, &patience_bg);
        
        if (patience_ratio > 0.7) {
            SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
        } else if (patience_ratio > 0.3) {
            SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255);
        } else {
            SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
        }
        
        SDL_Rect patience_fg = {x - 15, y - 35, 30 * patience_ratio, 5};
        SDL_RenderFillRect(renderer, &patience_fg);
    }
}

int check_button_hover(int x, int y, int w, int h) {
    int mx, my;
    SDL_GetMouseState(&mx, &my);
    return (mx >= x && mx <= x + w && my >= y && my <= y + h);
}