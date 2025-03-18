global long_mode_start
extern kernel_main

section .text
bits 64
long_mode_start:
    # loading null into all data segment registers
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    # Lets now call the main kernel
    call kernel_main

    hlt

# 64 bit Global descriptor table
.section .rodata
gdt64:
    .quad 0
.equ code_segment, (.-gdt64)
    .quad (1 << 43) | (1 <<44) | (1 << 47) | (1 << 53)

.pointer:
    .word $ - gdt64 - 1
    .quad gdt64