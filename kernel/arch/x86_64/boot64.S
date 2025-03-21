.global long_mode_start
.extern kernel_main

.section .text
.code64
long_mode_start:
    # loading null into all data segment registers
    movw %ax, 0
    movw %ss, %ax
    movw %ds, %ax
    movw %es, %ax
    movw %fs, %ax
    movw %gs, %ax

    # Lets now call the main kernel
    call kernel_main

    1: hlt
    jmp 1