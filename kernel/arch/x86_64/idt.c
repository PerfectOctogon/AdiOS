#include "../../include/kernel/idt.h"
#include <string.h>

// This is the Interrupt descriptor table :)
struct idt_64 IDT[NUM_INTERRUPTS];

// Pointer to the idt
struct idt_pointer idtr;

// Contains interrupt description we can print out :)
// Source : https://wiki.osdev.org/Interrupt_Descriptor_Table
char *interrupt_description[]={
    "Divide error",
    "Debug exception",
    "NMI interrupt",
    "Breakpoint",
    "Overflow",
    "Bound range exceeded",
    "Invalid opcode",
    "Device not available",
    "Double fault",
    "Coprocessor segment overrun",
    "Invalid TSS",
    "Segment not present",
    "Stack-segment fault",
    "General protection",
    "Page fault",
    "Intel reserved",
    "Floating point error",
    "Alignment check",
    "Machine check",
    "SIMD floating point exception",
    "Virtualization exception",
    "control protection exception",
    "Unknown mysterious interrupt...... :)"
};

// LIDT!!! Load the IDT into IDTR
void lidt(){
    asm("movabsq $idtr, %%rax"
        "lidt (%%rax)"
        :
        :
        : "rax");
}

// Add an entry to the IDT
void idt_add_gate(uint32_t index, uint8_t attributes, uint16_t code_segment_selector, void (*isr_function)()){

    // This is the pointer to the entry point of the isr handler
    uintptr_t isr_pointer = (uintptr_t)isr_function;

    // Set the youngest two bytes of the address to offset low
    IDT[index].offset_low = (uint64_t)(isr_pointer) & 0xFFFF;
    // Set the code selector
    IDT[index].code_segment_selector = code_segment_selector;
    // Not using IST, set to 0
    IDT[index].interrupt_stack_table = 0x0;
    // Set attributes
    IDT[index].attributes = attributes;
    // Set the middle offset of this ISR
    IDT[index].offset_mid = ((uint64_t)(isr_pointer) >> 16) & 0xFFFF;
    // Set the high offset of this ISR
    IDT[index].offset_high = ((uint64_t)(isr_pointer) >> 32) & 0xFFFFFFFF;
    // Set null descriptor of the IDT
    IDT[index].null_descriptor = 0x00000000;
}

void idt_load(){
    // Size of IDT(256 for the number of entries we will eventually have) - 1
    idtr.idt_size = (sizeof(IDT)) - 1;
    idtr.offset = (uintptr_t)&IDT[0];

    // 0 out all entries
    memset((void *)&IDT[0], 0, sizeof(IDT));
}

void idt_fill_idt(){

}

void isr_handler(){
    
}