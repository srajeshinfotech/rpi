#!/bin/bash
if [ "x${1}" = "x" ]; then
	echo -e "\nUsage: ${0} <block device> [ <tar file> ]\n"
	exit 0
fi

if [ -z "${MACHINE}" ]; then
	echo "Environment variable MACHINE not set"
	echo "Example: export MACHINE=raspberrypi3 or export MACHINE=raspberrypi0-wifi or export MACHINE=raspberrypi0"
	echo "Set default MACHINE=raspberrypi0"
	export MACHINE=raspberrypi0
fi


if [ -z "${IMAGE}" ]; then
        IMAGE=console
fi
echo "IMAGE: $IMAGE"


if [ -z "${OETMP}" ]; then
        export OETMP=../../../build/tmp/
fi
echo "OETMP: $OETMP"

SRCDIR=${OETMP}/deploy/images/${MACHINE}

if [ "x${2}" = "x" ]; then
        TAR_FILE_PATH=${SRCDIR}/${IMAGE}-image-${MACHINE}.tar.xz
else
        TAR_FILE_PATH=${2}
fi

echo -e "TAR_FILE_PATH: $TAR_FILE_PATH\n"


if [ ! -f "${TAR_FILE_PATH}" ]; then
        echo "File not found: ${TAR_FILE_PATH}"
        exit 1
fi

_DEV=${1}

if [ ! -b ${_DEV}2 ]; then
	_DEV=${1}p

	if [ ! -b ${_DEV}2 ]; then
		echo "Block device not found: ${1}2 or ${1}p2"
		exit 1
	fi
fi

a=2
while [ $a -lt 4 ]
do
	DEV=${_DEV}${a}
	if [ ! -b $DEV ]; then
		echo "Block device not found: $DEV"
		exit 1
	fi
	echo "Unmount ${DEV}"
	sudo umount ${DEV}
	if [ $a -eq 2 ]
	then
		echo "Create ACTIVE image bank..."
		echo "Formatting ${DEV} as ext4"
		echo -e "y\n" | sudo mkfs.ext4 -q -L active ${DEV}
	else
		echo "Create PASSIVE image bank..."
		echo "Formatting ${DEV} as ext4"
		echo -e "y\n" | sudo mkfs.ext4 -q -L passive ${DEV}
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

	sudo rm -rf ${mountpath}/* 2> /dev/null
	echo "Extracting ${TAR_FILE_PATH} to ${mountpath}"
	sudo tar --numeric-owner -C ${mountpath} -xJf ${TAR_FILE_PATH} --no-same-owner

	echo "Generating a random-seed for urandom"
	sudo mkdir -p ${mountpath}/var/lib/urandom
	sudo dd if=/dev/urandom of=${mountpath}/var/lib/urandom/random-seed bs=512 count=1
	sudo chmod 600 ${mountpath}/var/lib/urandom/random-seed

	echo "Unmounting ${DEV}"
	sudo umount ${DEV}
	a=`expr $a + 1`
done

DEV=${_DEV}4

if [ -b ${DEV} ]; then
	echo "Formatting partition ${DEV} as ext4"
	echo -e "y\n" | sudo mkfs.ext4 -q -L storage ${DEV}
fi

echo "Done"
