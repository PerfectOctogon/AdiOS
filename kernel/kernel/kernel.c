#include <stdio.h>
#include "../include/kernel/tty.h"
#include "../include/kernel/idt.h"
#include "../include/kernel/pic.h"

void kernel_main(void){
    terminal_initialize();
    printf("Welcome to the 64-bit adios kernel\n");

    // Initialize PIC
    //PIC_initialize(0x20, 0x28);
    idt_full_initialize();
    // Load interrupt descriptor table
}