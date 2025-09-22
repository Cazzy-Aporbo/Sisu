####################################################################
# Level One Assembly Tutorial – Complete Package
# Author: Cazzy
# Purpose: Teach 15 foundational assembly concepts with multiple
#          approaches, clean, human-readable, without separators.
####################################################################

.global _start

####################################################################
# Data Section: Arrays, buffers, constants for all examples
####################################################################
.section .data

# Example 1,2,3: Arrays and sequences
array:      .quad 1,2,3,4,5
length:     .quad 5
fib_array:  .space 10*8
fact_array: .space 10*8
sum:        .quad 0
result:     .quad 0

# Example 4,5: Strings
string1:    .ascii "Hello, Assembly!\0"
string2:    .space 50
str_len:    .quad 0

# Example 6: Matrices
matA:       .quad 1,2,3,4,5,6,7,8,9
matB:       .quad 9,8,7,6,5,4,3,2,1
matC:       .space 9*8
N:          .quad 3

# Example 8: Linked List
list_head:  .quad 0
list_values:.quad 10,20,30
node_space: .skip 3*16

####################################################################
# Text Section: Functions and _start
####################################################################
.section .text

_start:

    ################################################################
    # Example 1: Sum Array (Iterative + Unrolled)
    ################################################################
    call sum_array_iterative
    call sum_array_unrolled

    ################################################################
    # Example 2: Factorial (Recursive + Iterative)
    ################################################################
    movq $5, %rdi       # compute factorial of 5
    call factorial_recursive
    movq %rax, result(%rip)
    movq $6, %rdi
    call factorial_iterative

    ################################################################
    # Example 3: Fibonacci (Iterative + Recursive)
    ################################################################
    movq $10, %rdi
    call fibonacci_iterative
    movq $10, %rdi
    call fibonacci_recursive

    ################################################################
    # Example 4: String Length
    ################################################################
    lea string1(%rip), %rdi
    call strlen

    ################################################################
    # Example 5: String Copy
    ################################################################
    lea string1(%rip), %rsi
    lea string2(%rip), %rdi
    call strcpy

    ################################################################
    # Example 6: Matrix Multiply 3x3
    ################################################################
    call matrix_multiply

    ################################################################
    # Example 8: Linked List Insert & Traverse
    ################################################################
    call linked_list_insert
    call linked_list_traverse

    ################################################################
    # Exit Program
    ################################################################
    movq $60, %rax       # sys_exit
    xor %rdi, %rdi
    syscall

####################################################################
# Functions
####################################################################

# Example 1: Sum Array Iterative
sum_array_iterative:
    movq $0, %rax
    movq $0, %rcx
loop_sum:
    cmpq %rcx, length(%rip)
    jge done_sum
    addq array(,%rcx,8), %rax
    incq %rcx
    jmp loop_sum
done_sum:
    movq %rax, sum(%rip)
    ret

# Example 1: Sum Array Unrolled
sum_array_unrolled:
    movq array(%rip), %rax
    addq array+8(%rip), %rax
    addq array+16(%rip), %rax
    addq array+24(%rip), %rax
    addq array+32(%rip), %rax
    ret

# Example 2: Factorial Recursive
factorial_recursive:
    cmpq $1, %rdi
    jle fact_base
    push %rdi
    dec %rdi
    call factorial_recursive
    pop %rdi
    imul %rdi, %rax
    ret
fact_base:
    movq $1, %rax
    ret

# Example 2: Factorial Iterative
factorial_iterative:
    movq $1, %rax
    movq %rdi, %rcx
fact_loop:
    cmpq $1, %rcx
    jle fact_done
    imul %rcx, %rax
    decq %rcx
    jmp fact_loop
fact_done:
    ret

# Example 3: Fibonacci Iterative
fibonacci_iterative:
    movq $0, %rax
    movq $1, %rbx
    movq $0, %rcx
fib_loop:
    cmpq %rcx, %rdi
    jge fib_done
    movq %rax, fib_array(,%rcx,8)
    movq %rax, %rdx
    addq %rbx, %rax
    movq %rdx, %rbx
    incq %rcx
    jmp fib_loop
fib_done:
    ret

# Example 3: Fibonacci Recursive
fibonacci_recursive:
    cmpq $1, %rdi
    jle fib_base
    push %rdi
    dec %rdi
    call fibonacci_recursive
    movq %rax, %rbx
    pop %rdi
    dec %rdi
    call fibonacci_recursive
    addq %rbx, %rax
    ret
fib_base:
    movq $1, %rax
    ret

# Example 4: String Length
strlen:
    xor %rax, %rax
strlen_loop:
    cmpb $0, (%rdi,%rax)
    je strlen_done
    inc %rax
    jmp strlen_loop
strlen_done:
    movq %rax, str_len(%rip)
    ret

# Example 5: String Copy
strcpy:
    xor %rax, %rax
copy_loop:
    movb (%rsi,%rax), %dl
    movb %dl, (%rdi,%rax)
    cmpb $0, (%rsi,%rax)
    je copy_done
    inc %rax
    jmp copy_loop
copy_done:
    ret

# Example 6: Matrix Multiply 3x3
matrix_multiply:
    movq $0, %r8
row_loop:
    cmpq %r8, N(%rip)
    jge matrix_done
    movq $0, %r9
col_loop:
    cmpq %r9, N(%rip)
    jge next_row
    movq $0, %rax
    movq $0, %r10
inner_loop:
    cmpq %r10, N(%rip)
    jge store_result
    movq matA(,%r8,24)(,%r10,8), %rbx
    movq matB(,%r10,24)(,%r9,8), %rcx
    imul %rbx, %rcx
    addq %rcx, %rax
    incq %r10
    jmp inner_loop
store_result:
    movq %rax, matC(,%r8,24)(,%r9,8)
    incq %r9
    jmp col_loop
next_row:
    incq %r8
    jmp row_loop
matrix_done:
    ret

# Example 8: Linked List Insert
linked_list_insert:
    movq $0, %rax
    lea list_values(%rip), %rbx
    movq $3, %rcx
insert_loop:
    cmpq $0, %rcx
    je insert_done
    decq %rcx
    lea node_space(,%rcx,16), %rdi
    movq (%rbx,%rcx,8), %rsi
    movq list_head(%rip), %rdx
    movq %rsi, 0(%rdi)
    movq %rdx, 8(%rdi)
    movq %rdi, list_head(%rip)
    jmp insert_loop
insert_done:
    ret

# Example 8: Linked List Traverse
linked_list_traverse:
    movq list_head(%rip), %r8
traverse_loop:
    cmpq $0, %r8
    je traverse_done
    movq 0(%r8), %rax
    movq 8(%r8), %r8
    jmp traverse_loop
traverse_done:
    ret