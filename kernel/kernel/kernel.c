#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/kernel/tty.h"
#include "../include/kernel/idt.h"
#include "../include/kernel/pic.h"

void kernel_main(void){
    terminal_initialize();
    printf("Welcome to the 64-bit AdiOS kernel\n");
    printf("Initializing PIC...\n");
    // Initialize PIC
    PIC_initialize(0x20, 0x28);
    // Masking channel 0 so we don't trigger system timer interrupt
    PIC_mask_irq_channel(0);
    printf("Initializing Interrupt Descriptor Table...\n");
    // Initialize the IDT
    idt_full_initialize();

    while(1){
        poll_keyboard();
    }
}