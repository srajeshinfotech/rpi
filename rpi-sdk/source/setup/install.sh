#!/bin/sh
#Rajesh Sakkarai

if [ "$#" -ne 3 ]; then
    echo -n "\nusage:-  $0 <device> <bootloader.tar> <aicam.tar>\n\n"
    echo -n "example:- $0 /dev/sdb aicambootloader.tar.xz aicam.tar.xz\n\n"
    exit 1
fi

if [ ! -e "$1" ]; then
    echo "Error: File not found - $1"
    exit 1
elif [ ! -e "$2" ]; then
    echo "Error: File not found - $2"
    exit 1
elif [ ! -e "$3" ]; then
    echo "Error: File not found - $3"
    exit 1
fi

./mk4parts.sh $1
./copy_boot.sh $1 $2
if [ $? -ne 0 ]; then
    echo "Error while flashing the bootloader"
    exit 1
fi
./copy_2rootfs.sh $1 $3

fdisk  -l $1
echo "!!! AICAM Image flashed successfully into the SD card !!!"
