#!/bin/sh
set -e
. ./iso.sh

show_usage(){
    echo "Usage: $0 [-i | -h]"
    echo "-i Boot using ISO (CD-ROM)"
    echo "-h Boot using disk image (FAT12)"
    exit 1
}

if [ $# -ne 1 ]; then
    show_usage
fi

case "$1" in
    -i)
        . ./iso.sh
        qemu-system-$(./target-triplet-to-arch.sh $HOST) -cdrom adios.iso
        ;;
    -h)
        . ./disk.sh
        qemu-system-$(./target-triplet-to-arch.sh $HOST) -drive format=raw,file=adios.img
        ;;
    *)
        show_usage
        ;;
esac