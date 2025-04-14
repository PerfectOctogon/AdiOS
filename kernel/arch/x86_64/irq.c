#include "../../include/kernel/irq.h"
#include "../../include/kernel/idt.h"
#include "../../include/kernel/pic.h"
#include "../../include/kernel/drivers/keyboard.h"
#include <stdio.h>
#include <string.h>

// Source : https://en.wikipedia.org/wiki/Interrupt_request
static char * interrupt_description[]={
    "System timer",
    "Keyboard",
    "Slave cascade",
    "Serial port controller for serial port 2",
    "Serial port controller for serial port 1",
    "Parallel port 3 / ISA sound card",
    "Floppy disk controller",
    "Parallel port 1",
    "Real time clock",
    "ACPI",
    "Peripherals",
    "Peripherals",
    "Mouse",
    "CPU co-processor",
    "Primary ATA channel",
    "Secondary ATA channel"
};

void irq_handler(struct stack_vals * stack_vals){
    char * int_desc = interrupt_description[stack_vals->interrupt_code - 32];
    // printf("Interrupt request : %s\n", int_desc);
    
    // If the interrupt code is 33, we can read it into scancode to clear keyboard buffer
    if(stack_vals->interrupt_code == 33){
        unsigned char scancode = inb(0x60);
        printf("%c", scancode_to_keycode(scancode));
    }
    // Send EOI to slave
    if(stack_vals->interrupt_code >= 40){
        outb(0xA0, 0x20);
    }

    // Send EOI to master
    outb(0x20, 0x20);
    // while(1);
}

void irq_init(){
    idt_add_gate(32, 0x8E, 0x08, irq0);
    idt_add_gate(33, 0x8E, 0x08, irq1);
    idt_add_gate(34, 0x8E, 0x08, irq2);
    idt_add_gate(35, 0x8E, 0x08, irq3);
    idt_add_gate(36, 0x8E, 0x08, irq4);
    idt_add_gate(37, 0x8E, 0x08, irq5);
    idt_add_gate(38, 0x8E, 0x08, irq6);
    idt_add_gate(39, 0x8E, 0x08, irq7);
    idt_add_gate(40, 0x8E, 0x08, irq8);
    idt_add_gate(41, 0x8E, 0x08, irq9);
    idt_add_gate(42, 0x8E, 0x08, irq10);
    idt_add_gate(43, 0x8E, 0x08, irq11);
    idt_add_gate(44, 0x8E, 0x08, irq12);
    idt_add_gate(45, 0x8E, 0x08, irq13);
    idt_add_gate(46, 0x8E, 0x08, irq14);
    idt_add_gate(47, 0x8E, 0x08, irq15);
}