#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <SDL2/SDL.h>

#define PI 3.14159265358979323846
#define WIDTH 1200
#define HEIGHT 800
#define MAX_DIM 4
#define MAX_VERTS 16
#define MAX_EDGES 32

// Structure for 4D points
typedef struct {
    double x, y, z, w;
} Point4D;

// Structure for 4D vectors
typedef struct {
    double components[MAX_DIM];
} Vector4D;

// Structure for 4D rotation matrices
typedef struct {
    double matrix[MAX_DIM][MAX_DIM];
} Matrix4D;

// Structure for hypercube
typedef struct {
    Point4D vertices[MAX_VERTS];
    int edges[MAX_EDGES][2];
    int num_edges;
} Hypercube;

// Global variables
SDL_Window* window = NULL;
SDL_Renderer* renderer = NULL;
int running = 1;
Hypercube tesseract;
double angle_xy = 0, angle_xz = 0, angle_xw = 0, angle_yz = 0, angle_yw = 0, angle_zw = 0;
int selected_dimension = 3; // Default to 4D visualization

// Function declarations
void init_sdl();
void cleanup();
void init_tesseract();
Point4D project_4d_to_3d(Point4D point);
SDL_Point project_3d_to_2d(Point4D point);
void rotate_tesseract();
void draw_tesseract();
void draw_ui();
void handle_input();
Vector4D create_4d_vector(double x, double y, double z, double w);
double dot_product_4d(Vector4D a, Vector4D b);
Matrix4D create_rotation_matrix(int plane1, int plane2, double angle);
Point4D apply_rotation(Point4D point, Matrix4D rotation);
void color_from_dimension(int dim, Uint8* r, Uint8* g, Uint8* b);
void draw_string(const char* text, int x, int y, SDL_Color color);

int main(int argc, char* argv[]) {
    init_sdl();
    init_tesseract();
    
    // Main loop
    while (running) {
        handle_input();
        rotate_tesseract();
        
        // Clear screen
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);
        
        // Draw the tesseract
        draw_tesseract();
        
        // Draw UI
        draw_ui();
        
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
    
    window = SDL_CreateWindow("Dimensional Explorer", SDL_WINDOWPOS_UNDEFINED, 
                             SDL_WINDOWPOS_UNDEFINED, WIDTH, HEIGHT, SDL_WINDOW_SHOWN);
    if (window == NULL) {
        printf("Window could not be created! SDL_Error: %s\n", SDL_GetError());
        exit(1);
    }
    
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (renderer == NULL) {
        printf("Renderer could not be created! SDL_Error: %s\n", SDL_GetError());
        exit(1);
    }
    
    printf("Dimensional Explorer initialized successfully!\n");
    printf("Use arrow keys to rotate in different planes\n");
    printf("Press 1-4 to select different dimensional perspectives\n");
    printf("Press ESC to quit\n");
}

void cleanup() {
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

void init_tesseract() {
    // Create vertices for a 4D hypercube (tesseract)
    int index = 0;
    for (int x = -1; x <= 1; x += 2) {
        for (int y = -1; y <= 1; y += 2) {
            for (int z = -1; z <= 1; z += 2) {
                for (int w = -1; w <= 1; w += 2) {
                    tesseract.vertices[index].x = x;
                    tesseract.vertices[index].y = y;
                    tesseract.vertices[index].z = z;
                    tesseract.vertices[index].w = w;
                    index++;
                }
            }
        }
    }
    
    // Create edges for the tesseract
    tesseract.num_edges = 0;
    for (int i = 0; i < MAX_VERTS; i++) {
        for (int j = i + 1; j < MAX_VERTS; j++) {
            int diff = 0;
            if (tesseract.vertices[i].x != tesseract.vertices[j].x) diff++;
            if (tesseract.vertices[i].y != tesseract.vertices[j].y) diff++;
            if (tesseract.vertices[i].z != tesseract.vertices[j].z) diff++;
            if (tesseract.vertices[i].w != tesseract.vertices[j].w) diff++;
            
            if (diff == 1) {
                tesseract.edges[tesseract.num_edges][0] = i;
                tesseract.edges[tesseract.num_edges][1] = j;
                tesseract.num_edges++;
            }
        }
    }
}

Point4D project_4d_to_3d(Point4D point) {
    // Perspective projection from 4D to 3D
    double distance = 5.0;
    double w = 1.0 / (distance - point.w);
    
    Point4D result;
    result.x = point.x * w;
    result.y = point.y * w;
    result.z = point.z * w;
    result.w = 0; // Now in 3D space
    
    return result;
}

SDL_Point project_3d_to_2d(Point4D point) {
    // Perspective projection from 3D to 2D
    double distance = 5.0;
    double z = 1.0 / (distance - point.z);
    
    SDL_Point result;
    result.x = (int)(WIDTH / 2 + point.x * z * 500);
    result.y = (int)(HEIGHT / 2 + point.y * z * 500);
    
    return result;
}

void rotate_tesseract() {
    // Create rotation matrices for different planes
    Matrix4D rot_xy = create_rotation_matrix(0, 1, angle_xy);
    Matrix4D rot_xz = create_rotation_matrix(0, 2, angle_xz);
    Matrix4D rot_xw = create_rotation_matrix(0, 3, angle_xw);
    Matrix4D rot_yz = create_rotation_matrix(1, 2, angle_yz);
    Matrix4D rot_yw = create_rotation_matrix(1, 3, angle_yw);
    Matrix4D rot_zw = create_rotation_matrix(2, 3, angle_zw);
    
    // Apply rotations to all vertices
    for (int i = 0; i < MAX_VERTS; i++) {
        tesseract.vertices[i] = apply_rotation(tesseract.vertices[i], rot_xy);
        tesseract.vertices[i] = apply_rotation(tesseract.vertices[i], rot_xz);
        tesseract.vertices[i] = apply_rotation(tesseract.vertices[i], rot_xw);
        tesseract.vertices[i] = apply_rotation(tesseract.vertices[i], rot_yz);
        tesseract.vertices[i] = apply_rotation(tesseract.vertices[i], rot_yw);
        tesseract.vertices[i] = apply_rotation(tesseract.vertices[i], rot_zw);
    }
}

void draw_tesseract() {
    // Draw edges of the tesseract
    for (int i = 0; i < tesseract.num_edges; i++) {
        Point4D start_4d = tesseract.vertices[tesseract.edges[i][0]];
        Point4D end_4d = tesseract.vertices[tesseract.edges[i][1]];
        
        // Project to 3D based on selected dimension
        Point4D start_3d, end_3d;
        
        if (selected_dimension == 4) {
            // Standard 4D projection
            start_3d = project_4d_to_3d(start_4d);
            end_3d = project_4d_to_3d(end_4d);
        } else if (selected_dimension == 3) {
            // 3D projection (ignore w)
            start_3d = start_4d;
            start_3d.w = 0;
            end_3d = end_4d;
            end_3d.w = 0;
        } else if (selected_dimension == 2) {
            // 2D projection (ignore z and w)
            start_3d.x = start_4d.x;
            start_3d.y = start_4d.y;
            start_3d.z = 0;
            start_3d.w = 0;
            
            end_3d.x = end_4d.x;
            end_3d.y = end_4d.y;
            end_3d.z = 0;
            end_3d.w = 0;
        } else if (selected_dimension == 1) {
            // 1D projection (only x)
            start_3d.x = start_4d.x;
            start_3d.y = 0;
            start_3d.z = 0;
            start_3d.w = 0;
            
            end_3d.x = end_4d.x;
            end_3d.y = 0;
            end_3d.z = 0;
            end_3d.w = 0;
        }
        
        // Project to 2D for rendering
        SDL_Point start = project_3d_to_2d(start_3d);
        SDL_Point end = project_3d_to_2d(end_3d);
        
        // Determine color based on the dominant dimension
        Uint8 r, g, b;
        color_from_dimension(selected_dimension, &r, &g, &b);
        
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        SDL_RenderDrawLine(renderer, start.x, start.y, end.x, end.y);
    }
}

void draw_ui() {
    // Draw informational text
    SDL_Color white = {255, 255, 255, 255};
    SDL_Color cyan = {0, 255, 255, 255};
    SDL_Color yellow = {255, 255, 0, 255};
    
    draw_string("DIMENSIONAL EXPLORER", 20, 20, yellow);
    
    char dim_text[50];
    snprintf(dim_text, 50, "Viewing %dD projection of a 4D hypercube", selected_dimension);
    draw_string(dim_text, 20, 50, cyan);
    
    draw_string("Controls:", 20, 90, white);
    draw_string("Arrow Keys: Rotate in different planes", 20, 110, white);
    draw_string("1-4: Select dimensional view (1D-4D)", 20, 130, white);
    draw_string("ESC: Quit", 20, 150, white);
    
    // Draw dimension explanation
    const char* dim_explanations[] = {
        "1D: Linear perspective - only the X dimension is visible",
        "2D: Flatland view - X and Y dimensions create a plane",
        "3D: Our familiar world - X, Y, and Z spatial dimensions",
        "4D: Hyper-space - X, Y, Z, and W dimensions (time or spatial)"
    };
    
    for (int i = 0; i < 4; i++) {
        SDL_Color color;
        if (i+1 == selected_dimension) {
            color = (SDL_Color){255, 100, 100, 255}; // Highlight selected
        } else {
            color = (SDL_Color){180, 180, 180, 255};
        }
        draw_string(dim_explanations[i], 20, 190 + i*20, color);
    }
    
    // Draw current rotation angles
    char angle_text[100];
    snprintf(angle_text, 100, "Rotation angles: XY:%.2f XZ:%.2f XW:%.2f YZ:%.2f YW:%.2f ZW:%.2f", 
             angle_xy, angle_xz, angle_xw, angle_yz, angle_yw, angle_zw);
    draw_string(angle_text, 20, HEIGHT - 30, white);
}

void handle_input() {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT) {
            running = 0;
        } else if (event.type == SDL_KEYDOWN) {
            switch (event.key.keysym.sym) {
                case SDLK_ESCAPE:
                    running = 0;
                    break;
                case SDLK_1:
                    selected_dimension = 1;
                    break;
                case SDLK_2:
                    selected_dimension = 2;
                    break;
                case SDLK_3:
                    selected_dimension = 3;
                    break;
                case SDLK_4:
                    selected_dimension = 4;
                    break;
                case SDLK_UP:
                    angle_xy += 0.1;
                    break;
                case SDLK_DOWN:
                    angle_xy -= 0.1;
                    break;
                case SDLK_LEFT:
                    angle_xz += 0.1;
                    break;
                case SDLK_RIGHT:
                    angle_xz -= 0.1;
                    break;
                case SDLK_w:
                    angle_xw += 0.1;
                    break;
                case SDLK_s:
                    angle_xw -= 0.1;
                    break;
                case SDLK_a:
                    angle_yz += 0.1;
                    break;
                case SDLK_d:
                    angle_yz -= 0.1;
                    break;
                case SDLK_q:
                    angle_yw += 0.1;
                    break;
                case SDLK_e:
                    angle_yw -= 0.1;
                    break;
                case SDLK_z:
                    angle_zw += 0.1;
                    break;
                case SDLK_x:
                    angle_zw -= 0.1;
                    break;
            }
        }
    }
}

Vector4D create_4d_vector(double x, double y, double z, double w) {
    Vector4D vec;
    vec.components[0] = x;
    vec.components[1] = y;
    vec.components[2] = z;
    vec.components[3] = w;
    return vec;
}

double dot_product_4d(Vector4D a, Vector4D b) {
    double result = 0;
    for (int i = 0; i < MAX_DIM; i++) {
        result += a.components[i] * b.components[i];
    }
    return result;
}

Matrix4D create_rotation_matrix(int plane1, int plane2, double angle) {
    Matrix4D mat;
    
    // Initialize as identity matrix
    for (int i = 0; i < MAX_DIM; i++) {
        for (int j = 0; j < MAX_DIM; j++) {
            if (i == j) {
                mat.matrix[i][j] = 1.0;
            } else {
                mat.matrix[i][j] = 0.0;
            }
        }
    }
    
    // Set rotation values for the specified plane
    mat.matrix[plane1][plane1] = cos(angle);
    mat.matrix[plane1][plane2] = -sin(angle);
    mat.matrix[plane2][plane1] = sin(angle);
    mat.matrix[plane2][plane2] = cos(angle);
    
    return mat;
}

Point4D apply_rotation(Point4D point, Matrix4D rotation) {
    Point4D result;
    Vector4D vec = create_4d_vector(point.x, point.y, point.z, point.w);
    
    for (int i = 0; i < MAX_DIM; i++) {
        Vector4D row = create_4d_vector(
            rotation.matrix[i][0],
            rotation.matrix[i][1],
            rotation.matrix[i][2],
            rotation.matrix[i][3]
        );
        result.x = dot_product_4d(row, vec);
        result.y = dot_product_4d(row, vec);
        result.z = dot_product_4d(row, vec);
        result.w = dot_product_4d(row, vec);
    }
    
    return result;
}

void color_from_dimension(int dim, Uint8* r, Uint8* g, Uint8* b) {
    // Assign colors based on dimension for visual distinction
    switch (dim) {
        case 1:
            *r = 255; *g = 0; *b = 0; // Red
            break;
        case 2:
            *r = 0; *g = 255; *b = 0; // Green
            break;
        case 3:
            *r = 0; *g = 0; *b = 255; // Blue
            break;
        case 4:
            *r = 255; *g = 0; *b = 255; // Magenta
            break;
        default:
            *r = 255; *g = 255; *b = 255; // White
    }
}

// Simple text drawing function (simplified for this example)
void draw_string(const char* text, int x, int y, SDL_Color color) {
    // This is a simplified text drawing function
    // In a real application, you'd use SDL_ttf or texture-based text rendering
    
    // For this example, we'll just print the text to console
    // and draw a placeholder rectangle in the renderer
    printf("%s\n", text);
    
    SDL_Rect rect = {x, y, 10, 2};
    SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
    SDL_RenderFillRect(renderer, &rect);
}