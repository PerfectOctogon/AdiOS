DEFAULT_HOST != ../default-host.sh
HOST ?= $(DEFAULT_HOST)
HOSTARCH != ../target-triplet-to-arch.sh $(HOST)

CFLAGS = -c -O2 -g -I -m32
CPPFLAGS ?=
LDFLAGS ?=
LIBS ?=

DESTDIR ?=
PREFIX ?= /usr/local
EXEC_PREFIX ?= $(PREFIX)
BOOTDIR ?= $(EXEC_PREFIX)/boot
INCLUDEDIR ?= $(PREFIX)/include

CFLAGS := $(CFLAGS) -ffreestanding -Wall -Wextra
CPPFLAGS := $(CPPFLAGS) -D__is_kernel -Iinclude
LDFLAGS := $(LDFLAGS)
LIBS := $(LIBS) -nostdlib -lk -lgcc

ARCHDIR = arch/$(HOSTARCH)

$(info HOST=$(HOST))
$(info HOSTARCH=$(HOSTARCH))
$(info ARCHDIR=$(ARCHDIR))

include $(ARCHDIR)/make.config

CFLAGS := $(CFLAGS) $(KERNEL_ARCH_CFLAGS)
CPPFLAGS := $(CPPFLAGS) $(KERNEL_ARCH_CPPFLAGS)
LDFLAGS := $(LDFLAGS) $(KERNEL_ARCH_LDFLAGS)
LIBS := $(LIBS) $(KERNEL_ARCH_LIBS)

# Find source files
KERNEL_C_SOURCE_FILES := $(shell find kernel -name '*.c')
KERNEL_ASM_SOURCE_FILES := $(shell find kernel -name '*.S')

# Convert source files to object files
KERNEL_C_OBJECT_FILES := $(patsubst kernel/%.c, build/kernel/%.o, $(KERNEL_C_SOURCE_FILES))
KERNEL_ASM_OBJECT_FILES := $(patsubst kernel/%.S, build/kernel/%.o, $(KERNEL_ASM_SOURCE_FILES))

KERNEL_OBJS = \
    $(KERNEL_ARCH_OBJS) \
    $(KERNEL_C_OBJECT_FILES) \
    $(KERNEL_ASM_OBJECT_FILES)

OBJS = \
    $(ARCHDIR)/crti.o \
    $(ARCHDIR)/crtbegin.o \
    $(KERNEL_OBJS) \
    $(ARCHDIR)/crtend.o \
    $(ARCHDIR)/crtn.o

LINK_LIST = \
    $(LDFLAGS) \
    $(ARCHDIR)/crti.o \
    $(ARCHDIR)/crtbegin.o \
    $(KERNEL_OBJS) \
    $(LIBS) \
    $(ARCHDIR)/crtend.o \
    $(ARCHDIR)/crtn.o

.PHONY: all clean install install-headers install-kernel
.SUFFIXES: .o .c .S

all: adios.kernel

adios.kernel: $(OBJS) $(ARCHDIR)/linker.ld
	$(CC) -T $(ARCHDIR)/linker.ld -o $@ $(CFLAGS) $(LINK_LIST)
	grub-file --is-x86-multiboot adios.kernel

# Compile C files
build/kernel/%.o: kernel/%.c
	mkdir -p $(dir $@)
	$(CC) -MD -c $< -o $@ -std=gnu11 $(CFLAGS) $(CPPFLAGS)

# Compile Assembly files (.S) using the C compiler
build/kernel/%.o: kernel/%.S
	mkdir -p $(dir $@)
	$(CC) -MD -c $< -o $@ $(CFLAGS) $(CPPFLAGS)

clean:
	rm -f adios.kernel
	rm -f $(OBJS) *.o */*.o */*/*.o
	rm -f $(OBJS:.o=.d) *.d */*.d */*/*.d

install: install-headers install-kernel

install-headers:
	mkdir -p $(DESTDIR)$(INCLUDEDIR)
	cp -R --preserve=timestamps include/. $(DESTDIR)$(INCLUDEDIR)/.

install-kernel: adios.kernel
	mkdir -p $(DESTDIR)$(BOOTDIR)
	cp adios.kernel $(DESTDIR)$(BOOTDIR)

-include $(OBJS:.o=.d)
