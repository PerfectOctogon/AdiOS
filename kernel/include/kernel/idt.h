#ifndef __IDT__
#define __IDT__

#include <stdint.h>

// This is the maximum number of interrupt vector entries
#define NUM_INTERRUPTS  256

// define the IDT for long mode
struct idt_64{
    // youngest two bytes of the offset
    uint16_t offset_low;
    // GDT code segment selector
    uint16_t code_segment_selector;
    // Interrupt stack table
    uint8_t interrupt_stack_table;
    // Attributes
    uint8_t attributes;
    // Offset mid
    uint16_t offset_mid;
    // Offset high
    uint32_t offset_high;
    // Null descriptor
    uint32_t null_descriptor;
}__attribute((packed)); // Make sure there is no padding in memory

// Pointer to the idt needed for the IDTR
struct idt_pointer{
    // One less than the size of the IDT in bytes
    uint16_t idt_size;
    // Address of the IDT
    uintptr_t offset;
}__attribute__((packed));

// Pointers to values that were pushed into the stack by interrupt.S
struct stack_vals{
    // R- registers
    uintptr_t r15, r14, r13, r12, r11, r10, r9, r8;
    // Registers
    uintptr_t rsp, rbp, rdi, rsi, rdx, rcx, rbx, rax;
    // Interrupt code
    uintptr_t interrupt_code;
    // Interrupt error code
    uintptr_t error_code;
}__attribute__((packed));

// Initializes the IDT
void idt_load(void);

/**
 * @brief  Add an entry to the IDT
 * 
 * @param index index of this entry
 * @param attributes Attributes of this entry
 * @param code_segment_selector 
 * @param isr_function The function that will handle this IRQ
 */
void idt_add_gate(uint32_t index, uint8_t attributes, uint16_t code_segment_selector, void (*isr_function)());

// Load the IDT to the IDTR
void lidt();

// Fills up the IDT with entries
void idt_fill_idt();

// Default ISR handler
void isr_handler(struct stack_vals * stack_vals);

// Fully initializes the IDT
void idt_full_initialize();
#endif