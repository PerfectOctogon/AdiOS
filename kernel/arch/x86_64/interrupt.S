.section .text
.code64

# Handler for isr
.extern isr_handler

# Macro for ISR with no error codes
.macro ISR_NO_ERR i
.global isr\i
isr\i:
    pushl $0 # There is no error code, so just push 0 onto the stack
    pushl $\num # Push the interrupt number onto the stack so we can identify the interrupt from the common stub
    jmp isr_common_stub # Jump to the common isr stub
.endm

# Macro for ISR with error codes
.macro ISR_ERR i
.global isr\i
isr\i:
    # no need to push the error code onto the stack because the CPU has already done that
    pushl $\num # Push the interrupt number onto the stack so we can identify the interrupt from the common stub
    jmp isr_common_stub # Jump to the common isr stub
.endm

# instantiate the macros for each interrupt
# source : https://wiki.osdev.org/Interrupt_Descriptor_Table
ISR_NOERR 0     # Divide error
ISR_NOERR 1     # Debug exception
ISR_NOERR 2     # NMI interrupt
ISR_NOERR 3     # Breakpoint
ISR_NOERR 4     # Overflow
ISR_NOERR 5     # Bound range exceeded
ISR_NOERR 6     # Invalid opcode
ISR_NOERR 7     # Device not available
ISR_ERR   8     # Double fault
ISR_NOERR 9     # Coprocessor segment overrun
ISR_ERR   10    # Invalid TSS
ISR_ERR   11    # Segment not present
ISR_ERR   12    # Stack-segment fault
ISR_ERR   13    # General protection
ISR_ERR   14    # Page fault
ISR_NOERR 15    # Intel reserved
ISR_NOERR 16    # Floating point error
ISR_ERR   17    # Alignment check
ISR_NOERR 18    # Machine check
ISR_NOERR 19    # SIMD floating point exception
ISR_NOERR 20    # Virtualization exception
ISR_NOERR 21    # control protection exception

# Reserved
ISR_NOERR 22
ISR_NOERR 23
ISR_NOERR 24
ISR_NOERR 25
ISR_NOERR 26
ISR_NOERR 27
ISR_NOERR 28
ISR_NOERR 29
ISR_NOERR 30
ISR_NOERR 31

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
    
    # We need to store the stack pointer in rdi
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