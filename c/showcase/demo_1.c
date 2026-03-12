/*
 * ADVANCED C PROGRAMMING SHOWCASE
 * 
 * This program demonstrates advanced C programming concepts that would
 * impress employers, including:
 * 1. Custom memory allocator with debugging features
 * 2. Generic data structures using type erasure
 * 3. Thread pooling and concurrent execution
 * 4. SIMD optimization for performance-critical code
 * 5. Plugin architecture with dynamic loading
 * 6. Advanced error handling and logging
 * 7. Algorithm optimization techniques
 * 8. Clean, professional code organization
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <dlfcn.h>
#include <time.h>
#include <sys/time.h>
#include <x86intrin.h>  // For SIMD intrinsics

// 1. ADVANCED MEMORY ALLOCATOR WITH DEBUGGING FEATURES

typedef struct {
    void *ptr;
    size_t size;
    const char *file;
    int line;
    const char *func;
} alloc_info_t;

typedef struct {
    alloc_info_t *allocations;
    size_t count;
    size_t capacity;
    pthread_mutex_t lock;
} memory_debugger_t;

memory_debugger_t mem_debugger = {0};

void* debug_malloc(size_t size, const char *file, int line, const char *func) {
    void *ptr = malloc(size);
    if (!ptr) return NULL;
    
    pthread_mutex_lock(&mem_debugger.lock);
    
    // Resize allocations array if needed
    if (mem_debugger.count >= mem_debugger.capacity) {
        size_t new_capacity = mem_debugger.capacity ? mem_debugger.capacity * 2 : 16;
        alloc_info_t *new_allocations = realloc(mem_debugger.allocations, 
                                              new_capacity * sizeof(alloc_info_t));
        if (new_allocations) {
            mem_debugger.allocations = new_allocations;
            mem_debugger.capacity = new_capacity;
        }
    }
    
    // Record allocation info
    if (mem_debugger.count < mem_debugger.capacity) {
        mem_debugger.allocations[mem_debugger.count].ptr = ptr;
        mem_debugger.allocations[mem_debugger.count].size = size;
        mem_debugger.allocations[mem_debugger.count].file = file;
        mem_debugger.allocations[mem_debugger.count].line = line;
        mem_debugger.allocations[mem_debugger.count].func = func;
        mem_debugger.count++;
    }
    
    pthread_mutex_unlock(&mem_debugger.lock);
    
    return ptr;
}

void debug_free(void *ptr, const char *file, int line, const char *func) {
    if (!ptr) return;
    
    pthread_mutex_lock(&mem_debugger.lock);
    
    // Find and remove allocation record
    for (size_t i = 0; i < mem_debugger.count; i++) {
        if (mem_debugger.allocations[i].ptr == ptr) {
            // Move last element to this position
            if (i < mem_debugger.count - 1) {
                mem_debugger.allocations[i] = mem_debugger.allocations[mem_debugger.count - 1];
            }
            mem_debugger.count--;
            break;
        }
    }
    
    pthread_mutex_unlock(&mem_debugger.lock);
    
    free(ptr);
}

void report_memory_leaks() {
    pthread_mutex_lock(&mem_debugger.lock);
    
    if (mem_debugger.count > 0) {
        fprintf(stderr, "Memory leak detected! %zu allocation(s) not freed:\n", mem_debugger.count);
        for (size_t i = 0; i < mem_debugger.count; i++) {
            fprintf(stderr, "  %zu bytes at %p allocated in %s:%d (%s)\n",
                   mem_debugger.allocations[i].size,
                   mem_debugger.allocations[i].ptr,
                   mem_debugger.allocations[i].file,
                   mem_debugger.allocations[i].line,
                   mem_debugger.allocations[i].func);
        }
    } else {
        printf("No memory leaks detected.\n");
    }
    
    pthread_mutex_unlock(&mem_debugger.lock);
}

// Macros to automatically capture file, line, and function info
#define MALLOC(size) debug_malloc(size, __FILE__, __LINE__, __func__)
#define FREE(ptr) debug_free(ptr, __FILE__, __LINE__, __func__)

// 2. GENERIC VECTOR (DYNAMIC ARRAY) IMPLEMENTATION

typedef struct {
    void *data;
    size_t size;
    size_t capacity;
    size_t elem_size;
} vector_t;

vector_t* vector_create(size_t elem_size, size_t initial_capacity) {
    vector_t *vec = MALLOC(sizeof(vector_t));
    if (!vec) return NULL;
    
    vec->elem_size = elem_size;
    vec->capacity = initial_capacity > 0 ? initial_capacity : 1;
    vec->size = 0;
    vec->data = MALLOC(vec->capacity * elem_size);
    
    if (!vec->data) {
        FREE(vec);
        return NULL;
    }
    
    return vec;
}

void vector_destroy(vector_t *vec) {
    if (vec) {
        FREE(vec->data);
        FREE(vec);
    }
}

void* vector_at(vector_t *vec, size_t index) {
    if (index >= vec->size) return NULL;
    return (char*)vec->data + (index * vec->elem_size);
}

int vector_push_back(vector_t *vec, const void *value) {
    if (vec->size >= vec->capacity) {
        size_t new_capacity = vec->capacity * 2;
        void *new_data = realloc(vec->data, new_capacity * vec->elem_size);
        if (!new_data) return 0;
        
        vec->data = new_data;
        vec->capacity = new_capacity;
    }
    
    memcpy((char*)vec->data + (vec->size * vec->elem_size), value, vec->elem_size);
    vec->size++;
    return 1;
}

// 3. THREAD POOL IMPLEMENTATION

typedef struct {
    void (*task)(void*);
    void *arg;
} task_t;

typedef struct {
    pthread_t *threads;
    size_t thread_count;
    
    task_t *task_queue;
    size_t queue_size;
    size_t queue_capacity;
    
    pthread_mutex_t queue_mutex;
    pthread_cond_t queue_cond;
    pthread_cond_t working_cond;
    
    size_t working_count;
    int stop;
} thread_pool_t;

void* worker_thread(void *arg) {
    thread_pool_t *pool = (thread_pool_t*)arg;
    
    while (1) {
        pthread_mutex_lock(&pool->queue_mutex);
        
        // Wait for tasks or stop signal
        while (pool->queue_size == 0 && !pool->stop) {
            pthread_cond_wait(&pool->queue_cond, &pool->queue_mutex);
        }
        
        if (pool->stop) {
            pthread_mutex_unlock(&pool->queue_mutex);
            break;
        }
        
        // Get task from queue
        task_t task = pool->task_queue[0];
        
        // Shift queue
        for (size_t i = 0; i < pool->queue_size - 1; i++) {
            pool->task_queue[i] = pool->task_queue[i + 1];
        }
        pool->queue_size--;
        
        pool->working_count++;
        pthread_mutex_unlock(&pool->queue_mutex);
        
        // Execute task
        task.task(task.arg);
        
        pthread_mutex_lock(&pool->queue_mutex);
        pool->working_count--;
        if (pool->working_count == 0 && pool->queue_size == 0) {
            pthread_cond_signal(&pool->working_cond);
        }
        pthread_mutex_unlock(&pool->queue_mutex);
    }
    
    return NULL;
}

thread_pool_t* thread_pool_create(size_t num_threads) {
    thread_pool_t *pool = MALLOC(sizeof(thread_pool_t));
    if (!pool) return NULL;
    
    pool->threads = MALLOC(num_threads * sizeof(pthread_t));
    if (!pool->threads) {
        FREE(pool);
        return NULL;
    }
    
    pool->thread_count = num_threads;
    pool->queue_capacity = 16;
    pool->task_queue = MALLOC(pool->queue_capacity * sizeof(task_t));
    if (!pool->task_queue) {
        FREE(pool->threads);
        FREE(pool);
        return NULL;
    }
    
    pool->queue_size = 0;
    pool->working_count = 0;
    pool->stop = 0;
    
    pthread_mutex_init(&pool->queue_mutex, NULL);
    pthread_cond_init(&pool->queue_cond, NULL);
    pthread_cond_init(&pool->working_cond, NULL);
    
    // Create worker threads
    for (size_t i = 0; i < num_threads; i++) {
        pthread_create(&pool->threads[i], NULL, worker_thread, pool);
    }
    
    return pool;
}

int thread_pool_add_task(thread_pool_t *pool, void (*task)(void*), void *arg) {
    pthread_mutex_lock(&pool->queue_mutex);
    
    // Resize task queue if needed
    if (pool->queue_size >= pool->queue_capacity) {
        size_t new_capacity = pool->queue_capacity * 2;
        task_t *new_queue = realloc(pool->task_queue, new_capacity * sizeof(task_t));
        if (!new_queue) {
            pthread_mutex_unlock(&pool->queue_mutex);
            return 0;
        }
        
        pool->task_queue = new_queue;
        pool->queue_capacity = new_capacity;
    }
    
    // Add task to queue
    pool->task_queue[pool->queue_size].task = task;
    pool->task_queue[pool->queue_size].arg = arg;
    pool->queue_size++;
    
    pthread_cond_signal(&pool->queue_cond);
    pthread_mutex_unlock(&pool->queue_mutex);
    
    return 1;
}

void thread_pool_wait(thread_pool_t *pool) {
    pthread_mutex_lock(&pool->queue_mutex);
    while (pool->working_count > 0 || pool->queue_size > 0) {
        pthread_cond_wait(&pool->working_cond, &pool->queue_mutex);
    }
    pthread_mutex_unlock(&pool->queue_mutex);
}

void thread_pool_destroy(thread_pool_t *pool) {
    pthread_mutex_lock(&pool->queue_mutex);
    pool->stop = 1;
    pthread_cond_broadcast(&pool->queue_cond);
    pthread_mutex_unlock(&pool->queue_mutex);
    
    for (size_t i = 0; i < pool->thread_count; i++) {
        pthread_join(pool->threads[i], NULL);
    }
    
    FREE(pool->task_queue);
    FREE(pool->threads);
    
    pthread_mutex_destroy(&pool->queue_mutex);
    pthread_cond_destroy(&pool->queue_cond);
    pthread_cond_destroy(&pool->working_cond);
    
    FREE(pool);
}

// 4. SIMD-OPTIMIZED MATRIX MULTIPLICATION

void matrix_multiply_simd(const float *a, const float *b, float *c, 
                         size_t a_rows, size_t a_cols, size_t b_cols) {
    for (size_t i = 0; i < a_rows; i++) {
        for (size_t j = 0; j < b_cols; j += 8) {  // Process 8 elements at a time
            __m256 sum = _mm256_setzero_ps();
            
            for (size_t k = 0; k < a_cols; k++) {
                __m256 a_vec = _mm256_set1_ps(a[i * a_cols + k]);
                __m256 b_vec = _mm256_loadu_ps(&b[k * b_cols + j]);
                sum = _mm256_add_ps(sum, _mm256_mul_ps(a_vec, b_vec));
            }
            
            _mm256_storeu_ps(&c[i * b_cols + j], sum);
        }
    }
}

// 5. PLUGIN ARCHITECTURE WITH DYNAMIC LOADING

typedef struct {
    void *handle;
    const char *name;
    void (*init)();
    void (*process)(void*);
    void (*cleanup)();
} plugin_t;

plugin_t* load_plugin(const char *path, const char *name) {
    void *handle = dlopen(path, RTLD_LAZY);
    if (!handle) {
        fprintf(stderr, "Error loading plugin: %s\n", dlerror());
        return NULL;
    }
    
    plugin_t *plugin = MALLOC(sizeof(plugin_t));
    if (!plugin) {
        dlclose(handle);
        return NULL;
    }
    
    plugin->handle = handle;
    plugin->name = name;
    
    // Load plugin functions
    plugin->init = dlsym(handle, "init");
    plugin->process = dlsym(handle, "process");
    plugin->cleanup = dlsym(handle, "cleanup");
    
    if (!plugin->init || !plugin->process || !plugin->cleanup) {
        fprintf(stderr, "Error loading plugin functions: %s\n", dlerror());
        dlclose(handle);
        FREE(plugin);
        return NULL;
    }
    
    // Initialize plugin
    plugin->init();
    
    return plugin;
}

void unload_plugin(plugin_t *plugin) {
    if (plugin) {
        plugin->cleanup();
        dlclose(plugin->handle);
        FREE(plugin);
    }
}

// 6. PROFESSIONAL ERROR HANDLING AND LOGGING

typedef enum {
    LOG_DEBUG,
    LOG_INFO,
    LOG_WARNING,
    LOG_ERROR,
    LOG_CRITICAL
} log_level_t;

void logger(log_level_t level, const char *file, int line, const char *func, const char *format, ...) {
    const char *level_str;
    FILE *output;
    
    switch (level) {
        case LOG_DEBUG: level_str = "DEBUG"; output = stdout; break;
        case LOG_INFO: level_str = "INFO"; output = stdout; break;
        case LOG_WARNING: level_str = "WARNING"; output = stderr; break;
        case LOG_ERROR: level_str = "ERROR"; output = stderr; break;
        case LOG_CRITICAL: level_str = "CRITICAL"; output = stderr; break;
        default: level_str = "UNKNOWN"; output = stderr;
    }
    
    struct timeval tv;
    gettimeofday(&tv, NULL);
    struct tm *tm_info = localtime(&tv.tv_sec);
    
    char timestamp[64];
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", tm_info);
    
    fprintf(output, "%s.%03ld [%s] %s:%d (%s): ", 
            timestamp, tv.tv_usec / 1000, level_str, file, line, func);
    
    va_list args;
    va_start(args, format);
    vfprintf(output, format, args);
    va_end(args);
    
    fprintf(output, "\n");
}

#define LOG(level, ...) logger(level, __FILE__, __LINE__, __func__, __VA_ARGS__)

// 7. DEMONSTRATION OF ADVANCED ALGORITHMS

// Binary search tree implementation
typedef struct bst_node {
    int key;
    void *data;
    struct bst_node *left;
    struct bst_node *right;
} bst_node_t;

bst_node_t* bst_insert(bst_node_t *root, int key, void *data) {
    if (!root) {
        bst_node_t *new_node = MALLOC(sizeof(bst_node_t));
        if (!new_node) return NULL;
        
        new_node->key = key;
        new_node->data = data;
        new_node->left = new_node->right = NULL;
        return new_node;
    }
    
    if (key < root->key) {
        root->left = bst_insert(root->left, key, data);
    } else if (key > root->key) {
        root->right = bst_insert(root->right, key, data);
    }
    
    return root;
}

void* bst_search(bst_node_t *root, int key) {
    if (!root) return NULL;
    
    if (key == root->key) {
        return root->data;
    } else if (key < root->key) {
        return bst_search(root->left, key);
    } else {
        return bst_search(root->right, key);
    }
}

void bst_free(bst_node_t *root) {
    if (root) {
        bst_free(root->left);
        bst_free(root->right);
        FREE(root);
    }
}

// 8. MAIN FUNCTION DEMONSTRATING ALL FEATURES

void sample_task(void *arg) {
    int *value = (int*)arg;
    LOG(LOG_INFO, "Processing task with value: %d (thread: %lu)", 
        *value, (unsigned long)pthread_self());
    
    // Simulate work
    usleep(100000);  // 100ms
}

int main() {
    LOG(LOG_INFO, "Starting advanced C programming showcase");
    
    // 1. Demonstrate memory allocator with debugging
    LOG(LOG_INFO, "Testing memory allocator with debugging");
    int *test_ptr = MALLOC(sizeof(int) * 10);
    for (int i = 0; i < 10; i++) {
        test_ptr[i] = i * i;
    }
    
    // 2. Demonstrate generic vector
    LOG(LOG_INFO, "Testing generic vector");
    vector_t *int_vec = vector_create(sizeof(int), 10);
    for (int i = 0; i < 20; i++) {
        vector_push_back(int_vec, &i);
    }
    
    // 3. Demonstrate thread pool
    LOG(LOG_INFO, "Testing thread pool");
    thread_pool_t *pool = thread_pool_create(4);
    int task_data[10];
    
    for (int i = 0; i < 10; i++) {
        task_data[i] = i;
        thread_pool_add_task(pool, sample_task, &task_data[i]);
    }
    
    thread_pool_wait(pool);
    
    // 4. Demonstrate SIMD matrix multiplication
    LOG(LOG_INFO, "Testing SIMD matrix multiplication");
    float a[4][4] = {{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}, {13, 14, 15, 16}};
    float b[4][4] = {{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}};
    float c[4][4] = {0};
    
    matrix_multiply_simd((float*)a, (float*)b, (float*)c, 4, 4, 4);
    
    // 5. Demonstrate binary search tree
    LOG(LOG_INFO, "Testing binary search tree");
    bst_node_t *root = NULL;
    int values[] = {50, 30, 70, 20, 40, 60, 80};
    
    for (int i = 0; i < 7; i++) {
        int *data = MALLOC(sizeof(int));
        *data = values[i] * 10;
        root = bst_insert(root, values[i], data);
    }
    
    // Search for a value
    int *found = bst_search(root, 40);
    if (found) {
        LOG(LOG_INFO, "Found value in BST: %d", *found);
    }
    
    // Clean up
    LOG(LOG_INFO, "Cleaning up resources");
    bst_free(root);
    thread_pool_destroy(pool);
    vector_destroy(int_vec);
    FREE(test_ptr);
    
    // Check for memory leaks
    report_memory_leaks();
    
    LOG(LOG_INFO, "Program completed successfully");
    return 0;
}