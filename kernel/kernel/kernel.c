#include <stdio.h>
#include "../include/kernel/tty.h"

void kernel_main(void){
    terminal_initialize();
    printf("Welcome to the 64-bit adios kernel\n");

    // Initialize PIC
    // Load interrupt descriptor table
}