#include "../../include/kernel/isr.h"

void (*interrupt_handlers[32])() = {
    isr0,  isr1,  isr2,  isr3,
    isr4,  isr5,  isr6,  isr7,
    isr8,  isr9,  isr10, isr11,
    isr12, isr13, isr14, isr15,
    isr16, isr17, isr18, isr19,
    isr20, isr21, isr22, isr23,
    isr24, isr25, isr26, isr27,
    isr28, isr29, isr30, isr31
};