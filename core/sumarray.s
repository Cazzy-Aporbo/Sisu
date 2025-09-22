.global _start
.section .data
array:  .quad 1, 2, 3, 4, 5
length: .quad 5
sum:    .quad 0

.section .text
_start:
    movq $0, %rax        # sum accumulator
    movq $0, %rcx        # index
    movq length(%rip), %r8

loop_start:
    cmpq %rcx, %r8
    jge done
    movq array(,%rcx,8), %r9
    addq %r9, %rax
    incq %rcx
    jmp loop_start

done:
    movq %rax, sum(%rip)

    # exit syscall
    movq $60, %rax       # sys_exit
    xor %rdi, %rdi
    syscall