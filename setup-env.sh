#!/bin/bash

# Setups STM32F4-Discovery Build and Test Environment

###
# Setups STM32F4-Discovery Build and Test Environment
# 
# Host:   Ubuntu 14.04 LTS x86_64
# Target: ARM cortex-m4f
#
# Features:
# - GCC ARM Embedded Toolchain (Ubuntu 14.04 LTS PPA Repository)
# - OpenOCD (On-chip Debugger)
# - Buildbot (Automated Build and Test Environment)
# - Optional: GCC ARM Embedded Toolchain (Built from scratch)

###
# Prerequisites:
# - Ubuntu 14.04 GNU/Linux.

###
# Check My Blog
#  http://istarc.wordpress.com

###
# 0. Define Variables
# 0.1 Stop on first error
set -e 
# 0.2 Be verbose
set -x
# 0.3 Build directory
PREFIX=~
# 0.4 Check if Ubuntu 14.04 LTS
if [ -z "$(cat /etc/os-release | grep "Ubuntu 14.04")" ]; then
	echo "This script should be only used with Ubuntu 14.04,"
	echo "but your system is"
	echo ""
	cat /etc/os-release
	echo ""
	echo "Use the following Docker image instead."
	echo "https://registry.hub.docker.com/u/istarc/stm32/"
	echo ""
	exit 
fi
# 0.5 Check if clean
if [ -d "$PREFIX/stm32" ] || [ -d "$PREFIX/stm32bb" ] || [ -d "$PREFIX/openocd" ] || [ -d "/opt/openocd" ]; then
	echo ""
	echo "The following directories may be overwritten."
	echo " - $PREFIX/stm32"
	echo " - $PREFIX/stm32bb"
	echo " - $PREFIX/openocd"
	echo " - /opt/openocd"
	echo ""
	read -r -p "Are you sure? [y/N] " response
	case $response in
	    [yY][eE][sS]|[yY])
	        ;;
	    *)
	        exit
	        ;;
	esac
fi

# 1. Install dependancies
# 1.1 Install platform dependancies
if [ ! -d $PREFIX ]; then
	mkdir -p $PREFIX
fi
cd $PREFIX
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -q
# 1.2 Install project dependancies
sudo add-apt-repository -y ppa:terry.guo/gcc-arm-embedded
sudo apt-get update -q
sudo apt-cache policy gcc-arm-none-eabi
# 1.2.1 GCC ARM
# Remove the offical packages
sudo apt-get purge -y binutils-arm-none-eabi gcc-arm-none-eabi gdb-arm-none-eabi libnewlib-arm-none-eabi
# Install the packages from the PPA repository (these come with C++ libraries and newlib.nano)
sudo apt-get install -y build-essential git openocd gcc-arm-none-eabi=4.8.4.2014q3-0trusty11
# 1.2.2 Buildbot
sudo apt-get install -y buildbot buildbot-slave
# 1.2.3 OpenOCD build dependancies
sudo apt-get install -y libtool libftdi-dev libusb-1.0-0-dev automake pkg-config texinfo
# 1.2.4 Clone and init stm32 repository
if [ ! -d "$PREFIX/stm32" ]; then
	cd $PREFIX
	git clone --depth 1 https://github.com/istarc/stm32.git
	cd $PREFIX/stm32
	git submodule update --init --depth 1
else
	cd $PREFIX/stm32
	git pull
	git submodule update
fi
# 1.2.5 Clone OpenOCD
if [ ! -d "$PREFIX/openocd" ]; then
	cd $PREFIX
	#git clone git://openocd.git.sourceforge.net/gitroot/openocd/openocd # Unreliable
	git clone --depth 1 https://github.com/ntfreak/openocd.git
else
	cd $PREFIX/openocd
	git pull
	git submodule update
fi

# 2. Build and Install CppUTest
if [ ! -d "$PREFIX/stm32/lib/cpputest" ]; then
	cd $PREFIX/stm32/cpputest
	autoreconf -i
	./configure --prefix=$PREFIX/stm32/lib/cpputest --host=arm-none-eabi LDFLAGS=--specs=nosys.specs
        make
        make install
	git reset --hard
fi

# 2. Build and Install OpenOCD
if [ ! -d "/opt/openocd" ]; then
	cd $PREFIX/openocd
	./bootstrap
	./configure --enable-maintainer-mode --disable-option-checking --disable-werror --prefix=/opt/openocd --enable-dummy --enable-usb_blaster_libftdi --enable-ep93xx --enable-at91rm9200 --enable-presto_libftdi --enable-usbprog --enable-jlink --enable-vsllink --enable-rlink --enable-stlink --enable-arm-jtag-ew
	make
	sudo make install
fi

# 3. Setup buildbot master and workers
if [ ! -d "$PREFIX/stm32bb" ]; then
	mkdir -p $PREFIX/stm32bb
	buildbot create-master $PREFIX/stm32bb/master
	cp $PREFIX/stm32/test/buildbot/master/master.cfg $PREFIX/stm32bb/master/master.cfg
	buildslave create-slave $PREFIX/stm32bb/slave localhost:9989 arm-none-eabi pass-MonkipofPaj1
fi

cd $PREFIX/stm32bb
buildbot restart master
buildbot reconfig master
buildslave restart slave

# 4. Test (Connect the STM32F4-Discovery board)
cd $PREFIX/stm32/examples/Template.mbed
make clean
make -j4
# sudo make deploy

# 5 Install 
echo ""
echo "Build GCC ARM Embedded Toolchain from the scratch?"
echo ""
read -r -p "Are you sure? [y/N] " response
case $response in
	[yY][eE][sS]|[yY])
	cd $PREFIX/stm32/build-ARM-toolchain
# 5.1 Install the toolchain
	bash build.sh
# 5.2 Test the toolchain
	export PATH=~/arm/bin:$PATH
	cd $PREFIX/stm32/examples/Template.mbed
	make clean
	make -j4
	arm-none-eabi-g++ --version
	# sudo make deploy
	;;
	*)
	exit
	;;
esac

echo ""
echo "### END ###"
echo ""
