.global _start

.section .data
n: .quad 10
fib: .space 10*8

.section .text
_start:
    movq n(%rip), %rcx
    movq $0, %rax
    movq $1, %rbx
    movq $0, %rdx
    movq $0, %r8

loop_fib:
    cmpq %r8, %rcx
    jge done
    movq %rax, fib(,%r8,8)
    movq %rax, %rdx
    addq %rbx, %rax
    movq %rdx, %rbx
    incq %r8
    jmp loop_fib

done:
    movq $60, %rax
    xor %rdi, %rdi
    syscall