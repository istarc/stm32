#!/bin/bash

# Setups STM32F4-Discovery Build and Test Environment

set -e # Exit immediately if a command exits with a non-zero status

#PREFIX=~/stm32f4-env
PREFIX=~

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
mkdir -p $PREFIX
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
sudo apt-get install -y build-essential git openocd gcc-arm-none-eabi=4-8-2014q2-0trusty10
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
sudo make deploy

