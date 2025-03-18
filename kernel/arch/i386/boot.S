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
_start:
	movl $stack_top, %esp

	# Call the global constructors.
	call _init

	# Lets check for cpuid
	call checkcpuid

	# Transfer control to the main kernel.
	call kernel_main

	# Hang if kernel_main unexpectedly returns.
	cli
1:	hltha
	jmp 1b
.size _start, . - _start

# Check if CPUID exists
checkcpuid:
	pushfd # Dump CPU flags into the stack
	pop eax # Pop the flags into the EAX register
	mov ecx, eax # Storing a copy of these flags so we don't end up modifying the CPU flags
	xor eax, 1 << 21 # Flipping the 21st bit. If we can flip this, we can use CPUID
	push eax # Push the modified flags into the stack
	popfd # Put the modified flags into the CPU flags register
	pushfd # Lets check if the bit was flipped and restore the flags
	pop eax
	push ecx # ECX contains our original copy of our flags
	popfd # Restore the flags
	cmp eax, ecx # Let's compare EAX and ECX
	jz .nocpuid # If zero flag was set, then the bit was not flipped, so jump to nocpuid error
	ret

# Check if extended functionality exists
checkextfunc:
	mov eax, 0x80000000 # Function number for querying extended functionality
	cpuid
	cmp eax, 0x80000001 # Check if EAX got larger
	jb .noextfunc

	mov eax, 0x80000001
	cpuid # This will now store various CPU information into different registers
	test edx, 1 << 29 # Checking the 30th youngest bit of the EDX register to see if we have long mode support
	jz .nolongmode # If it's 0, we don't have long mode support

.nocpuid:
	mv al, "C"
	jmp error

.noextfunc:
	mv al, "E"
	jmp error

.nolongmode:
	mv al, "L"
	jmp error

error:
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte [0xb800a], al
    hlt