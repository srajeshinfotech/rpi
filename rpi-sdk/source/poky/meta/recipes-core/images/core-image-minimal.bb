SUMMARY = "A small image just capable of allowing a device to boot."

APRICOT_DEPENDS = " \
    g++ \
    wiringpi \
    openssh openssh-sshd openssh-keygen openssh-sftp-server \
    gnupg librepo curl glib-2.0 systemd-machine-units \
    libcurl \
    libxml2-utils libxml2 \
    sqlite3 \
    opencv \
"

WIFI_SUPPORT = " \
    crda \
    iw \
    linux-firmware-raspbian \
    wpa-supplicant \
"


IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL} ${APRICOT_DEPENDS} ${WIFI_SUPPORT}"

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "" ,d)}"
