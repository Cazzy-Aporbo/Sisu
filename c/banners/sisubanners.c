#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>

// Function declarations
void generate_fractal_banner();
void generate_sisu_symbol_banner();
void generate_finnish_banner();
void generate_quantum_banner();
void generate_dimension_banner();
void print_centered(const char* text, int width);

int main() {
    printf("Sisu Repository Banner Generator\n");
    printf("================================\n\n");
    
    // Seed random number generator
    srand(time(NULL));
    
    // Generate different types of banners
    printf("1. Fractal Sisu Banner:\n");
    generate_fractal_banner();
    
    printf("\n2. Sisu Symbol Banner:\n");
    generate_sisu_symbol_banner();
    
    printf("\n3. Finnish-inspired Banner:\n");
    generate_finnish_banner();
    
    printf("\n4. Quantum Sisu Banner:\n");
    generate_quantum_banner();
    
    printf("\n5. Dimensional Sisu Banner:\n");
    generate_dimension_banner();
    
    return 0;
}

void generate_fractal_banner() {
    int width = 60;
    int height = 20;
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            // Create a fractal pattern using mathematical functions
            double fx = (x - width/2.0) / (width/4.0);
            double fy = (y - height/2.0) / (height/4.0);
            
            // Mandelbrot-like fractal pattern
            double zx = 0.0, zy = 0.0;
            int iter = 0;
            while (zx * zx + zy * zy < 4.0 && iter < 20) {
                double tmp = zx * zx - zy * zy + fx;
                zy = 2.0 * zx * zy + fy;
                zx = tmp;
                iter++;
            }
            
            if (iter == 20) {
                printf("*");
            } else {
                printf(" ");
            }
        }
        printf("\n");
    }
    
    print_centered("SISU", width);
    print_centered("Perseverance Beyond Limits", width);
}

void generate_sisu_symbol_banner() {
    int width = 60;
    int height = 20;
    
    // Create a pattern that resembles the Finnish flag with a twist
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            // Create a cross pattern (like Finnish flag)
            if (x == width/2 || y == height/2 || 
                abs(x - width/2) < 3 && abs(y - height/2) < 8 ||
                abs(y - height/2) < 3 && abs(x - width/2) < 8) {
                // Blue color for the cross (represented by #)
                printf("#");
            } else if ((x + y) % 4 == 0) {
                // White background with pattern
                printf(".");
            } else {
                printf(" ");
            }
        }
        printf("\n");
    }
    
    print_centered("SISU", width);
    print_centered("Finnish Resilience", width);
}

void generate_finnish_banner() {
    int width = 60;
    int height = 12;
    
    // Create a pattern inspired by Finnish nature and design
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            // Pine tree pattern (simplified)
            if (x >= 10 && x < 50) {
                int rel_x = x - 10;
                int rel_y = y;
                
                // Create pine tree shapes
                if ((rel_x % 8 == 0 && rel_y > 2) || 
                    (abs(rel_x % 8 - 4) < 2 && rel_y > 4) ||
                    (abs(rel_x % 8 - 4) < 3 && rel_y > 6)) {
                    printf("^");
                } else if (x % 10 == 5 && y == height - 1) {
                    printf("|");
                } else {
                    // Create a snow-like pattern
                    if (rand() % 20 == 0) {
                        printf("*");
                    } else {
                        printf(" ");
                    }
                }
            } else {
                // Create a border
                if (x == 0 || x == width - 1 || y == 0 || y == height - 1) {
                    printf("=");
                } else {
                    printf(" ");
                }
            }
        }
        printf("\n");
    }
    
    print_centered("SISU REPOSITORY", width);
    print_centered("Strength from the North", width);
}

void generate_quantum_banner() {
    int width = 60;
    int height = 16;
    
    // Create a quantum-inspired pattern with superposition symbols
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            // Create a quantum wave pattern
            double x_val = (double)x / width * 4 * M_PI;
            double y_val = (double)y / height * 2 * M_PI;
            
            double wave1 = sin(x_val + y_val);
            double wave2 = cos(x_val * 0.7 - y_val * 1.3);
            
            double value = wave1 * wave2;
            
            if (value > 0.6) {
                printf("+");
            } else if (value > 0.2) {
                printf(".");
            } else if (value < -0.6) {
                printf("o");
            } else if (value < -0.2) {
                printf("*");
            } else {
                printf(" ");
            }
        }
        printf("\n");
    }
    
    print_centered("QUANTUM SISU", width);
    print_centered("Superposition of Strength", width);
}

void generate_dimension_banner() {
    int width = 60;
    int height = 18;
    
    // Create a hyperdimensional pattern
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            // Create a 4D projection pattern
            double dx = (x - width/2.0) / (width/4.0);
            double dy = (y - height/2.0) / (height/4.0);
            
            // Tesseract-like projection
            double d = sqrt(dx*dx + dy*dy);
            double angle = atan2(dy, dx);
            
            // Multiple rotating patterns
            double pattern1 = sin(d * 4 - angle * 2);
            double pattern2 = cos(d * 3 + angle * 3);
            double pattern3 = sin(d * 5 + angle * 4);
            
            double value = (pattern1 + pattern2 + pattern3) / 3;
            
            if (value > 0.7) {
                printf("#");
            } else if (value > 0.3) {
                printf("=");
            } else if (value > 0.0) {
                printf(".");
            } else if (value > -0.3) {
                printf(" ");
            } else if (value > -0.7) {
                printf("*");
            } else {
                printf("o");
            }
        }
        printf("\n");
    }
    
    print_centered("HIGHER DIMENSION SISU", width);
    print_centered("Beyond Conventional Limits", width);
}

void print_centered(const char* text, int width) {
    int len = strlen(text);
    int padding = (width - len) / 2;
    
    for (int i = 0; i < padding; i++) {
        printf(" ");
    }
    
    printf("%s\n", text);
}