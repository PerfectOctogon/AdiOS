#ifndef __IRQ_H__
#define __IRQ_H__

#include "../../include/kernel/idt.h"

// Handler for interrupt requests
void irq_handler(struct stack_vals * stack_vals);

// Adds IRQ's to IDT gates
void irq_init();

void irq0();
void irq1();
void irq2();
void irq3();
void irq4();
void irq5();
void irq6();
void irq7();
void irq8();
void irq9();
void irq10();
void irq11();
void irq12();
void irq13();
void irq14();
void irq15();

#endif