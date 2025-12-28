#!/bin/sh
set -e

. ./build.sh

# 1. Create a blank disk image (approx 48MB)
DISK_IMG="adios.img"
rm -f $DISK_IMG
dd if=/dev/zero of=$DISK_IMG bs=1M count=48

# 2. Create a Partition Table (MSDOS/MBR) and a Primary Partition
# We use 'parted' to script this easily. 
# It creates an MBR label, makes a primary partition starting at 1MB, and sets the boot flag.
parted -s $DISK_IMG mklabel msdos mkpart primary fat16 1MiB 100% set 1 boot on

# 3. Set up a loop device with partition scanning (-P)
# This creates /dev/loopX and /dev/loopXp1
LOOP_DEV=$(sudo losetup -fP --show $DISK_IMG)
PART_DEV="${LOOP_DEV}p1"

echo "Created loop device: $LOOP_DEV"
echo "Partition: $PART_DEV"

# 4. Format the partition as FAT (using FAT16 is safer for 48MB than FAT12)
sudo mkfs.fat -F 16 $PART_DEV

# 5. Mount the partition
mkdir -p mnt
sudo mount $PART_DEV mnt

# 6. Install Kernel and Config
sudo mkdir -p mnt/boot/grub
sudo cp sysroot/boot/adios.kernel mnt/boot/
# Create the GRUB config directly in the mount
cat << EOF | sudo tee mnt/boot/grub/grub.cfg
menuentry "adios" {
    multiboot /boot/adios.kernel
}
EOF

# 7. INSTALL GRUB
# --target=i386-pc: Standard BIOS boot
# --boot-directory: Where the grub files (fonts, modules) live (in the mounted partition)
# $LOOP_DEV: We install the bootloader to the MBR of the whole disk
echo "Installing GRUB..."
sudo grub-install --target=i386-pc --boot-directory=mnt/boot --modules="part_msdos fat multiboot" $LOOP_DEV

# 8. Cleanup
sudo umount mnt
sudo losetup -d $LOOP_DEV
rm -rf mnt

echo "Success! $DISK_IMG is now bootable."