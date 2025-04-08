#include <stdio.h>
#include "../include/kernel/tty.h"
#include "../include/kernel/idt.h"
#include "../include/kernel/pic.h"

void kernel_main(void){
    terminal_initialize();
    printf("\n");
    printf("Welcome to the 64-bit ADIOS kernel\n");
    //terminal_writestring("Welcome to the 64-bit ADIOS kernel\nInitializing...\n");
    //printf("Initializing PIC...\n");
    // Initialize PIC
    PIC_initialize(0x20, 0x28);
    //printf("Initializing IDT...\n");
    // Initialize the IDT
    idt_full_initialize();

    // Try dummy interrupt (division by 0)
    asm("int $2;");
}