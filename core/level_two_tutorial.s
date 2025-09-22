####################################################################
# Level Two Assembly Tutorial – Single File
# Author: Cazzy
# Purpose: Advanced Assembly concepts for teaching/portfolio
####################################################################

.global _start

.section .data
# Arrays and buffers
array_qs:      .quad 9,7,5,3,1,2,4,6,8
len_qs:        .quad 9
search_array:  .quad 1,3,5,7,9,11,13
len_search:    .quad 7
heap_array:    .space 10*8
event_buffer:  .space 10*16
string_data:   .ascii "level_two_example;split;tokenize\0"
delim:         .byte ';'

.section .bss
dynamic_array_space: .skip 64

.section .text

_start:
    ################################################################
    # Example 1: QuickSort
    ################################################################
    lea array_qs(%rip), %rdi
    movq len_qs(%rip), %rsi
    call quicksort

    ################################################################
    # Example 2: Binary Search
    ################################################################
    lea search_array(%rip), %rdi
    movq $7, %rsi
    movq len_search(%rip), %rdx
    call binary_search

    ################################################################
    # Example 3: Heap Insert / Remove
    ################################################################
    lea heap_array(%rip), %rdi
    call heap_insert
    call heap_remove

    ################################################################
    # Example 4: Function Pointer Table Example
    ################################################################
    call function_table_demo

    ################################################################
    # Example 5: File Copy
    ################################################################
    lea input_file(%rip), %rdi
    lea output_file(%rip), %rsi
    call file_copy

    ################################################################
    # Example 6: String Tokenizer
    ################################################################
    lea string_data(%rip), %rdi
    lea delim(%rip), %rsi
    call tokenize_string

    ################################################################
    # Example 7: Dynamic Array Append / Resize
    ################################################################
    lea dynamic_array_space(%rip), %rdi
    call dynamic_array_demo

    ################################################################
    # Example 8: Merge Two Arrays
    ################################################################
    call merge_arrays_demo

    ################################################################
    # Example 9: Memoized Factorial / Fibonacci
    ################################################################
    movq $10, %rdi
    call factorial_memo
    movq $10, %rdi
    call fibonacci_memo

    ################################################################
    # Example 10: Event Logger
    ################################################################
    call event_logger_demo

    ################################################################
    # Exit Program
    ################################################################
    movq $60, %rax
    xor %rdi, %rdi
    syscall

####################################################################
# Function Skeletons (implementations below)
####################################################################

# QuickSort Recursive Function
quicksort:
    # Implement Lomuto partition + recursion
    ret

# Binary Search Recursive / Iterative
binary_search:
    ret

# Heap Insert
heap_insert:
    ret

# Heap Remove
heap_remove:
    ret

# Function Table / Pointer Demo
function_table_demo:
    ret

# File Copy Using Syscalls
file_copy:
    ret

# String Tokenizer
tokenize_string:
    ret

# Dynamic Array Append / Resize
dynamic_array_demo:
    ret

# Merge Two Arrays
merge_arrays_demo:
    ret

# Memoized Factorial
factorial_memo:
    ret

# Memoized Fibonacci
fibonacci_memo:
    ret

# Event Logger Demo (Ring Buffer)
event_logger_demo:
    ret