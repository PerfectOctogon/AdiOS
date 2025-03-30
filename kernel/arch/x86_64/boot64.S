.global long_mode_start
.extern kernel_main

.section .text
.code64
long_mode_start:
    # loading null into all data segment registers
    cli
    mov $0x0010, %ax
    mov %ax, %ss
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs

    # Interrupt handler
    
    call kernel_main
    hlt