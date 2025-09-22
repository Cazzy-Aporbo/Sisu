---

# **3. Level Three Docs (`level_three_docs.md`)**

```markdown
# Level Three Assembly Tutorial Documentation

## Overview
Level Three focuses on **master-level assembly programming**, teaching:
- Optimized algorithms with recursion and loop unrolling
- Dynamic memory allocation with free list
- Event-driven and system-interfaced programs
- Function pointer tables and virtual dispatch
- Mini shell and file parser implementation

## Examples Included
| Example | Concept | Notes / Variants |
|---------|---------|-----------------|
| Optimized QuickSort | Tail-call recursion, in-place swaps | Lomuto & Hoare, unrolled |
| Merge Sort | Recursive merge, buffer usage | In-place and auxiliary array |
| Dynamic Memory Allocator | malloc/free simulation | Linked free list, best-fit |
| File Parser | Syscalls, tokenization | CSV, fixed-width fields |
| Event-Driven Program | Circular buffer, timer-based | Ring buffer events |
| Function Pointer Table | Virtual dispatch | Arithmetic ops, multi-type calls |
| Matrix Algebra | 3x3/4x4 multiply/add | Loop unrolling, SIMD layout |
| Prime Generator | Efficient prime detection | Sieve of Eratosthenes, incremental |
| Stack / Heap Profiler | Inspect memory usage | Count frames, allocations |
| Mini Shell | Syscall I/O, parsing | Command history, built-ins |
| Signal / Interrupt Demo | Trap / handler | Timer-based, user-defined |

## Recommended Sections in Each File
- **Overview / Purpose:** Clear statement of concept
- **Data Section:** Buffers, arrays, heap simulation
- **Text Section:** Functions, modular design
- **Variants:** Multiple approaches for optimization
- **System Interfacing:** Demonstrate syscalls, pseudo-multithreading
- **Testing / Output:** Sample output or validation steps

## Compilation and Execution
```bash
gcc -no-pie optimized_quicksort.s -o optimized_quicksort
./optimized_quicksort