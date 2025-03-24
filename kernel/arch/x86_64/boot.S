# Declare constants for the multiboot header.
.set ALIGN,    1<<0             # align loaded modules on page boundaries
.set MEMINFO,  1<<1             # provide memory map
.set FLAGS,    ALIGN | MEMINFO  # this is the Multiboot 'flag' field
.set MAGIC,    0x1BADB002       # 'magic number' lets bootloader find the header
.set CHECKSUM, -(MAGIC + FLAGS) # checksum of above, to prove we are multiboot

# Declare a header as in the Multiboot Standard.
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM


# The kernel entry point.
.section .text
.global _start
.type _start, @function
.extern long_mode_start

.code32
_start:
	movl $stack_top, %esp
	# Call the global constructors.
	# call _init Not writing C++ code right now, so don't need to call the global constructors! (Also this doesn't really work right now)
	# Lets check for cpuid
	call checkcpuid

	# Lets check for extended functionality
	call checkextfunc

	# Now, lets set up page tables
	call setup_pagetables

	# Enable SSE
	call set_sse

	# Now, we can enable paging
	jmp enable_pae_paging
	
	load_gdt:
	mov $(null_gdtr), %eax
    lgdt (%eax)
	
    ljmp $0x08, $long_mode_start # Long jump into the 64-bit kernel


	.code64
	.align 8
	null_gdtr:
		.word null_gdt_end - null_gdt_base
		.quad null_gdt_base

	null_gdt_base:
		.quad 0
		.word 0
		.word 0
		.byte 0
		.byte 0x9a
		.byte 0x20
		.byte 0
		.word 0xffff
		.word 0
		.byte 0
		.byte 0x92
		.byte 0
		.byte 0
	null_gdt_end:
	hlt
.size _start, . - _start

.code32
# Check if CPUID exists
checkcpuid:
	pushf # Dump CPU flags into the stack
	popl %eax # Pop the flags into the EAX register
	movl %eax, %ecx # Storing a copy of these flags so we don't end up modifying the CPU flags
	xor $(1 << 21), %eax # Flipping the 21st bit. If we can flip this, we can use CPUID
	pushl %eax # Push the modified flags into the stack
	popf # Put the modified flags into the CPU flags register
	pushf # Lets check if the bit was flipped and restore the flags
	popl %eax
	pushl %ecx # ECX contains our original copy of our flags
	popf # Restore the flags
	cmpl %eax, %ecx # Let's compare EAX and ECX
	jz .nocpuid # If zero flag was set, then the bit was not flipped, so jump to nocpuid error
	ret

# Check if extended functionality exists
checkextfunc:
	mov $0x80000000, %eax # Function number for querying extended functionality
	cpuid
	cmp $0x80000001, %eax # Check if EAX got larger
	jb .noextfunc

	mov $0x80000001, %eax
	cpuid # This will now store various CPU information into different registers
	test $(1 << 29), %edx # Checking the 30th youngest bit of the EDX register to see if we have long mode support
	jz .nolongmode # If it's 0, we don't have long mode support
	ret

setup_pagetables:
	# Temporarily disable paging
	mov %cr0, %eax
	and $~(1 << 31), %eax # Reset the oldest bit in control register 0
	mov %eax, %cr0

	setup_page_tables:
    # Load address of page_table_l3 into %eax
    movl $pdpt, %eax
    orl $0b11, %eax              # Present, writable
    movl %eax, pml4t      # Store in L4 table

    # Load address of page_table_l2 into %eax
    movl $pd, %eax
    orl $0b11, %eax              # Present, writable
    movl %eax, pdpt      # Store in L3 table

    xorl %ecx, %ecx              # Zero out ECX counter

	.loop:
		movl $0x200000, %eax         # Load 2MB page size
		mull %ecx                    # Multiply by ECX (EDX:EAX result)
		orl $0b10000011, %eax        # Present, writable, huge page flag
		movl %eax, pd(,%ecx,8) # Store at page_table_l2 + ECX * 8
		incl %ecx                    # Increment ECX
		cmpl $512, %ecx              # Check if whole table is mapped
		jne .loop                    # If not, continue loop
	ret

enable_pae_paging:
	mov $pml4t, %eax # Address of the PML4T
	mov %eax, %cr3 # Move this address to the control register 3

	mov %cr4, %eax # Enable PAE paging
	or $(1 << 5), %eax
	mov %eax, %cr4

	# Now the cr3 register knows where our PML4T is
	.enter_long_mode:
		mov $0xC0000080, %ecx # Move model specific register into ECX
		rdmsr # Write the register value into EAX
		or $(1 << 8), %eax # Set 8th bit, which is responsible for enabling long mode when we enable paging
		wrmsr # Write to the model specific register
	
	.enable_paging:
		mov %cr0, %eax
		or $(1 << 31), %eax # Flipping the oldest bit in control register 0
		mov %eax, %cr0
	
	# Paging is now enabled !!!!!!!!! :D
	jmp load_gdt

set_sse:
	mov %cr0, %eax
	and $0xfffb, %ax # Clear coprocessor emulation CR).EM
	or $0x2, %ax # Set coprocessor monitoring CR0.MP
	mov %eax, %cr0
	or $(3 << 9), %ax # Set CR4.OSFXSR and CR$.OSXMMEXCPT at the same time
	mov %eax, %cr4
	ret

.nocpuid:
	movb $'C', %al
	jmp error

.noextfunc:
	movb $'E', %al
	jmp error

.nolongmode:
	movb $'L', %al
	jmp error

error:
    movl $0x4f524f45, 0xb8000
    movl $0x4f3a4f53, 0xb8004
    movl $0x4f204f20, 0xb8008
    mov %al, 0xb800a
    hlt

# Reserve a stack for the initial thread.
.section .bss
.align 16
gdtr_dump:
	.skip 10

.align 4096
pml4t:
	.space 4096
pdpt:
	.space 4096
pd:
	.space 4096

stack_bottom:
.skip 16384 # 16 KiB
stack_top:
