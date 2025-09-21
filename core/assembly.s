/*
 * =========================================================
 * SISU — Assembly Foundation
 * =========================================================
 * 
 * DENSITY:     ██████████  [10/10]
 * ENDURANCE:   ██████████  [10/10]  
 * ABSTRACTION: ██░░░░░░░░  [2/10]
 *
 * COLOR PHASE: #052E16 (Void Green - The Deepest)
 *
 * Historical Context:
 *   Born from: Von Neumann Architecture, 1945
 *   Survived:  Every language built on top
 *   Evolves:   Into everything, remains itself
 *
 * Compression Ratio: ∞:1 (All computation compresses to this)
 *
 * =========================================================
 */

.section .data
    sisu_heartbeat: .ascii "SISU LIVES\n"
    heartbeat_len = . - sisu_heartbeat
    
    ; The gradient in bytes - from void to whisper
    gradient_green: .byte 0x05, 0x2E, 0x16  ; Void Green
                   .byte 0x0F, 0x46, 0x2A  ; Root
                   .byte 0x14, 0x53, 0x2D  ; Floor
                   .byte 0x16, 0x65, 0x34  ; Shadow
                   .byte 0x15, 0x80, 0x3D  ; Moss
                   .byte 0x16, 0xA3, 0x4A  ; Ancient
                   .byte 0xF0, 0xFD, 0xF4  ; Whisper

.section .text
.global _start

_start:
    ; The primordial algorithm: write, exit
    ; This is computation at its core
    
    ; Write syscall - the first compression
    mov $1, %rax           ; syscall: write
    mov $1, %rdi           ; file descriptor: stdout
    lea sisu_heartbeat, %rsi  ; buffer
    mov $heartbeat_len, %rdx  ; count
    syscall
    
    ; The eternal return
    mov $60, %rax          ; syscall: exit
    xor %rdi, %rdi         ; return 0 - the void green
    syscall

; Knuth, 1968: "We understand recursion by first understanding recursion"
recursive_endurance:
    push %rbp
    mov %rsp, %rbp
    
    ; Base case: when green reaches void
    cmp $0x052E16, %rax
    je .void_reached
    
    ; Recursive case: deepen the green
    dec %rax
    call recursive_endurance
    
.void_reached:
    pop %rbp
    ret

; The Sisu Principle encoded in assembly
; Every instruction here has survived since the 1950s
; This is endurance at the metal level
