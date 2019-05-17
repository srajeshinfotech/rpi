#!/bin/sh

PREFIX="./tmp/deploy/images/imx6ull14x14evk";

DST="./single";

rm -rf ${DST};

mkdir -p ${DST};

cp ${PREFIX}/zImage                                     ${DST};

cp ${PREFIX}/zImage-imx6ull-14x14-evk-gpmi-weim.dtb     ${DST};

cp ${PREFIX}/LG-1000-SDK-image-imx6ull14x14evk.tar.bz2  ${DST}/core-image-base-imx6ull14x14evk.tar.bz2

tar zcf single.tar.gz ${DST};

echo "rp!0!m@ge" > singleImage.fw
cat single.tar.gz       >> singleImage.fw

rm -rf single.tar.gz ${DST};
