---

# **2. Level Two Docs (`level_two_docs.md`)**

```markdown
# Level Two Assembly Tutorial Documentation

## Overview
Level Two builds on Level One by introducing:
- Modular function design with parameters and return values
- Stack and local variable management
- Dynamic memory simulation
- Advanced algorithms: QuickSort, Binary Search, Merge

## Examples Included
| Example | Concept | Notes / Variants |
|---------|---------|-----------------|
| QuickSort | Recursive sorting | Lomuto and Hoare partitions |
| Binary Search | Array search | Recursive and iterative |
| Heap Operations | Max heap insert/remove | Array-based implementation |
| Function Pointers | Jump table / virtual call | Table of arithmetic functions |
| File Copy | Syscall-based buffered I/O | Multiple buffer sizes |
| String Tokenizer | Pointer arithmetic | Delimiter-based tokenization |
| Dynamic Array | Simulated malloc/free | Append/resize operations |
| Merge Arrays | Memory copy and merge | Two arrays, in-place merge |
| Factorial / Fibonacci Memoized | Stack + heap | Cache stored in memory |
| Event Logger | Ring buffer | Store N latest events |

## Recommended Sections for Each Example
- **Overview / Purpose:** What the example demonstrates and why it is useful
- **Data Structures:** Arrays, buffers, stacks
- **Functions:** Modular functions, parameter passing
- **Variants:** Multiple implementations for teaching
- **Testing / Output:** Expected outputs for validation

## How to Compile and Run
```bash
gcc -no-pie quicksort.s -o quicksort
./quicksort