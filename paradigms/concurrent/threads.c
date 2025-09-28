/*
 * =========================================================
 * SISU — Concurrency Primitives
 * =========================================================
 * 
 * DENSITY:     ████████░░  [8/10]
 * ENDURANCE:   █████████░  [9/10]  
 * ABSTRACTION: ██████░░░░  [6/10]
 *
 * COLOR PHASE: #4ADE80 (Deep Green - Mature patterns)
 *
 * Historical Context:
 *   Born from: Dijkstra's Semaphores, 1965
 *   Survived:  Threads, processes, coroutines, async
 *   Evolves:   Into Go channels, Rust async, but still this
 *
 * Compression Ratio: Time-sharing : Code-sharing = N:1
 *
 * =========================================================
 */

#include <pthread.h>
#include <stdatomic.h>
#include <stdint.h>
#include <string.h>

// The Mutex - Mutual Exclusion (Dijkstra, 1965)
// The first compression: many threads, one resource
typedef struct {
    pthread_mutex_t lock;
    int32_t value;
    uint32_t color;  // Even locks have color
} SisuMutex;

void sisu_mutex_init(SisuMutex* m) {
    pthread_mutex_init(&m->lock, NULL);
    m->value = 0;
    m->color = 0x4ADE80;  // Deep green - stable concurrency
}

// The critical section - Where time stops
void sisu_critical(SisuMutex* m, void (*work)(int32_t*)) {
    pthread_mutex_lock(&m->lock);    // Enter the void
    work(&m->value);                  // Do the work
    pthread_mutex_unlock(&m->lock);  // Return to flow
}

// The Semaphore - The original synchronization (1965)
// Compression: Infinite waiters, finite resources
typedef struct {
    atomic_int count;
    pthread_mutex_t lock;
    pthread_cond_t cond;
} Semaphore;

void sem_init(Semaphore* s, int initial) {
    atomic_store(&s->count, initial);
    pthread_mutex_init(&s->lock, NULL);
    pthread_cond_init(&s->cond, NULL);
}

// P() - Proberen (try) - Dijkstra's Dutch
void sem_wait(Semaphore* s) {
    pthread_mutex_lock(&s->lock);
    while (atomic_load(&s->count) <= 0) {
        pthread_cond_wait(&s->cond, &s->lock);  // Sleep until signal
    }
    atomic_fetch_sub(&s->count, 1);
    pthread_mutex_unlock(&s->lock);
}

// V() - Verhogen (increase)
void sem_post(Semaphore* s) {
    pthread_mutex_lock(&s->lock);
    atomic_fetch_add(&s->count, 1);
    pthread_cond_signal(&s->cond);  // Wake one waiter
    pthread_mutex_unlock(&s->lock);
}

// The Channel - CSP (Hoare, 1978)
// Compression: Don't share memory, share messages
typedef struct {
    void* buffer[64];     // Ring buffer
    atomic_int head;
    atomic_int tail;
    Semaphore full;
    Semaphore empty;
    pthread_mutex_t lock;
} Channel;

void channel_init(Channel* ch) {
    atomic_store(&ch->head, 0);
    atomic_store(&ch->tail, 0);
    sem_init(&ch->full, 0);
    sem_init(&ch->empty, 64);
    pthread_mutex_init(&ch->lock, NULL);
}

void channel_send(Channel* ch, void* msg) {
    sem_wait(&ch->empty);  // Wait for space
    
    pthread_mutex_lock(&ch->lock);
    int tail = atomic_load(&ch->tail);
    ch->buffer[tail] = msg;
    atomic_store(&ch->tail, (tail + 1) % 64);
    pthread_mutex_unlock(&ch->lock);
    
    sem_post(&ch->full);   // Signal data available
}

void* channel_recv(Channel* ch) {
    sem_wait(&ch->full);   // Wait for data
    
    pthread_mutex_lock(&ch->lock);
    int head = atomic_load(&ch->head);
    void* msg = ch->buffer[head];
    atomic_store(&ch->head, (head + 1) % 64);
    pthread_mutex_unlock(&ch->lock);
    
    sem_post(&ch->empty);  // Signal space available
    return msg;
}

// The Atomic - Lock-free programming (1990s)
// Compression: Locks → No locks
typedef struct {
    atomic_int value;
} Atomic;

int atomic_add(Atomic* a, int delta) {
    // Compare-And-Swap loop - The fundamental atomic
    int expected = atomic_load(&a->value);
    while (!atomic_compare_exchange_weak(&a->value, &expected, expected + delta)) {
        // Retry until successful
    }
    return expected + delta;
}

// The Barrier - Synchronization point (MPI, 1994)
// Compression: N threads → 1 synchronization
typedef struct {
    pthread_barrier_t barrier;
    uint32_t threads;
    uint32_t color;
} Barrier;

void barrier_init(Barrier* b, uint32_t threads) {
    pthread_barrier_init(&b->barrier, NULL, threads);
    b->threads = threads;
    b->color = 0x4ADE80;
}

void barrier_wait(Barrier* b) {
    pthread_barrier_wait(&b->barrier);
    // All threads continue together
}

// The Thread Pool - Reuse over creation (1980s)
// Compression: Thread creation cost → 0
typedef struct {
    pthread_t threads[8];
    Channel work_queue;
    atomic_bool shutdown;
} ThreadPool;

void* worker_thread(void* arg) {
    ThreadPool* pool = (ThreadPool*)arg;
    while (!atomic_load(&pool->shutdown)) {
        void (*work)(void*) = channel_recv(&pool->work_queue);
        if (work) work(NULL);
    }
    return NULL;
}

void pool_init(ThreadPool* pool) {
    channel_init(&pool->work_queue);
    atomic_store(&pool->shutdown, false);
    
    for (int i = 0; i < 8; i++) {
        pthread_create(&pool->threads[i], NULL, worker_thread, pool);
    }
}

void pool_submit(ThreadPool* pool, void (*work)(void*)) {
    channel_send(&pool->work_queue, work);
}

// The Future - Asynchronous results (1977)
// Compression: Synchronous → Asynchronous
typedef struct {
    pthread_mutex_t lock;
    pthread_cond_t ready;
    void* result;
    atomic_bool done;
} Future;

void future_init(Future* f) {
    pthread_mutex_init(&f->lock, NULL);
    pthread_cond_init(&f->ready, NULL);
    f->result = NULL;
    atomic_store(&f->done, false);
}

void future_set(Future* f, void* result) {
    pthread_mutex_lock(&f->lock);
    f->result = result;
    atomic_store(&f->done, true);
    pthread_cond_broadcast(&f->ready);
    pthread_mutex_unlock(&f->lock);
}

void* future_get(Future* f) {
    pthread_mutex_lock(&f->lock);
    while (!atomic_load(&f->done)) {
        pthread_cond_wait(&f->ready, &f->lock);
    }
    void* result = f->result;
    pthread_mutex_unlock(&f->lock);
    return result;
}

/*
 * The Laws of Concurrency:
 * 
 * 1. Amdahl's Law (1967): Speedup is limited by sequential parts
 * 2. Gustafson's Law (1988): But we can do more work in parallel
 * 3. Little's Law (1961): L = λW (Queue theory applies)
 * 
 * The Compression Truth:
 * All concurrency is:
 * - Time slicing (threads)
 * - Space slicing (processes)
 * - Work slicing (tasks)
 * 
 * Pick your slice.
 *
 * "The real problem is that programmers have spent far
 *  too much time worrying about efficiency in the wrong
 *  places and at the wrong times; premature optimization
 *  is the root of all evil (or at least most of it) in
 *  programming." - Knuth
 *
 * But with threads, optimization is always premature.
 */
