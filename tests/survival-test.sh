/*
 * =========================================================
 * SISU — Survival Test
 * =========================================================
 * 
 * DENSITY:     ██████████  [10/10]
 * ENDURANCE:   ██████████  [10/10]  
 * ABSTRACTION: █████░░░░░  [5/10]
 *
 * COLOR PHASE: #16A34A (Ancient Green - Time-tested)
 *
 * Historical Context:
 *   Born from: UNIX philosophy, 1970s
 *   Survived:  Every paradigm shift since
 *   Evolves:   Never. This pattern is eternal.
 *
 * Compression Ratio: ∞:1 (Tests time itself)
 *
 * =========================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/stat.h>
#include <dirent.h>
#include <unistd.h>

// Sisu green colors (ANSI)
#define COLOR_WHISPER  "\033[38;2;240;253;244m"
#define COLOR_PRIMARY  "\033[38;2;167;243;208m"
#define COLOR_PEAK     "\033[38;2;110;231;183m"
#define COLOR_DEEP     "\033[38;2;74;222;128m"
#define COLOR_VOID     "\033[38;2;5;46;22m"
#define COLOR_RESET    "\033[0m"

// Endurance thresholds
#define MIN_AGE_DAYS      30    // Minimum age to be considered
#define ENDURANCE_YEARS   1     // Years to be considered enduring
#define ANCIENT_YEARS     5     // Years to be considered ancient
#define ETERNAL_YEARS     10    // Years to be considered eternal

// Maximum values
#define MAX_PATH          4096
#define MAX_PATTERNS      100

// Patterns that indicate endurance
const char* ETERNAL_PATTERNS[] = {
    "malloc",      // Memory management - 1970s
    "printf",      // I/O - 1970s
    "for",         // Loops - 1950s
    "if",          // Conditionals - 1950s
    "return 0",    // Success convention - 1970s
    "void",        // Type system - 1970s
    "struct",      // Data structures - 1970s
    "static",      // Scope control - 1970s
    "#include",    // Modularity - 1970s
    "const",       // Immutability - 1980s
    NULL
};

// Anti-patterns that reduce survival
const char* FRAGILE_PATTERNS[] = {
    "TODO",        // Unfinished work
    "HACK",        // Technical debt
    "FIXME",       // Known issues
    "deprecated",  // Marked for removal
    "experimental", // Not stable
    "beta",        // Not ready
    "alpha",       // Really not ready
    NULL
};

typedef struct {
    char path[MAX_PATH];
    time_t age;
    int eternal_count;
    int fragile_count;
    int lines;
    int changes;
    double survival_score;
    char* color;
} FileEndurance;

// Function to calculate file age in days
int get_file_age(const char* path) {
    struct stat st;
    if (stat(path, &st) != 0) return -1;
    
    time_t now = time(NULL);
    double seconds = difftime(now, st.st_mtime);
    return (int)(seconds / 86400); // Convert to days
}

// Function to count pattern occurrences
int count_patterns(const char* filepath, const char* patterns[]) {
    FILE* file = fopen(filepath, "r");
    if (!file) return 0;
    
    int count = 0;
    char line[1024];
    
    while (fgets(line, sizeof(line), file)) {
        for (int i = 0; patterns[i] != NULL; i++) {
            if (strstr(line, patterns[i]) != NULL) {
                count++;
            }
        }
    }
    
    fclose(file);
    return count;
}

// Function to count lines in file
int count_lines(const char* filepath) {
    FILE* file = fopen(filepath, "r");
    if (!file) return 0;
    
    int lines = 0;
    char ch;
    while ((ch = fgetc(file)) != EOF) {
        if (ch == '\n') lines++;
    }
    
    fclose(file);
    return lines;
}

// Function to get git change count (if available)
int get_change_count(const char* filepath) {
    char cmd[MAX_PATH + 100];
    snprintf(cmd, sizeof(cmd), 
             "git log --follow --oneline -- %s 2>/dev/null | wc -l", 
             filepath);
    
    FILE* pipe = popen(cmd, "r");
    if (!pipe) return 0;
    
    int changes = 0;
    fscanf(pipe, "%d", &changes);
    pclose(pipe);
    
    return changes;
}

// Function to calculate survival score
double calculate_survival_score(FileEndurance* file) {
    double score = 0.0;
    
    // Age factor (older = better)
    int age_years = file->age / 365;
    if (age_years >= ETERNAL_YEARS) {
        score += 10.0;
    } else if (age_years >= ANCIENT_YEARS) {
        score += 8.0;
    } else if (age_years >= ENDURANCE_YEARS) {
        score += 6.0;
    } else {
        score += (file->age / 365.0) * 6.0;
    }
    
    // Pattern factor (eternal patterns = better)
    double pattern_ratio = 0.0;
    if (file->eternal_count + file->fragile_count > 0) {
        pattern_ratio = (double)file->eternal_count / 
                       (file->eternal_count + file->fragile_count);
        score += pattern_ratio * 5.0;
    }
    
    // Stability factor (fewer changes = better)
    if (file->changes > 0 && file->age > 0) {
        double changes_per_year = (file->changes * 365.0) / file->age;
        if (changes_per_year < 10) {
            score += 3.0;
        } else if (changes_per_year < 50) {
            score += 2.0;
        } else if (changes_per_year < 100) {
            score += 1.0;
        }
    }
    
    // Density factor (fewer lines = better)
    if (file->lines > 0 && file->lines <= 100) {
        score += 2.0;
    } else if (file->lines <= 200) {
        score += 1.0;
    }
    
    // Normalize to 0-10 scale
    return (score > 20.0) ? 10.0 : (score / 2.0);
}

// Function to assign color based on survival score
const char* assign_color(double score) {
    if (score >= 9.0) return COLOR_PEAK;
    if (score >= 7.0) return COLOR_PRIMARY;
    if (score >= 5.0) return COLOR_DEEP;
    if (score >= 3.0) return COLOR_WHISPER;
    return COLOR_VOID;
}

// Function to test file survival
FileEndurance test_file_survival(const char* filepath) {
    FileEndurance file = {0};
    strncpy(file.path, filepath, MAX_PATH - 1);
    
    // Get file age
    file.age = get_file_age(filepath);
    if (file.age < 0) file.age = 0;
    
    // Count patterns
    file.eternal_count = count_patterns(filepath, ETERNAL_PATTERNS);
    file.fragile_count = count_patterns(filepath, FRAGILE_PATTERNS);
    
    // Get metrics
    file.lines = count_lines(filepath);
    file.changes = get_change_count(filepath);
    
    // Calculate survival score
    file.survival_score = calculate_survival_score(&file);
    file.color = (char*)assign_color(file.survival_score);
    
    return file;
}

// Function to test directory recursively
void test_directory_survival(const char* dir_path, FileEndurance* results, int* count) {
    DIR* dir = opendir(dir_path);
    if (!dir) return;
    
    struct dirent* entry;
    while ((entry = readdir(dir)) != NULL) {
        // Skip hidden files and directories
        if (entry->d_name[0] == '.') continue;
        
        char path[MAX_PATH];
        snprintf(path, sizeof(path), "%s/%s", dir_path, entry->d_name);
        
        struct stat st;
        if (stat(path, &st) != 0) continue;
        
        if (S_ISDIR(st.st_mode)) {
            // Recurse into subdirectory
            test_directory_survival(path, results, count);
        } else if (S_ISREG(st.st_mode)) {
            // Check if it's a source file
            char* ext = strrchr(entry->d_name, '.');
            if (ext && (strcmp(ext, ".c") == 0 || 
                       strcmp(ext, ".h") == 0 || 
                       strcmp(ext, ".s") == 0)) {
                
                if (*count < MAX_PATTERNS) {
                    results[(*count)++] = test_file_survival(path);
                }
            }
        }
    }
    
    closedir(dir);
}

// Function to print survival report
void print_survival_report(FileEndurance* files, int count) {
    printf("\n%s╔═══════════════════════════════════════════════════════════╗%s\n", 
           COLOR_PRIMARY, COLOR_RESET);
    printf("%s║                   SURVIVAL TEST REPORT                     ║%s\n", 
           COLOR_PRIMARY, COLOR_RESET);
    printf("%s╚═══════════════════════════════════════════════════════════╝%s\n\n", 
           COLOR_PRIMARY, COLOR_RESET);
    
    if (count == 0) {
        printf("%sNo files to test%s\n", COLOR_VOID, COLOR_RESET);
        return;
    }
    
    // Calculate statistics
    double total_score = 0.0;
    int eternal_files = 0;
    int ancient_files = 0;
    int enduring_files = 0;
    
    for (int i = 0; i < count; i++) {
        total_score += files[i].survival_score;
        int age_years = files[i].age / 365;
        
        if (age_years >= ETERNAL_YEARS) eternal_files++;
        else if (age_years >= ANCIENT_YEARS) ancient_files++;
        else if (age_years >= ENDURANCE_YEARS) enduring_files++;
    }
    
    double avg_score = total_score / count;
    
    // Print summary
    printf("%sSummary Statistics%s\n", COLOR_PRIMARY, COLOR_RESET);
    printf("%s────────────────────────────────────%s\n", COLOR_WHISPER, COLOR_RESET);
    printf("Files tested: %s%d%s\n", COLOR_PEAK, count, COLOR_RESET);
    printf("Average survival score: %s%.2f/10%s\n", COLOR_PEAK, avg_score, COLOR_RESET);
    printf("Eternal files (>%d years): %s%d%s\n", 
           ETERNAL_YEARS, COLOR_PEAK, eternal_files, COLOR_RESET);
    printf("Ancient files (>%d years): %s%d%s\n", 
           ANCIENT_YEARS, COLOR_PRIMARY, ancient_files, COLOR_RESET);
    printf("Enduring files (>%d year): %s%d%s\n", 
           ENDURANCE_YEARS, COLOR_DEEP, enduring_files, COLOR_RESET);
    
    // Print individual file results
    printf("\n%sFile Endurance Analysis%s\n", COLOR_PRIMARY, COLOR_RESET);
    printf("%s────────────────────────────────────%s\n", COLOR_WHISPER, COLOR_RESET);
    
    for (int i = 0; i < count && i < 10; i++) {  // Top 10 files
        FileEndurance* f = &files[i];
        printf("\n%s%s%s\n", f->color, f->path, COLOR_RESET);
        printf("  Age: %d days (%.1f years)\n", f->age, f->age / 365.0);
        printf("  Eternal patterns: %d | Fragile patterns: %d\n", 
               f->eternal_count, f->fragile_count);
        printf("  Lines: %d | Changes: %d\n", f->lines, f->changes);
        printf("  Survival score: %.2f/10\n", f->survival_score);
    }
    
    // Recommendations
    if (avg_score < 7.0) {
        printf("\n%s⚠ Warning: Code needs more endurance%s\n", COLOR_VOID, COLOR_RESET);
        printf("  - Remove fragile patterns (TODO, HACK, FIXME)\n");
        printf("  - Reduce file sizes below 100 lines\n");
        printf("  - Use more eternal patterns\n");
    } else {
        printf("\n%s✓ Code has good survival characteristics%s\n", COLOR_PEAK, COLOR_RESET);
    }
}

int main(int argc, char* argv[]) {
    // Get directory to test
    const char* test_dir = (argc > 1) ? argv[1] : ".";
    
    // Test survival
    FileEndurance files[MAX_PATTERNS];
    int file_count = 0;
    
    test_directory_survival(test_dir, files, &file_count);
    
    // Sort by survival score
    for (int i = 0; i < file_count - 1; i++) {
        for (int j = 0; j < file_count - i - 1; j++) {
            if (files[j].survival_score < files[j + 1].survival_score) {
                FileEndurance temp = files[j];
                files[j] = files[j + 1];
                files[j + 1] = temp;
            }
        }
    }
    
    // Print report
    print_survival_report(files, file_count);
    
    // Return success/failure based on average score
    if (file_count > 0) {
        double total = 0.0;
        for (int i = 0; i < file_count; i++) {
            total += files[i].survival_score;
        }
        double avg = total / file_count;
        
        if (avg < 5.0) {
            printf("\n%s❌ Survival test failed (avg: %.2f)%s\n", 
                   COLOR_VOID, avg, COLOR_RESET);
            return 1;
        }
    }
    
    printf("\n%s✓ Survival test complete%s\n", COLOR_PEAK, COLOR_RESET);
    return 0;  // The eternal return
}
