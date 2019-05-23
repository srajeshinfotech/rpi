SUMMARY = "A console development image with some C/C++ dev tools"

IMAGE_FEATURES += "package-management splash"
IMAGE_LINGUAS = "en-us"

DISTRO_FEATURES_append = "systemd"

inherit image

DEPENDS += "bcm2835-bootfiles"

CORE_OS = " \
    kernel-modules \
    packagegroup-core-boot \
    term-prompt \
    tzdata \
"

WIFI_SUPPORT = " \
    crda \
    iw \
    linux-firmware-raspbian \
    wpa-supplicant \
"

DEV_SDK_INSTALL = " \
    binutils \
    binutils-symlinks \
    coreutils \
    cpp \
    cpp-symlinks \
    diffutils \
    elfutils elfutils-binutils \
    file \
    g++ \
    g++-symlinks \
    gcc \
    gcc-symlinks \
    gdb \
    gdbserver \
    gettext \
    git \
    ldd \
    libstdc++ \
    libstdc++-dev \
    libtool \
    ltrace \
    make \
    pkgconfig \
    python3-modules \
    strace \
    nmap \
"

DEV_EXTRAS = " \
    serialecho  \
    spiloop \
"

EXTRA_TOOLS_INSTALL = " \
    bzip2 \
    devmem2 \
    dosfstools \
    ethtool \
    fbset \
    findutils \
    firewall \
    grep \
    i2c-tools \
    iperf3 \
    iproute2 \
    iptables \
    less \
    lsof \
    nano \
    netcat-openbsd \
    ntp ntp-tickadj \
    procps \
    rndaddtoentcnt \
    rng-tools \
    sysfsutils \
    unzip \
    util-linux \
    wget \
    zip \
"

RPI_STUFF = " \
    raspi2fb \
    userland \
"

APRICOT_DEPENDS = " \
    openssh openssh-keygen openssh-sftp-server \
    openssh-scp openssh-ssh openssh-sshd openssh-sftp openssh-misc openssh-dev \
    gnupg librepo curl mosquitto wiringpi glib-2.0 sqlite3 opie-deco-liquid systemd-machine-units dpkg ncurses \
    opencv libopencv-core libopencv-imgproc libopencv-core-dev opencv-apps gstreamer1.0-libav python3-pip libpipeline \
    libcurl curl-dev \
    libopencv-core-dev opencv-apps opencv-dev libopencv-imgproc-dev libopencv-objdetect-dev libopencv-ml-dev \
    wiringpi \
"

IMAGE_INSTALL += " \
    ${CORE_OS} \
    ${EXTRA_TOOLS_INSTALL} \
    ${RPI_STUFF} \
    ${WIFI_SUPPORT} \
    ${APRICOT_DEPENDS} \
    ${DEV_SDK_INSTALL} \
"

set_local_timezone() {
    ln -sf /usr/share/zoneinfo/EST5EDT ${IMAGE_ROOTFS}/etc/localtime
}

disable_bootlogd() {
    echo BOOTLOGD_ENABLE=no > ${IMAGE_ROOTFS}/etc/default/bootlogd
}


remove_unwanted_files() {
    rm -rf ${IMAGE_ROOTFS}/usr/bin/.debug
    rm -rf ${IMAGE_ROOTFS}/usr/sbin/.debug
    rm -rf ${IMAGE_ROOTFS}/usr/libexec/.debug
    rm -rf ${IMAGE_ROOTFS}/usr/lib/audit/.debug
    rm -rf ${IMAGE_ROOTFS}/usr/lib/.debug
    rm -rf ${IMAGE_ROOTFS}/sbin/.debug
    rm -rf ${IMAGE_ROOTFS}/lib/.debug
    rm -rf ${IMAGE_ROOTFS}/usr/share/ca-certificates/
    rm -rf ${IMAGE_ROOTFS}/usr/src/debug/
    rm -rf ${IMAGE_ROOTFS}/usr/include/
}

ROOTFS_POSTPROCESS_COMMAND += " \
    set_local_timezone ; \
    disable_bootlogd ; \
"

export IMAGE_BASENAME = "console-image"
