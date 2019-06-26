#!/bin/sh
#Rajesh Sakkarai

PREFIX="./tmp/deploy/images/raspberrypi0/";
MACHINE="raspberrypi0"

#============================== BOOTLOADER =================================

BL_DST="./bootloader"
rm -rf ${BL_DST} 2> /dev/null;
mkdir -p ${BL_DST};
BOOTLOADER_TAR="bootloader-rpi0$1.tar"
BOOTLOADER_TAR_XZ="bootloader-rpi0$1.tar.xz"

rm -rf $BOOTLOADER_TAR $BOOTLOADER_TAR_XZ 2> /dev/null

#copy bootloader files into BL_DST location
DTBS="bcm2708-rpi-0-w.dtb \
              bcm2708-rpi-b.dtb \
              bcm2708-rpi-b-plus.dtb \
              bcm2708-rpi-cm.dtb"

BOOTLDRFILES="bootcode.bin \
              cmdline.txt \
              config.txt \
              fixup_cd.dat \
              fixup.dat \
              fixup_x.dat \
              start_cd.elf \
              start.elf \
              start_x.elf"

SRCDIR=$PREFIX
cp -rf ${SRCDIR}/bcm2835-bootfiles/* $BL_DST

mkdir -p $BL_DST/overlays
echo 'Copying overlay dtbos'
for f in $( ls ${SRCDIR}/*.dtbo | grep -v -e "-${MACHINE}" )
do
    if [ -L ${f} ]; then
        cp ${f} $BL_DST/overlays
    fi
done

echo "Copying dtbs"
for f in ${DTBS}; do
    if [ -f ${SRCDIR}/${f} ]; then
        cp ${SRCDIR}/${f} $BL_DST
    fi
done

echo "Copying kernel"
KERNEL_IMAGETYPE=zImage
cp ${SRCDIR}/${KERNEL_IMAGETYPE} $BL_DST/

if [ -f ${SRCDIR}/u-boot.bin ]; then
    echo "Copying u-boot.bin to card"
    cp ${SRCDIR}/u-boot.bin $BL_DST

    if [ -f ${SRCDIR}/boot.scr ]; then
        echo "Copying boot.scr to card"
        cp ${SRCDIR}/boot.scr $BL_DST
    else
        echo "WARNING: No boot script found!"
    fi
fi

#finally copy the custom files
echo "Copying the custom bootloader configurations"
cp -rf ../source/bootloader/rpi0/* $BL_DST

#make bootloader tar
echo "create bootloader tar file - $BOOTLOADER_TAR_XZ"
tar --numeric-owner -cf $BOOTLOADER_TAR -C ${BL_DST} .
xz -T 0 $BOOTLOADER_TAR
rm -rf ${BL_DST} $BOOTLOADER_TAR

#================================================================================


#=================================== ROOTFS =====================================
DST="./single";
rm -rf ${DST} 2> /dev/null;
mkdir -p ${DST};

tar -xvJf ${PREFIX}/console-image-raspberrypi0.tar.xz  -C ${DST}/

echo "Copying the custom rootfs from ../source/rootfs/rpi0/"
cp -rf ../source/rootfs/rpi0/* ${DST}/

IMAGE_PREFIX="os-rpi0$1"
FIRMWARE_TAR="$IMAGE_PREFIX.tar"
FIRMWARE_TAR_XZ="$IMAGE_PREFIX.tar.xz"
FIRMWARE_TAR_XZ_GPG="$IMAGE_PREFIX.tar.xz.gpg"
rm -rf $FIRMWARE_TAR $FIRMWARE_TAR_XZ $FIRMWARE_TAR_XZ_GPG 2> /dev/null

echo "Create new tar ball"
tar --numeric-owner -cf $FIRMWARE_TAR -C ${DST} .
echo "This might take few mins. So please wait.."
xz -T 0 $FIRMWARE_TAR

echo 'my@system' > /tmp/.magic

#create the encrypted tar
gpg --batch --passphrase-file=/tmp/.magic  -o $FIRMWARE_TAR_XZ_GPG --symmetric $FIRMWARE_TAR_XZ
rm -rf /tmp/.magic

mv $FIRMWARE_TAR_XZ_GPG $IMAGE_PREFIX.iso

rm -rf ${DST};
#======================================================================================

echo "================================================="
echo "OS TAR file - $FIRMWARE_TAR_XZ"
echo "================================================="

