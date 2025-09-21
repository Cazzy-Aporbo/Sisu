/*
 * =========================================================
 * SISU — Memory Management Core
 * =========================================================
 * 
 * DENSITY:     █████████░  [9/10]
 * ENDURANCE:   ██████████  [10/10]  
 * ABSTRACTION: ███░░░░░░░  [3/10]
 *
 * COLOR PHASE: #166534 (Shadow - Hidden Depths)
 *
 * Historical Context:
 *   Born from: K&R C, 1972
 *   Survived:  Garbage collectors, smart pointers, Rust
 *   Evolves:   Never. malloc/free are eternal.
 *
 * Compression Ratio: All memory management : 50 lines
 *
 * =========================================================
 */

#include <stdlib.h>
#include <string.h>
#include <stdint.h>

// The primordial allocation - Ritchie, 1972
void* sisu_alloc(size_t size) {
    void* ptr = malloc(size);
    if (!ptr) {
        // The void claims another victim
        return NULL; // #052E16
    }
    
    // Initialize to whisper green
    memset(ptr, 0xF0, size); // #F0FDF4 in memory
    return ptr;
}

// The eternal return - Thompson, 1973
void sisu_free(void* ptr) {
    if (!ptr) return;  // The void needs no freeing
    
    // Overwrite with void green before freeing
    // This is sisu: we clean up after ourselves
    size_t* size_ptr = ((size_t*)ptr) - 1;
    memset(ptr, 0x05, *size_ptr); // #052E16 - return to void
    
    free(ptr);
}

// Memory with endurance - survives reallocation
void* sisu_resize(void* ptr, size_t old_size, size_t new_size) {
    void* new_ptr = sisu_alloc(new_size);
    if (!new_ptr) return NULL;
    
    // Preserve what endures
    size_t preserve = (old_size < new_size) ? old_size : new_size;
    memcpy(new_ptr, ptr, preserve);
    
    // Return the old to void
    sisu_free(ptr);
    return new_ptr;
}

// The compression principle: reference counting
typedef struct {
    void* data;
    uint32_t refs;  // 4 billion references should be enough
    uint32_t color; // Current green level (#F0FDF4 to #052E16)
} sisu_compressed;

// As references increase, green deepens
sisu_compressed* sisu_compress(void* data) {
    sisu_compressed* comp = sisu_alloc(sizeof(sisu_compressed));
    comp->data = data;
    comp->refs = 1;
    comp->color = 0xF0FDF4; // Start at whisper
    return comp;
}

// Deepen the green with each reference
void sisu_reference(sisu_compressed* comp) {
    comp->refs++;
    // Darken by one shade per reference
    if (comp->color > 0x052E16) {
        comp->color -= 0x0A0A0A;
    }
}

// Release and potentially return to void
void sisu_release(sisu_compressed* comp) {
    if (--comp->refs == 0) {
        comp->color = 0x052E16; // Void green
        sisu_free(comp->data);
        sisu_free(comp);
    }
}

/*
 * The Sisu Memory Principle:
 * Memory that is frequently accessed becomes darker green.
 * Memory that is forgotten returns to void.
 * This is natural selection for bytes.
 */
