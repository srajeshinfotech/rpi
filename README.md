# RPI
This repo shall used to build the RPI0 sdk using Yocto build framework

To Build:-
-------------------------------------
cd RPI/rpi-sdk
source setup-release.sh -b build

bitbake console-image -c cleansstate

bitbake console-image -v -D

-------------------------------------

To make iso image:-
-------------------------------------
cd RPI/rpi-sdk/build

./rpi0-sdk.sh

-------------------------------------


To flash the image into SD card:-
-------------------------------------
cd RPI/rpi-sdk/source/setup

./install.sh <device path> <bootloader> <os>
  
ex:- ./install.sh /dev/sdb ../../build/bootloader-rpi0.tar.xz ../../build/os-rpi0.tar.xz

-------------------------------------
