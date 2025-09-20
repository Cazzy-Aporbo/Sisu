/*
 * ADVANCED C MULTI-PARADIGM SHOWCASE
 * 
 * This program demonstrates various approaches to common programming concepts,
 * showcasing different implementation strategies and their tradeoffs.
 * 
 * Concepts demonstrated:
 * 1. Multiple memory allocation strategies
 * 2. Different concurrency models
 * 3. Various data structure implementations
 * 4. Algorithm optimization techniques
 * 5. Error handling approaches
 * 6. API design patterns
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <stdatomic.h>
#include <time.h>
#include <stdarg.h>
#include <assert.h>

// ==========================================================================
// 1. MEMORY ALLOCATION: MULTIPLE APPROACHES
// ==========================================================================

/*
 * Approach 1: Standard allocator - Simple but can fragment memory
 * Best for: General purpose, variable-sized allocations
 */
void* standard_alloc(size_t size) {
    void *ptr = malloc(size);
    if (!ptr) {
        fprintf(stderr, "Standard allocation failed for %zu bytes\n", size);
    }
    return ptr;
}

/*
 * Approach 2: Pool allocator - Fixed-size blocks, no fragmentation
 * Best for: Many same-sized objects, high allocation frequency
 */
typedef struct {
    void **free_list;
    size_t block_size;
    size_t capacity;
    size_t count;
} pool_allocator_t;

pool_allocator_t* pool_create(size_t block_size, size_t capacity) {
    pool_allocator_t *pool = malloc(sizeof(pool_allocator_t));
    if (!pool) return NULL;
    
    pool->free_list = malloc(capacity * sizeof(void*));
    if (!pool->free_list) {
        free(pool);
        return NULL;
    }
    
    // Pre-allocate all blocks
    for (size_t i = 0; i < capacity; i++) {
        pool->free_list[i] = malloc(block_size);
        if (!pool->free_list[i]) {
            // Cleanup on failure
            for (size_t j = 0; j < i; j++) {
                free(pool->free_list[j]);
            }
            free(pool->free_list);
            free(pool);
            return NULL;
        }
    }
    
    pool->block_size = block_size;
    pool->capacity = capacity;
    pool->count = capacity;
    
    return pool;
}

void* pool_alloc(pool_allocator_t *pool) {
    if (pool->count == 0) return NULL;
    return pool->free_list[--pool->count];
}

void pool_free(pool_allocator_t *pool, void *block) {
    if (pool->count < pool->capacity) {
        pool->free_list[pool->count++] = block;
    }
}

/*
 * Approach 3: Arena allocator - Bump pointer, ultra-fast, bulk free
 * Best for: Temporary objects, scene rendering, compilers
 */
typedef struct {
    char *memory;
    size_t size;
    size_t offset;
} arena_allocator_t;

arena_allocator_t* arena_create(size_t size) {
    arena_allocator_t *arena = malloc(sizeof(arena_allocator_t));
    if (!arena) return NULL;
    
    arena->memory = malloc(size);
    if (!arena->memory) {
        free(arena);
        return NULL;
    }
    
    arena->size = size;
    arena->offset = 0;
    return arena;
}

void* arena_alloc(arena_allocator_t *arena, size_t size) {
    if (arena->offset + size > arena->size) return NULL;
    void *ptr = arena->memory + arena->offset;
    arena->offset += size;
    return ptr;
}

void arena_reset(arena_allocator_t *arena) {
    arena->offset = 0;
}

// ==========================================================================
// 2. CONCURRENCY: MULTIPLE MODELS
// ==========================================================================

/*
 * Approach 1: Mutex-based synchronization
 * Best for: General purpose, easier to reason about
 */
typedef struct {
    int counter;
    pthread_mutex_t mutex;
} mutex_counter_t;

void mutex_counter_init(mutex_counter_t *c) {
    c->counter = 0;
    pthread_mutex_init(&c->mutex, NULL);
}

void mutex_counter_increment(mutex_counter_t *c) {
    pthread_mutex_lock(&c->mutex);
    c->counter++;
    pthread_mutex_unlock(&c->mutex);
}

/*
 * Approach 2: Atomic operations
 * Best for: Simple counters, low contention scenarios
 */
typedef struct {
    atomic_int counter;
} atomic_counter_t;

void atomic_counter_init(atomic_counter_t *c) {
    atomic_init(&c->counter, 0);
}

void atomic_counter_increment(atomic_counter_t *c) {
    atomic_fetch_add_explicit(&c->counter, 1, memory_order_relaxed);
}

/*
 * Approach 3: Read-Copy-Update (RCU) pattern
 * Best for: Read-heavy, write-rarely scenarios
 */
typedef struct {
    int *data;
    atomic_int *reader_count;
} rcu_shared_t;

void rcu_read_lock(atomic_int *rc) {
    atomic_fetch_add_explicit(rc, 1, memory_order_acquire);
}

void rcu_read_unlock(atomic_int *rc) {
    atomic_fetch_sub_explicit(rc, 1, memory_order_release);
}

// ==========================================================================
// 3. DATA STRUCTURES: MULTIPLE IMPLEMENTATIONS
// ==========================================================================

/*
 * Approach 1: Linked list - Simple but O(n) access
 * Best for: Frequently changing data, unknown size
 */
typedef struct list_node {
    void *data;
    struct list_node *next;
} list_node_t;

list_node_t* list_append(list_node_t *head, void *data) {
    list_node_t *new_node = malloc(sizeof(list_node_t));
    if (!new_node) return head;
    
    new_node->data = data;
    new_node->next = NULL;
    
    if (!head) return new_node;
    
    list_node_t *current = head;
    while (current->next) {
        current = current->next;
    }
    current->next = new_node;
    
    return head;
}

/*
 * Approach 2: Dynamic array - O(1) access, amortized insertion
 * Best for: Random access, known or predictable size
 */
typedef struct {
    void **items;
    size_t count;
    size_t capacity;
} dynamic_array_t;

dynamic_array_t* da_create(size_t initial_capacity) {
    dynamic_array_t *da = malloc(sizeof(dynamic_array_t));
    if (!da) return NULL;
    
    da->items = malloc(initial_capacity * sizeof(void*));
    if (!da->items) {
        free(da);
        return NULL;
    }
    
    da->count = 0;
    da->capacity = initial_capacity;
    return da;
}

void da_append(dynamic_array_t *da, void *item) {
    if (da->count >= da->capacity) {
        size_t new_capacity = da->capacity * 2;
        void **new_items = realloc(da->items, new_capacity * sizeof(void*));
        if (!new_items) return;
        
        da->items = new_items;
        da->capacity = new_capacity;
    }
    
    da->items[da->count++] = item;
}

/*
 * Approach 3: Hash table - O(1) average case for insert/lookup
 * Best for: Key-value storage, dictionary operations
 */
typedef struct {
    void **buckets;
    size_t bucket_count;
    size_t item_count;
} hash_table_t;

hash_table_t* ht_create(size_t bucket_count) {
    hash_table_t *ht = malloc(sizeof(hash_table_t));
    if (!ht) return NULL;
    
    ht->buckets = calloc(bucket_count, sizeof(void*));
    if (!ht->buckets) {
        free(ht);
        return NULL;
    }
    
    ht->bucket_count = bucket_count;
    ht->item_count = 0;
    return ht;
}

// Simple hash function for demonstration
size_t ht_hash(const char *key, size_t bucket_count) {
    size_t hash = 5381;
    int c;
    
    while ((c = *key++)) {
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
    }
    
    return hash % bucket_count;
}

void ht_insert(hash_table_t *ht, const char *key, void *value) {
    size_t index = ht_hash(key, ht->bucket_count);
    
    // Simple implementation - in real code we'd handle collisions
    ht->buckets[index] = value;
    ht->item_count++;
}

// ==========================================================================
// 4. ALGORITHM OPTIMIZATION: MULTIPLE TECHNIQUES
// ==========================================================================

/*
 * Approach 1: Loop unrolling - Reduces loop overhead
 * Best for: Small, performance-critical loops
 */
int sum_array_unrolled(const int *arr, size_t size) {
    int sum = 0;
    size_t i;
    
    // Process 4 elements at a time
    for (i = 0; i + 3 < size; i += 4) {
        sum += arr[i] + arr[i+1] + arr[i+2] + arr[i+3];
    }
    
    // Process remaining elements
    for (; i < size; i++) {
        sum += arr[i];
    }
    
    return sum;
}

/*
 * Approach 2: Cache blocking - Improves cache locality
 * Best for: Large data sets, matrix operations
 */
void matrix_multiply_blocked(const double *a, const double *b, double *c,
                            size_t n, size_t block_size) {
    for (size_t i = 0; i < n; i += block_size) {
        for (size_t j = 0; j < n; j += block_size) {
            for (size_t k = 0; k < n; k += block_size) {
                // Process block
                for (size_t ii = i; ii < i + block_size && ii < n; ii++) {
                    for (size_t jj = j; jj < j + block_size && jj < n; jj++) {
                        double sum = 0.0;
                        for (size_t kk = k; kk < k + block_size && kk < n; kk++) {
                            sum += a[ii * n + kk] * b[kk * n + jj];
                        }
                        c[ii * n + jj] += sum;
                    }
                }
            }
        }
    }
}

/*
 * Approach 3: Memoization - Caches expensive computations
 * Best for: Recursive algorithms with overlapping subproblems
 */
unsigned long long fibonacci_memoized(unsigned n, unsigned long long *cache) {
    if (n == 0) return 0;
    if (n == 1) return 1;
    
    if (cache[n] != 0) {
        return cache[n];
    }
    
    cache[n] = fibonacci_memoized(n - 1, cache) + fibonacci_memoized(n - 2, cache);
    return cache[n];
}

// ==========================================================================
// 5. ERROR HANDLING: MULTIPLE APPROACHES
// ==========================================================================

/*
 * Approach 1: Return codes - Simple, explicit control flow
 * Best for: Libraries, systems where exceptions are unavailable
 */
typedef enum {
    ERROR_NONE = 0,
    ERROR_INVALID_ARGUMENT,
    ERROR_ALLOCATION_FAILED,
    ERROR_IO_FAILURE,
    // ... other error codes
} error_code_t;

error_code_t process_data(const char *input, char **output) {
    if (!input) return ERROR_INVALID_ARGUMENT;
    
    *output = malloc(strlen(input) + 1);
    if (!*output) return ERROR_ALLOCATION_FAILED;
    
    strcpy(*output, input);
    return ERROR_NONE;
}

/*
 * Approach 2: Error callback - Centralized error handling
 * Best for: Applications with consistent error reporting
 */
typedef void (*error_callback_t)(const char *message, void *user_data);

void set_error_callback(error_callback_t callback, void *user_data) {
    // In a real implementation, this would store the callback globally
}

void process_with_callback(const char *input, error_callback_t on_error) {
    if (!input) {
        on_error("Invalid input", NULL);
        return;
    }
    
    // Process input
    printf("Processing: %s\n", input);
}

/*
 * Approach 3: Error struct with context - Rich error information
 * Best for: Complex systems needing detailed error diagnostics
 */
typedef struct {
    error_code_t code;
    const char *message;
    const char *file;
    int line;
    const char *function;
} error_info_t;

error_info_t create_error(error_code_t code, const char *message,
                         const char *file, int line, const char *function) {
    return (error_info_t){
        .code = code,
        .message = message,
        .file = file,
        .line = line,
        .function = function
    };
}

#define ERROR(code, msg) create_error(code, msg, __FILE__, __LINE__, __func__)

// ==========================================================================
// 6. API DESIGN: MULTIPLE PATTERNS
// ==========================================================================

/*
 * Approach 1: Opaque pointers - Information hiding, implementation flexibility
 * Best for: Public APIs, library interfaces
 */
typedef struct context context_t;

context_t* context_create();
void context_destroy(context_t *ctx);
int context_do_something(context_t *ctx, int param);

/*
 * Approach 2: Builder pattern - Fluent interface for complex object creation
 * Best for: Objects with many configuration options
 */
typedef struct {
    int option1;
    char *option2;
    double option3;
} complex_object_t;

typedef struct {
    complex_object_t obj;
} complex_object_builder_t;

complex_object_builder_t* builder_new() {
    return calloc(1, sizeof(complex_object_builder_t));
}

complex_object_builder_t* builder_set_option1(complex_object_builder_t *b, int value) {
    b->obj.option1 = value;
    return b;
}

complex_object_builder_t* builder_set_option2(complex_object_builder_t *b, const char *value) {
    b->obj.option2 = strdup(value);
    return b;
}

complex_object_t* builder_build(complex_object_builder_t *b) {
    complex_object_t *result = malloc(sizeof(complex_object_t));
    if (result) {
        *result = b->obj;
        // Reset the builder for potential reuse
        b->obj.option2 = NULL;
    }
    free(b);
    return result;
}

/*
 * Approach 3: Strategy pattern - Runtime algorithm selection
 * Best for: Systems needing flexible behavior
 */
typedef struct {
    int (*algorithm)(int a, int b);
} strategy_t;

int algorithm_add(int a, int b) { return a + b; }
int algorithm_multiply(int a, int b) { return a * b; }

int execute_strategy(strategy_t *strategy, int a, int b) {
    return strategy->algorithm(a, b);
}

// ==========================================================================
// DEMONSTRATION CODE
// ==========================================================================

int main() {
    printf("=== C MULTI-PARADIGM IMPLEMENTATION SHOWCASE ===\n\n");
    
    // 1. Memory allocation demonstration
    printf("1. Memory Allocation Strategies:\n");
    
    // Standard allocation
    int *std_alloc = standard_alloc(sizeof(int) * 10);
    printf("   Standard alloc: %p\n", (void*)std_alloc);
    free(std_alloc);
    
    // Pool allocation
    pool_allocator_t *pool = pool_create(sizeof(int), 10);
    int *pool_alloc = pool_alloc(pool);
    printf("   Pool alloc: %p\n", (void*)pool_alloc);
    pool_free(pool, pool_alloc);
    
    // Arena allocation
    arena_allocator_t *arena = arena_create(1024);
    int *arena_alloc = arena_alloc(arena, sizeof(int) * 10);
    printf("   Arena alloc: %p\n", (void*)arena_alloc);
    
    // 2. Concurrency demonstration
    printf("\n2. Concurrency Models:\n");
    
    atomic_counter_t atomic_cnt;
    atomic_counter_init(&atomic_cnt);
    atomic_counter_increment(&atomic_cnt);
    printf("   Atomic counter: %d\n", atomic_load(&atomic_cnt.counter));
    
    // 3. Data structures demonstration
    printf("\n3. Data Structures:\n");
    
    // Linked list
    list_node_t *list = NULL;
    int data1 = 42, data2 = 84;
    list = list_append(list, &data1);
    list = list_append(list, &data2);
    printf("   Linked list length: 2 (hardcoded for demo)\n");
    
    // Dynamic array
    dynamic_array_t *da = da_create(2);
    da_append(da, &data1);
    da_append(da, &data2);
    printf("   Dynamic array count: %zu\n", da->count);
    
    // Hash table
    hash_table_t *ht = ht_create(10);
    ht_insert(ht, "key1", &data1);
    ht_insert(ht, "key2", &data2);
    printf("   Hash table items: %zu\n", ht->item_count);
    
    // 4. Algorithm optimization demonstration
    printf("\n4. Algorithm Optimization:\n");
    
    int arr[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int sum = sum_array_unrolled(arr, 10);
    printf("   Unrolled sum: %d\n", sum);
    
    // 5. Error handling demonstration
    printf("\n5. Error Handling:\n");
    
    char *output;
    error_code_t err = process_data("test", &output);
    printf("   Error code: %d\n", err);
    free(output);
    
    // 6. API design demonstration
    printf("\n6. API Design Patterns:\n");
    
    complex_object_t *obj = builder_new()
        ->builder_set_option1(builder_new(), 42)
        ->builder_set_option2(builder_new(), "test")
        ->builder_build;
    printf("   Builder pattern: option1=%d\n", obj->option1);
    free(obj->option2);
    free(obj);
    
    printf("\n=== DEMONSTRATION COMPLETE ===\n");
    
    // Cleanup
    // (In a real application, we'd properly free all allocated resources)
    
    return 0;
}