.global _start
.section .data
string: .ascii "Hello, Assembly!\0"
length: .quad 0

.section .text
_start:
    lea string(%rip), %rdi
    call strlen
    movq %rax, length(%rip)

    movq $60, %rax
    xor %rdi, %rdi
    syscall

strlen:
    xor %rax, %rax
.loop:
    cmpb $0, (%rdi,%rax)
    je .done
    inc %rax
    jmp .loop
.done:
    ret