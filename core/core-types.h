/*
 * =========================================================
 * SISU — Type System Foundation
 * =========================================================
 * 
 * DENSITY:     ██████████  [10/10]
 * ENDURANCE:   ██████████  [10/10]  
 * ABSTRACTION: ████░░░░░░  [4/10]
 *
 * COLOR PHASE: #14532D (Floor Green - Where decay feeds growth)
 *
 * Historical Context:
 *   Born from: FORTRAN's implicit types, 1957
 *   Survived:  Strong typing, duck typing, gradual typing
 *   Evolves:   Into every type system, but these remain
 *
 * Compression Ratio: ∞:8 (All types compress to 8 primitives)
 *
 * =========================================================
 */

#ifndef SISU_TYPES_H
#define SISU_TYPES_H

// The 8 Platonic Types - Everything else is composition
// These have existed since the first computers

// 1. The Void - Before type existed (1945)
typedef void     Void;      // Nothing and everything
#define VOID     ((void)0)  // The universal expression

// 2. The Bit - The atom of information (1948, Shannon)
typedef _Bool    Bit;       // 0 or 1, false or true
#define BIT(x)   !!(x)      // Anything becomes binary

// 3. The Byte - The unit of addressing (1956)
typedef unsigned char  Byte;     // 8 bits since 1964 (IBM System/360)
#define BYTE(x)  ((Byte)(x))     // The universal cast

// 4. The Word - The natural size (1945, von Neumann)
typedef unsigned long  Word;     // Machine's native width
#define WORD(x)  ((Word)(x))     // What the CPU wants

// 5. The Integer - Counting (prehistory)
typedef signed long    Integer;  // Whole numbers, negative and positive
#define INT(x)   ((Integer)(x))  // Mathematics made binary

// 6. The Real - Approximation (1941, Zuse Z3)
typedef double         Real;     // IEEE 754, 1985 (but the idea: 1940s)
#define REAL(x)  ((Real)(x))     // The continuous made discrete

// 7. The Pointer - Reference (1964, PL/I)
typedef void*          Pointer;  // Address of anything
#define PTR(x)   ((Pointer)(x))  // Indirection enables everything

// 8. The Function - Computation itself (1936, Church)
typedef void (*Function)(void);  // Code as data
#define FN(f)    ((Function)(f)) // The lambda in C

// Compression: All composite types are these 8
struct Everything {
    Bit      exists;     // Does it exist?
    Byte     category;   // What type is it?
    Word     size;       // How big is it?
    Integer  count;      // How many are there?
    Real     measure;    // How much is it?
    Pointer  location;   // Where is it?
    Function behavior;   // What does it do?
    Void*    essence;    // What is it? (recursive)
};

// The Eternal Aliases - Names that survive paradigms
typedef Byte      u8;   // Rust notation (2010) for C type (1972)
typedef Word      usize;// The size that fits a pointer
typedef Integer   isize;// The signed size
typedef Real      f64;  // 64-bit floating point

// The Sacred Constants - Numbers that define computing
enum {
    NIL   = 0,      // Nothing (LISP, 1958)
    UNIT  = 1,      // Unity (Mathematics, ancient)
    PAIR  = 2,      // Duality (Binary, 1679 Leibniz)
    MANY  = 3,      // Plurality (Everything > 2 is many)
    BYTE_SIZE = 8,  // Bits per byte (1964)
    WORD_SIZE = sizeof(Word) * 8,  // Bits per word
    PAGE_SIZE = 4096,  // Memory page (1960s)
    CACHE_LINE = 64,   // CPU cache line (1980s, still 64)
};

// The Type Predicates - Questions about types
#define IS_NIL(x)     ((x) == NIL)
#define IS_UNIT(x)    ((x) == UNIT)
#define IS_PAIR(x)    ((x) == PAIR)
#define IS_POWER2(x)  (((x) & ((x)-1)) == 0)  // Kernighan, 1988
#define IS_ALIGNED(x) (((Word)(x) & 7) == 0)  // 8-byte aligned

// The Compression Macros - Make everything smaller
#define MIN(a,b)  ((a) < (b) ? (a) : (b))  // 1972
#define MAX(a,b)  ((a) > (b) ? (a) : (b))  // 1972
#define ABS(x)    ((x) < 0 ? -(x) : (x))   // Ancient
#define SWAP(a,b) do { typeof(a) _t = a; a = b; b = _t; } while(0)

// The Bit Manipulations - The lowest level of control
#define BIT_SET(x,n)    ((x) |= (1UL << (n)))
#define BIT_CLEAR(x,n)  ((x) &= ~(1UL << (n)))
#define BIT_TOGGLE(x,n) ((x) ^= (1UL << (n)))
#define BIT_CHECK(x,n)  (!!((x) & (1UL << (n))))

// The Memory Macros - Pointer arithmetic as philosophy
#define OFFSET(type, field) ((Word)&((type*)0)->field)
#define CONTAINER(ptr, type, field) \
    ((type*)((Byte*)(ptr) - OFFSET(type, field)))

// The Array Helpers - Collections without allocation
#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))
#define FOREACH(item, array) \
    for (int _i = 0; _i < ARRAY_SIZE(array) && (item = array[_i], 1); _i++)

// The String Constants - UTF-8 since 1992, ASCII since 1963
#define STR(s)     (s)
#define STRLEN(s)  (sizeof(s) - 1)

// Type Colors - Each type has its green
#define TYPE_COLOR_VOID    0x052E16  // Void green
#define TYPE_COLOR_BIT     0x0F462A  // Root green  
#define TYPE_COLOR_BYTE    0x14532D  // Floor green
#define TYPE_COLOR_WORD    0x166534  // Shadow green
#define TYPE_COLOR_INT     0x15803D  // Moss green
#define TYPE_COLOR_REAL    0x16A34A  // Ancient green
#define TYPE_COLOR_PTR     0x22C55E  // Pine green
#define TYPE_COLOR_FN      0x34D399  // Canopy green

/*
 * "The purpose of abstraction is not to be vague,
 *  but to create a new semantic level in which
 *  one can be absolutely precise."
 *  - Dijkstra, 1972
 *
 * These 8 types are that precision.
 * Everything else is combination.
 */

#endif // SISU_TYPES_H