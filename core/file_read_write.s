.global _start

.section .data
input_file: .asciz "input.txt"
output_file: .asciz "output.txt"
buffer: .space 128

.section .text
_start:
    movq $2, %rax           # sys_open
    lea input_file(%rip), %rdi
    movq $0, %rsi
    syscall
    movq %rax, %r8          # save input fd

    movq $0, %rax           # sys_read
    movq %r8, %rdi
    lea buffer(%rip), %rsi
    movq $128, %rdx
    syscall
    movq %rax, %r9          # bytes read

    movq $2, %rax           # sys_open output file
    lea output_file(%rip), %rdi
    movq $577, %rsi         # O_WRONLY|O_CREAT|O_TRUNC
    movq $0644, %rdx
    syscall
    movq %rax, %r10         # output fd

    movq $1, %rax           # sys_write
    movq %r10, %rdi
    lea buffer(%rip), %rsi
    movq %r9, %rdx
    syscall

    movq $60, %rax
    xor %rdi, %rdi
    syscall