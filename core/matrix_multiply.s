.global _start

.section .data
A: .quad 1,2,3,4,5,6,7,8,9
B: .quad 9,8,7,6,5,4,3,2,1
C: .space 9*8

N: .quad 3

.section .text
_start:
    movq $0, %r8       # row index i
outer_row:
    cmpq %r8, N(%rip)
    jge done
    movq $0, %r9       # column index j
outer_col:
    cmpq %r9, N(%rip)
    jge next_row
    movq $0, %rax      # sum accumulator
    movq $0, %r10      # k index
inner:
    cmpq %r10, N(%rip)
    jge store_result
    movq A(,%r8,24)(,%r10,8), %rbx
    movq B(,%r10,24)(,%r9,8), %rcx
    imul %rbx, %rcx
    addq %rcx, %rax
    incq %r10
    jmp inner
store_result:
    movq %rax, C(,%r8,24)(,%r9,8)
    incq %r9
    jmp outer_col
next_row:
    incq %r8
    jmp outer_row
done:
    movq $60, %rax
    xor %rdi, %rdi
    syscall