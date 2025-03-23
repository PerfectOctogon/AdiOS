.global long_mode_start
.extern kernel_main

.section .text
.code64
long_mode_start:
    # loading null into all data segment registers
    # Lets now call the main kernel
    // TO:DO Movq not executing properly
    // movq $0xb8000, %rax
    // movq $0x4f524f45, (%rax)

    call kernel_main
    hlt