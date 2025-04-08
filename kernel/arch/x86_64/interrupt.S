.section .text
.code64

# Handler for isr
.extern isr_handler

# Macro for ISR with no error codes
.macro ISR_NO_ERR i
.global isr\i
isr\i:
    push $0 # There is no error code, so just push 0 onto the stack
    push $\i # Push the interrupt number onto the stack so we can identify the interrupt from the common stub
    jmp isr_common_stub # Jump to the common isr stub
.endm

# Macro for ISR with error codes
.macro ISR_ERR i
.global isr\i
isr\i:
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