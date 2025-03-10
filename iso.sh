#!/bin/sh
set -e
. ./build.sh

mkdir -p isodir
mkdir -p isodir/boot
mkdir -p isodir/boot/grub

cp sysroot/boot/adios.kernel isodir/boot/adios.kernel
cat > isodir/boot/grub/grub.cfg << EOF
menuentry "adios" {
	multiboot /boot/adios.kernel
}
EOF
grub-mkrescue -o adios.iso isodir