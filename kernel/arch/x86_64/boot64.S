.global long_mode_start
.extern kernel_main

.section .text
.code64
long_mode_start:
    # loading null into all data segment registers
    movl $0x4f3a4f53, 0xb8004
    movw $0, %ax
    movw %ax, %ss
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs

    # Lets now call the main kernel
    call kernel_main

    1: hlt
    jmp 1