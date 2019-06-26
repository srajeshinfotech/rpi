SUMMARY = "A console development image with some C/C++ dev tools"

IMAGE_FEATURES += "package-management splash"
IMAGE_LINGUAS = "en-us"

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
"


_DEV_SDK_INSTALL = " \
    binutils \
    binutils-symlinks \
    coreutils \
    cpp \
    cpp-symlinks \
    diffutils \
    elfutils elfutils-binutils \
    gcc \
    gcc-symlinks \
    ldd \
    g++-symlinks \
    gdb \
    gdbserver \
    gettext \
    libstdc++ \
    libstdc++-dev \
    libtool \
    ltrace \
    make \
    pkgconfig \
    gawk \
    autoconf \
    git \
    curl-dev \
    openssl-dev \
    cmake \
    libxml2-dev \
    opencv-dev libopencv-core libopencv-core-dev \
    mosquitto-dev \
    mosquitto \
    librepo \
    wiringpi \
"

EXTRA_TOOLS_INSTALL = " \
    iptables \
    ntp \
    ntp-tickadj \
    file \
"

UNUSED_TOOLS = " \
    serialecho  \
    spiloop \
    lsof \
    less \
    grep \
    wget \
    zip \
    unzip \
    util-linux \
    i2c-tools \
    iperf3 \
    iproute2 \
    bzip2 \
    devmem2 \
    dosfstools \
    ethtool \
    fbset \
    findutils \
    firewall \
    netcat-openbsd \
    procps \
    rndaddtoentcnt \
    rng-tools \
    sysfsutils \
    nmap \
    xmlto \
    usbinit \
    nano \
    libopencv-imgproc libopencv-imgproc-dev libopencv-objdetect-dev libopencv-ml-dev opencv-apps gstreamer1.0-libav \
    python3-modules python3-pip libpipeline \
    strace \
    dhcp-server \
    dhcp-client \
    dpkg \
    ncurses \
    openssh-ssh \
    openssh-misc openssh-dev \
    openssh-scp openssh-sftp \
    opie-deco-liquid \
    libcurl \
    libxml2-utils libxml2 \
    sqlite3 \
    opencv \
"

RPI_STUFF = " \
"


_RPI_STUFF = " \
    raspi2fb \
    userland \
"

MY_APP_DEPENDS = " \
    g++ \
    openssh openssh-sshd openssh-keygen openssh-sftp-server \
    gnupg glib-2.0 systemd-machine-units \
"

IMAGE_INSTALL += " \
    ${CORE_OS} \
    ${EXTRA_TOOLS_INSTALL} \
    ${RPI_STUFF} \
    ${WIFI_SUPPORT} \
    ${MY_APP_DEPENDS} \
    ${DEV_SDK_INSTALL} \
"

set_local_timezone() {
    ln -sf /usr/share/zoneinfo/Asia/Tokyo ${IMAGE_ROOTFS}/etc/localtime
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
    rm -rf ${IMAGE_ROOTFS}/usr/src/
    rm -rf ${IMAGE_ROOTFS}/usr/include/
    rm -rf ${IMAGE_ROOTFS}/var/lib/opkg/info/
    rm -rf ${IMAGE_ROOTFS}/usr/share/OpenCV/haarcascades/
}

ROOTFS_POSTPROCESS_COMMAND += " \
    set_local_timezone ; \
    disable_bootlogd ; \
    remove_unwanted_files ; \
"

export IMAGE_BASENAME = "console-image"
