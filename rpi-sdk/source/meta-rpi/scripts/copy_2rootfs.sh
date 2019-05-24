#!/bin/bash

if [ -z "${MACHINE}" ]; then
	echo "Environment variable MACHINE not set"
	echo "Example: export MACHINE=raspberrypi3 or export MACHINE=raspberrypi0-wifi or export MACHINE=raspberrypi0"
	echo "Set default MACHINE=raspberrypi0 OETMP=../../../build/tmp/"
	export MACHINE=raspberrypi0
	export OETMP=../../../build/tmp/
	#exit 1
fi

if [ "x${1}" = "x" ]; then
	echo -e "\nUsage: ${0} <block device> [ <image-type> [<hostname>] ]\n"
	exit 0
fi

#if [ ! -d /media/card ]; then
#	echo "Temporary mount point [/media/card] not found"
#	exit 1
#fi

if [ "x${2}" = "x" ]; then
        IMAGE=console
else
        IMAGE=${2}
fi


if [ -z "$OETMP" ]; then
	echo -e "\nWorking from local directory"
	SRCDIR=.
else
	echo -e "\nOETMP: $OETMP"

	if [ ! -d ${OETMP}/deploy/images/${MACHINE} ]; then
		echo "Directory not found: ${OETMP}/deploy/images/${MACHINE}"
		exit 1
	fi

	SRCDIR=${OETMP}/deploy/images/${MACHINE}
fi 

echo "IMAGE: $IMAGE"

if [ "x${3}" = "x" ]; then
        TARGET_HOSTNAME=$MACHINE
else
        TARGET_HOSTNAME=${3}
fi

echo -e "HOSTNAME: $TARGET_HOSTNAME\n"


if [ "x${4}" = "x" ]; then
	DEFAULT_ROOTFS=../../rootfs/rpi0/
else
        DEFAULT_ROOTFS=${4}
fi

echo -e "DEFAULT_ROOTFS: $DEFAULT_ROOTFS\n"


if [ ! -f "${SRCDIR}/${IMAGE}-image-${MACHINE}.tar.xz" ]; then
        echo "File not found: ${SRCDIR}/${IMAGE}-image-${MACHINE}.tar.xz"
        exit 1
fi

if [ -b ${1} ]; then
	DEV=${1}
else
	DEV=/dev/${1}2

	if [ ! -b $DEV ]; then
		DEV=/dev/${1}p2

		if [ ! -b $DEV ]; then
			echo "Block device not found: /dev/${1}2 or /dev/${1}p2"
			exit 1
		fi
	fi
fi

a=2
while [ $a -lt 4 ]
do
	DEV=/dev/${1}${a}
	echo "Unmount ${DEV}"
	sudo umount ${DEV}
	if [ $a -eq 2 ]
	then
		echo "Create ACTIVE image bank..."
		echo "Formatting ${DEV} as ext4"
		echo -e "y\n" | sudo mkfs.ext4 -q -L ACTIVE ${DEV}
	else
		echo "Create PASSIVE image bank..."
		echo "Formatting ${DEV} as ext4"
		echo -e "y\n" | sudo mkfs.ext4 -q -L PASSIVE ${DEV}
	fi

	if [ "$?" -ne 0 ]; then
		echo "Error formatting ${DEV} as ext4"
		exit 1
	fi

	echo "Mounting ${DEV}"
	mountpath=/media/card${a}
	sudo mkdir -p ${mountpath}
	sudo mount ${DEV} ${mountpath}

	if [ "$?" -ne 0 ]; then
		echo "Error mounting ${DEV} at ${mountpath}"
		exit 1
	fi

	echo "Extracting ${IMAGE}-image-${MACHINE}.tar.xz to ${mountpath}"
	sudo tar --numeric-owner -C ${mountpath} -xJf ${SRCDIR}/${IMAGE}-image-${MACHINE}.tar.xz

	echo "Generating a random-seed for urandom"
	sudo mkdir -p ${mountpath}/var/lib/urandom
	sudo dd if=/dev/urandom of=${mountpath}/var/lib/urandom/random-seed bs=512 count=1
	sudo chmod 600 ${mountpath}/var/lib/urandom/random-seed

	echo "Writing ${TARGET_HOSTNAME} to /etc/hostname"
	export TARGET_HOSTNAME
	sudo -E bash -c 'echo ${TARGET_HOSTNAME} > ${mountpath}/etc/hostname'

	echo "Install the default rootfs to ${mountpath}"
	cp -rf ${DEFAULT_ROOTFS}/* ${mountpath}/

	#if [ -f ${SRCDIR}/interfaces ]; then
	#	echo "Writing interfaces to ${mountpath}/etc/network/"
	#	sudo cp ${SRCDIR}/interfaces ${mountpath}/etc/network/interfaces
	#elif [ -f ./interfaces ]; then
	#	echo "Writing ./interfaces to ${mountpath}/etc/network/"
	#	sudo cp ./interfaces ${mountpath}/etc/network/interfaces
	#fi

	#if [ -f ${SRCDIR}/wpa_supplicant.conf ]; then
	#	echo "Writing wpa_supplicant.conf to ${mountpath}/etc/"
	#	sudo cp ${SRCDIR}/wpa_supplicant.conf ${mountpath}/etc/wpa_supplicant.conf
	#elif [ -f ./wpa_supplicant.conf ]; then
	#	echo "Writing ./wpa_supplicant.conf to ${mountpath}/etc/"
	#	sudo mkdir -p ${mountpath}/etc/wpa_supplicant/
	#	sudo cp ./wpa_supplicant.conf ${mountpath}/etc/wpa_supplicant.conf
	#	sudo cp ./wpa_supplicant.conf ${mountpath}/etc/wpa_supplicant/wpa_supplicant-wlan0.conf
	#	sudo ln -s /lib/systemd/system/wpa_supplicant@.service ${mountpath}/etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service
	#fi

	echo "Unmounting ${DEV}"
	sudo umount ${DEV}
	a=`expr $a + 1`
done

DEV=/dev/${1}4

if [ -b ${DEV} ]; then
	echo "Formatting partition ${DEV} as ext4"
	echo -e "y\n" | sudo mkfs.ext4 -q -L FLASH ${DEV}
fi

echo "Done"
