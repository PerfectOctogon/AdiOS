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
.code32
# Reserve a stack for the initial thread.
.section .bss
.align 16
stack_bottom:
.skip 16384 # 16 KiB
stack_top:

# The kernel entry point.
.section .text
.global _start
.type _start, @function
.extern long_mode_start
.extern _init
_start:
	movl $stack_top, %esp
	
	# Call the global constructors.
	call _init
	# Lets check for cpuid
	call checkcpuid

	# Lets check for extended functionality
	call checkextfunc

	# Now, lets set up page tables
	call setup_pagetables

	# Now, we can enable paging
	call enable_pae_paging

	jmp long_mode_start

	hlt
.size _start, . - _start

# Check if CPUID exists
checkcpuid:
	pushf # Dump CPU flags into the stack
	pop %eax # Pop the flags into the EAX register
	mov %eax, %ecx # Storing a copy of these flags so we don't end up modifying the CPU flags
	xor %eax, 1 << 21 # Flipping the 21st bit. If we can flip this, we can use CPUID
	push %eax # Push the modified flags into the stack
	popf # Put the modified flags into the CPU flags register
	pushf # Lets check if the bit was flipped and restore the flags
	pop %eax
	push %ecx # ECX contains our original copy of our flags
	popf # Restore the flags
	cmp %eax, %ecx # Let's compare EAX and ECX
	jz .nocpuid # If zero flag was set, then the bit was not flipped, so jump to nocpuid error
	ret

# Check if extended functionality exists
checkextfunc:
	mov %eax, 0x80000000 # Function number for querying extended functionality
	cpuid
	cmp %eax, 0x80000001 # Check if EAX got larger
	jb .noextfunc

	mov %eax, 0x80000001
	cpuid # This will now store various CPU information into different registers
	test %edx, 1 << 29 # Checking the 30th youngest bit of the EDX register to see if we have long mode support
	jz .nolongmode # If it's 0, we don't have long mode support
	ret

setup_pagetables:
	movl $0x2003, 0x1000 # point to the PDPT with flags
	movl $0x3003, 0x2000 # Move up 4 KB
	movl $0x4003, 0x3000 # We have now set up the page table, we need to fill it up

	mov 0, %ecx # Set up the counter
	# Creating the identity map
	idmap:
		mov $4096, %eax # move the page size to the EAX register
		mul %ecx
		or %eax, 0x83
		leal 0x3000(, %ecx, 8), %ebx
		movl %eax, (%ebx)
		inc %ecx
		cmp %ecx, 512
		jne idmap
	
	ret

enable_pae_paging:
	mov %eax, 0x1000 # Address of the PML4T
	mov %cr3, %eax # Move this address to the control register 3
	# Now the cr3 register knows where our PML4T is

	enter_long_mode:
		mov %ecx, 0xC0000080 # Move model specific register into ECX
		rdmsr # Write the register value into EAX
		or %eax, 1 << 8 # Set 8th bit, which is responsible for enabling long mode when we enable paging
		wrmsr # Write to the model specific register
	
	enable_paging:
		mov %eax, %cr0
		or %eax, 1 << 31 # Flipping the oldest bit in control register 0
		mov %cr0, %eax
	
	# Paging is now enabled !!!!!!!!! :D
	ret

.nocpuid:
	mov %al, 'C'
	jmp error

.noextfunc:
	mov %al, 'E'
	jmp error

.nolongmode:
	mov %al, 'L'
	jmp error

error:
    movl $0x4f524f45, 0xb8000
    movl $0x4f3a4f52, 0xb8004
    movl $0x4f204f20, 0xb8008
    movb %al, 0xb800a
    hlt