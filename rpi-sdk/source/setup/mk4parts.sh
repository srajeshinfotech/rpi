#!/bin/bash
#Rajesh Sakkarai

function ver() {
	printf "%03d%03d%03d" $(echo "$1" | tr '.' ' ')
}

if [ -n "$1" ]; then
	DRIVE=$1
else
	echo -e "\nUsage: sudo $0 <device>\n"
	echo -e "Example: sudo $0 /dev/sdb\n"
	exit 1
fi

if [ "$DRIVE" = "/dev/sda" ] ; then
	echo "Sorry, not going to format $DRIVE"
	exit 1
fi


echo -e "\nWorking on $DRIVE\n"

#make sure that the SD card isn't mounted before we start
if [ -b ${DRIVE}1 ]; then
	umount ${DRIVE}1
	umount ${DRIVE}2
	umount ${DRIVE}3
	umount ${DRIVE}4
elif [ -b ${DRIVE}p1 ]; then
	umount ${DRIVE}p1
	umount ${DRIVE}p2
	umount ${DRIVE}p3
	umount ${DRIVE}p4
else
	umount ${DRIVE}
fi

# new versions of sfdisk don't use rotating disk params
sfdisk_ver=`sfdisk --version | awk '{ print $NF }'`

if [ $(ver $sfdisk_ver) -lt $(ver 2.26.2) ]; then
	SIZE=`fdisk -l $DRIVE | grep "$DRIVE" | cut -d' ' -f5 | grep -o -E '[0-9]+'`

	if [ "$SIZE" -lt 3800000000 ]; then
		echo Card size is $SIZE bytes
		echo "Require an SD card of at least 4GB"
		exit 1
	fi

	CYLINDERS=`echo $SIZE/255/63/512 | bc`
	echo "CYLINDERS – $CYLINDERS"
	SFDISK_CMD="sfdisk --force -D -uS -H255 -S63 -C ${CYLINDERS}"
else
	SIZE=`fdisk -l $DRIVE | grep "$DRIVE" | cut -d' ' -f5 | grep -o -E '[0-9]+'`

	if [ "$SIZE" -lt 3800000000 ]; then
		echo Card size is $SIZE bytes
		echo "Require an SD card of at least 4GB"
		exit 1
	fi
	SFDISK_CMD="sfdisk"
fi

echo -e "\nOkay, here we go ...\n"

echo -e "=== Zeroing the MBR ===\n"
dd if=/dev/zero of=$DRIVE bs=1024 count=1024


echo "SIZE - $SIZE. SFDISK_CMD - $SFDISK_CMD"

#For 32 or 32+ GB card - 31914983424
if [ "$SIZE" -gt 30914983424 ]; then #For 32 or 32+ GB card; 30914983424
	# 4 partitions
	# Sectors are 512 bytes
	# 0       : 4MB, no partition, MBR then empty
	# 8192    : 64 MB, FAT partition, bootloader, kernel 
	# 139264  : 6GB, linux partition, root filesystem 1
	# 6430720 : 6GB, linux partition, root filesystem 2
	# 12722176: 12GB+, linux partition, no assigned use

	echo -e "\n=== Creating 4 partitions ===\n"
	{
		echo 8192,131072,0x0C,*
		echo 139264,12587008,0x83,-
		echo 12726272,12498944,0x83,-
		echo 25225216,+,0x83,-
	} | $SFDISK_CMD $DRIVE


elif [ "$SIZE" -gt 14457491712 ]; then #For 16GB card - 15957491712
	# 4 partitions
	# Sectors are 512 bytes
	# 0       : 4MB, no partition, MBR then empty
	# 8192    : 64 MB, FAT partition, bootloader, kernel
	# 139264  : 4GB, linux partition, root filesystem 1
	# 6430720 : 4GB, linux partition, root filesystem 2
	# 12722176: 8GB+, linux partition, no assigned use

	echo -e "\n=== Creating 4 partitions ===\n"
	{
		echo 8192,131072,0x0C,*
		echo 139264,8398848,0x83,-
		echo 8538112,8484864,0x83,-
		echo 17022976,+,0x83,-
	} | $SFDISK_CMD $DRIVE



elif [ "$SIZE" -gt 7078745856 ]; then #For 8GB card - 7978745856
	# 4 partitions
	# Sectors are 512 bytes
	# 0       : 4MB, no partition, MBR then empty
	# 8192    : 64 MB, FAT partition, bootloader, kernel 
	# 139264  : 3GB, linux partition, root filesystem 1
	# 6430720 : 3GB, linux partition, root filesystem 2
	# 12722176: 6GB+, linux partition, no assigned use

	echo -e "\n=== Creating 4 partitions ===\n"
	{
		echo 8192,131072,0x0C,*
		echo 139264,6291456,0x83,-
		echo 6430720,6326272,0x83,-
		echo 12756992,+,0x83,-
	} | $SFDISK_CMD $DRIVE


else #For 4GB card
	# 4 partitions
	# Sectors are 512 bytes
	# 0       : 4MB, no partition, MBR then empty
	# 8192    : 64 MB, FAT partition, bootloader, kernel
	# 139264  : 1.5GB, linux partition, root filesystem 1
	# 6430720 : 1.5GB, linux partition, root filesystem 2
	# 12722176: 3GB+, linux partition, no assigned use

	echo -e "\n=== Creating 4 partitions ===\n"
	{
		echo 8192,131072,0x0C,*
		echo 139264,3211264,0x83,-
		echo 3350528,3125248,0x83,-
		echo 6475776,+,0x83,-
	} | $SFDISK_CMD $DRIVE
fi

sleep 1

echo -e "\n=== Done! ===\n"

