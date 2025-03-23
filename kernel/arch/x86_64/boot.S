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

	# Now, we can enable paging
	call enable_pae_paging
	
	.code64
	load_gdt:
	lgdt .pointer
	movabsq $long_mode_start, %rax
	// movabs
	call *%rax
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

	movl $0x2003, 0x1000 # point to the PDPT with flags
	movl $0x3003, 0x2000 # Move up 4 KB
	movl $0x4003, 0x3000 # We have now set up the page table, we need to fill it up
	xor %ecx, %ecx # Zero out ecx
	# Creating the identity map
	.idmap:
		mov $4096, %eax # move the page size to the EAX register
		mul %ecx # multiple current page index to eax. Beginning will be 0, of course. So, starting at index 0
		movl %edx, %eax # Bruh, so apparently mul stores result into edx ;-;, we we're moving it into eax
		or $0x83, %eax # Setting flags
		movl %eax, 0x3000(,%ecx,8)
		inc %ecx
		cmp $0x200, %ecx
		jne .idmap
	ret
enable_pae_paging:
	mov $0x1000, %eax # Address of the PML4T
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
		mov %eax, %cr0 # TO:DO PAGING NOT WORKING!!! CANNOT WRITE TO CR0
	
	# Paging is now enabled !!!!!!!!! :D
	jmp load_gdt

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

# 64-bit Global Descriptor Table
.section .rodata
gdt64:
    .quad 0

.code_segment: 
    .equ code_segment, . - gdt64
    .quad (1 << 44) | (1 << 47) | (1 << 41) | (1 << 43) | (1 << 53)

.data_segment: 
    .equ data_segment, . - gdt64
    .quad (1 << 44) | (1 << 47) | (1 << 41)

.pointer:
    .word gdt64_end - gdt64 - 1
    .quad gdt64

gdt64_end:

