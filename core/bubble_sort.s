.global _start
.section .data
array: .quad 5,3,4,1,2
length: .quad 5

.section .text
_start:
    movq length(%rip), %rcx

outer:
    dec %rcx
    jle done

    movq $0, %rbx       # inner index

inner:
    cmp %rbx, %rcx
    jge outer

    movq array(,%rbx,8), %rax
    movq array(,%rbx,8+8), %rdx

    cmpq %rax, %rdx
    jle skip
    movq %rdx, array(,%rbx,8)
    movq %rax, array(,%rbx,8+8)
skip:
    inc %rbx
    jmp inner

done:
    movq $60, %rax
    xor %rdi, %rdi
    syscall