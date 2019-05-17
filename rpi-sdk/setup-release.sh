#!/bin/sh
#

CWD=`pwd`
PROGNAME="setup-environment"
exit_message ()
{
   echo "To return to this build environment later please run:"
   echo "    source setup-environment <build_dir>"

}

usage()
{
    echo -e "\nUsage: source $0
    Optional parameters: [-b build-dir] [-h]"
echo "
    * [-b build]: Build directory, if unspecified script uses 'build' as output directory
    * [-h]: help
"
}


clean_up()
{

    unset CWD BUILD_DIR BACKEND 
    unset setup_help setup_error setup_flag
    unset usage clean_up
    unset ARM_DIR META_FSL_BSP_RELEASE
    exit_message clean_up
}

# get command line options
OLD_OPTIND=$OPTIND

while getopts "b:gh" fsl_setup_flag
do
    case $fsl_setup_flag in
        b) BUILD_DIR="$OPTARG";
           echo -e "\n Build directory is " $BUILD_DIR
           ;;
        h) setup_help='true';
           ;;
        ?) setup_error='true';
           ;;
    esac
done

OPTIND=$OLD_OPTIND

# check the "-h" and other not supported options
if test $fsl_setup_error || test $fsl_setup_help; then
    usage && clean_up && return 1
fi

if [ -z "$BUILD_DIR" ]; then
    BUILD_DIR='build'
fi

if [ -z "$MACHINE" ]; then
    MACHINE='raspberrypi0'
    echo setting to default machine $MACHINE
fi

echo "$MACHINE . ./$PROGNAME $BUILD_DIR"

# Set up the basic yocto environment
MACHINE=$MACHINE . ./$PROGNAME $BUILD_DIR

# Point to the current directory since the last command changed the directory to $BUILD_DIR
BUILD_DIR=.

if [ ! -e $BUILD_DIR/conf/local.conf ]; then
    echo -e "\n ERROR - No build directory is set yet. Run the 'setup-environment' script before running this script to create " $BUILD_DIR
    echo -e "\n"
    return 1
fi

# On the first script run, backup the local.conf file
# Consecutive runs, it restores the backup and changes are appended on this one.
if [ ! -e $BUILD_DIR/conf/local.conf.org ]; then
    cp $BUILD_DIR/conf/local.conf $BUILD_DIR/conf/local.conf.org
else
    cp $BUILD_DIR/conf/local.conf.org $BUILD_DIR/conf/local.conf
fi


if [ ! -e $BUILD_DIR/conf/bblayers.conf.org ]; then
    cp $BUILD_DIR/conf/bblayers.conf $BUILD_DIR/conf/bblayers.conf.org
else
    cp $BUILD_DIR/conf/bblayers.conf.org $BUILD_DIR/conf/bblayers.conf
fi


META_FSL_BSP_RELEASE="${CWD}/source/meta-fsl-bsp-release/imx/meta-bsp"

CUR_PWD=`pwd`
BUILDPATH=`dirname $CUR_PWD`


echo "# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf" > $BUILD_DIR/conf/bblayers.conf
echo "# changes incompatibly" >> $BUILD_DIR/conf/bblayers.conf
echo "POKY_BBLAYERS_CONF_VERSION = \"2\"" >> $BUILD_DIR/conf/bblayers.conf
echo -e "\n" >> $BUILD_DIR/conf/bblayers.conf
echo "BBPATH = \"\${TOPDIR}\"" >> $BUILD_DIR/conf/bblayers.conf
echo "BBFILES ?= \"\"" >> $BUILD_DIR/conf/bblayers.conf
echo -e "\n" >> $BUILD_DIR/conf/bblayers.conf
echo "BUILDPATH ?= \"${BUILDPATH}\"" >> $BUILD_DIR/conf/bblayers.conf

echo "##RPi Yocto Project Release layer" >> $BUILD_DIR/conf/bblayers.conf
echo "" >> $BUILD_DIR/conf/bblayers.conf
echo -e "BBLAYERS ?= \" \\
	\${BUILDPATH}/source/poky/meta \\
	\${BUILDPATH}/source/poky/meta-poky \\
	\${BUILDPATH}/source/poky/meta-openembedded/meta-oe \\
	\${BUILDPATH}/source/poky/meta-openembedded/meta-multimedia \\
	\${BUILDPATH}/source/poky/meta-openembedded/meta-networking \\
	\${BUILDPATH}/source/poky/meta-openembedded/meta-perl \\
	\${BUILDPATH}/source/poky/meta-openembedded/meta-python \\
	\${BUILDPATH}/source/poky/meta-qt5 \\
	\${BUILDPATH}/source/poky/meta-raspberrypi \\
	\${BUILDPATH}/source/meta-rpi \\
	\"" >> $BUILD_DIR/conf/bblayers.conf

echo BSPDIR=$BSPDIR
echo BUILD_DIR=$BUILD_DIR

cd  $BUILD_DIR
clean_up
