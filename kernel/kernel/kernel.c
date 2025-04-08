#include <stdio.h>
#include "../include/kernel/tty.h"
#include "../include/kernel/pic.h"
#include "../include/kernel/idt.h"

void kernel_main(void){
    terminal_initialize();
    printf("Welcome to the 64-bit adios kernel\n");

    // Initialize PIC
    // Load interrupt descriptor table
}