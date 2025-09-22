.global _start

.section .data
list_head: .quad 0
values: .quad 10,20,30

.section .bss
node_space: .skip 3*16

.section .text
_start:
    movq $0, %rax
    lea values(%rip), %rbx
    movq $3, %rcx

insert_loop:
    cmpq $0, %rcx
    je traverse
    decq %rcx
    lea node_space(,%rcx,16), %rdi
    movq (%rbx,%rcx,8), %rsi
    movq list_head(%rip), %rdx
    movq %rsi, 0(%rdi)
    movq %rdx, 8(%rdi)
    movq %rdi, list_head(%rip)
    jmp insert_loop

traverse:
    movq list_head(%rip), %r8
traverse_loop:
    cmpq $0, %r8
    je done
    movq 0(%r8), %rax
    movq 8(%r8), %r8
    jmp traverse_loop

done:
    movq $60, %rax
    xor %rdi, %rdi
    syscall