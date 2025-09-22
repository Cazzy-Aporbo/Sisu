.global _start
.section .data
n:      .quad 5
result: .quad 0

.section .text
_start:
    movq n(%rip), %rdi    # argument
    call factorial
    movq %rax, result(%rip)

    movq $60, %rax
    xor %rdi, %rdi
    syscall

factorial:
    cmpq $1, %rdi
    jle .base
    push %rdi
    dec %rdi
    call factorial
    pop %rdi
    imul %rdi, %rax
    ret
.base:
    movq $1, %rax
    ret