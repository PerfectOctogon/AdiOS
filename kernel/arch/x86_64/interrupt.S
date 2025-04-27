.section .text
.code64

# Handler for isr
.extern isr_handler

# Macro for ISR with no error codes
.macro ISR_NO_ERR i
.global isr\i
isr\i:
    cli
    push $0 # There is no error code, so just push 0 onto the stack
    push $\i # Push the interrupt number onto the stack so we can identify the interrupt from the common stub
    jmp isr_common_stub # Jump to the common isr stub
.endm

# Macro for ISR with error codes
.macro ISR_ERR i
.global isr\i
isr\i:
    cli
    # no need to push the error code onto the stack because the CPU has already done that
    push $\i # Push the interrupt number onto the stack so we can identify the interrupt from the common stub
    jmp isr_common_stub # Jump to the common isr stub
.endm

# instantiate the macros for each interrupt
# source : https://wiki.osdev.org/Interrupt_Descriptor_Table
ISR_NO_ERR 0     # Divide Error
ISR_NO_ERR 1     # Debug
ISR_NO_ERR 2     # NMI
ISR_NO_ERR 3     # Breakpoint
ISR_NO_ERR 4     # Overflow
ISR_NO_ERR 5     # Bound Range Exceeded
ISR_NO_ERR 6     # Invalid Opcode
ISR_NO_ERR 7     # Device Not Available
ISR_ERR    8     # Double Fault
ISR_NO_ERR 9     # Coprocessor Segment Overrun (reserved)
ISR_ERR    10     # Invalid TSS
ISR_ERR    11     # Segment Not Present
ISR_ERR    12     # Stack Segment Fault
ISR_ERR    13     # General Protection Fault
ISR_ERR    14     # Page Fault
ISR_NO_ERR 15    # Reserved
ISR_NO_ERR 16    # Floating Point Error
ISR_ERR    17     # Alignment Check
ISR_NO_ERR 18    # Machine Check
ISR_NO_ERR 19    # SIMD Floating-Point Exception
ISR_NO_ERR 20    # Virtualization Exception
ISR_NO_ERR 21    # Control Protection Exception
ISR_NO_ERR 22
ISR_NO_ERR 23
ISR_NO_ERR 24
ISR_NO_ERR 25
ISR_NO_ERR 26
ISR_NO_ERR 27
ISR_NO_ERR 28
ISR_NO_ERR 29
ISR_NO_ERR 30
ISR_NO_ERR 31

isr_common_stub:
    // If this is from the user space, we need to swap in kernel GS
    cmpq $8, 24(%rsp)
    je push_regs
    swapgs

    // Push all registers to the stack
    push_regs:
        pushq %rax
        pushq %rbx
        pushq %rcx
        pushq %rdx
        pushq %rsi
        pushq %rdi
        pushq %rbp
        pushq %rsp
        pushq %r8
        pushq %r9
        pushq %r10
        pushq %r11
        pushq %r12
        pushq %r13
        pushq %r14
        pushq %r15
    
    # We need to store the stack pointer in rdi so we can access pushed elements as a struct
    mov %rsp, %rdi
    # Call the handler
    call isr_handler

    # Enable interrupts again
    cli
    # Restore registers
    pop_regs:
        popq %r15
        popq %r14
        popq %r13
        popq %r12
        popq %r11
        popq %r10
        popq %r9
        popq %r8
        #popq %rsp
        add $8, %rsp
        popq %rbp
        popq %rdi
        popq %rsi
        popq %rdx
        popq %rcx
        popq %rbx
        popq %rax
    
    cmpq $8, 24(%rsp)
    je 1f
    swapgs

    1:
    # Make error code and isr number overwritable (don't need it no more)
    add $16, %rsp
    # This guy is the reason I had to touch assembly again
    iretq

.extern irq_handler

# Macro for ISR with error codes
.macro IRQ i j
.global irq\i
irq\i:
    cli
    push $0 // dummy error code
    push $\j 
    jmp irq_common_stub
.endm

IRQ 0, 32
IRQ 1, 33
IRQ 2, 34
IRQ 3, 35
IRQ 4, 36
IRQ 5, 37
IRQ 6, 38 
IRQ 8, 40
IRQ 9, 41
IRQ 10, 42
IRQ 11, 43
IRQ 12, 44
IRQ 13, 45
IRQ 14, 46

/*
 * Special handler for IRQ-7 to check and handle spurious interrupts.
 * See:
 *    https://forum.osdev.org/viewtopic.php?f=1&t=11673
 *    https://wiki.osdev.org/8259_PIC
 */

.global irq7
irq7:

    cli
    //xchg %bx, %bx
    //xchg %bx, %bx
    pushq %rax
    
    // PIC.OCW3 set function to read ISR (In Service Register)
    movb $0x0b, %al
    
    // write to PIC.OCW3
    outb %al, $0x20

    // read ISR
    inb $0x20, %al
    
    // if the in-service register does not have IR7 bit set
    // this would be a spurious interrupt.
    test $0x80, %al
    jz 1f
    
    // mutex for spurious guard
    //bts $0x01, flags
    //jc 1f

    popq %rax

    // normal IRQ-7 routine
    pushq $0     // dummy error code
    pushq $39
    jmp irq_common_stub

1:
    // do not send EOI to master pic for a spurious IRQ7
    popq %rax
    iretq


/*
 * Special handler for IRQ-15 to check and handle spurious interrupts.
 * See:
 *    https://forum.osdev.org/viewtopic.php?f=1&t=11673
 *    https://wiki.osdev.org/8259_PIC
 */

.global irq15
irq15:

    cli
    //xchg %bx, %bx
    //xchg %bx, %bx
    pushq %rax
    
    // PIC.OCW3 set function to read ISR (In Service Register)
    movb $0x0b, %al
    //movb $0x03, %al
    
    // write to PIC.OCW3
    outb %al, $0xa0
    //outb %al, $0xa3

    // read ISR
    inb $0xa0, %al
    
    // if the in-service register does not have IR7 bit set
    // this would be a spurious interrupt.
    test $0x80, %al
    jz 1f
    
    // mutex for spurious guard
    //bts $0x01, flags
    //jc 1f

    popq %rax

    // normal IRQ-15 routine
    pushq $0     // dummy error code
    pushq $47
    jmp irq_common_stub

1:
    // NOTE: Specific EOI used for master PIC cascade line!!!!
    //movb $0x20, %al
    movb $0x62, %al
    
    // send EOI to slave PIC (clear the ISR flag for IRQ15)
    outb %al, $0x20
    
    popq %rax
    iretq
    

irq_common_stub:
    // If this is from the user space, we need to swap in kernel GS
    cmpq $8, 24(%rsp)
    je push_regs_1
    swapgs

    // Push all registers to the stack
    push_regs_1:
        pushq %rax
        pushq %rbx
        pushq %rcx
        pushq %rdx
        pushq %rsi
        pushq %rdi
        pushq %rbp
        pushq %rsp
        pushq %r8
        pushq %r9
        pushq %r10
        pushq %r11
        pushq %r12
        pushq %r13
        pushq %r14
        pushq %r15
    
    # We need to store the stack pointer in rdi so we can access pushed elements as a struct
    mov %rsp, %rdi
    # Call the handler
    call irq_handler

    # Enable interrupts again
    cli
    # Restore registers
    pop_regs_1:
        popq %r15
        popq %r14
        popq %r13
        popq %r12
        popq %r11
        popq %r10
        popq %r9
        popq %r8
        #popq %rsp
        add $8, %rsp
        popq %rbp
        popq %rdi
        popq %rsi
        popq %rdx
        popq %rcx
        popq %rbx
        popq %rax
    
    cmpq $8, 24(%rsp)
    je 5f
    swapgs

    5:
    # Make error code and isr number overwritable (don't need it no more)
    add $16, %rsp

    // movb $0x20, %al
    // outb %al, $0x20
    # This guy is the reason I had to touch assembly again
    iretq