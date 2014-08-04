#!/bin/bash

##
# This is project generation utility for ARM embedded devices.

##
# Prerequisites: Ubuntu 14.04 LTS, STM32F4 Discovery Board

##
# Before use install software dependencies:
# sudo apt-get install build-essential git binutils-arm-none-eabi gcc-arm-none-eabi libnewlib-arm-none-eabi gdb-arm-none-eabi openocd symlink
# git clone https://github.com/istarc/stm32.git
# cd stm32 && git submodule update --init

##
# Depends on:
# freertos/*, mbed/*, mbed-freertos/*, mbed-none/*, mbed-mbedrtos/*

##
# Options:
# - mbed-none[-lib] - Bare-metal project /w mbed SDK [with library].
# - mbed-freertos[-lib] - FreeRTOS project /w mbed SDK [with library].
# - mbed-mbedrtos[-lib] - mbedRTOS project /w mbed SDK [with library].

##
# Variables:
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASEDIR=$SCRIPTDIR/..
CMSIS=$BASEDIR/STM32F4-Discovery_FW_V1.0.0
MBED=$BASEDIR/mbed/libraries/mbed
MBEDRTOS=$BASEDIR/mbed/libraries/rtos
FREERTOS=$BASEDIR/freertos/FreeRTOS

##
# Check if project directory is emtpy
STATUS=$(ls)
if [[ "$STATUS" ]]; then
	echo "Project directory is not empty!"
	exit 1
fi

##
# Check dependancies
TARGET=arm-none-eabi
for c in "make" "${TARGET}-gcc" "${TARGET}-g++" "${TARGET}-ld" "${TARGET}-as" "symlinks"
do
	STATUS=$(command -v $c >/dev/null 2>&1 || echo >&2 "$c not installed")
	if [[ "$STATUS" ]]; then
		echo "Install $c"
		exit 2
	fi
done

##
# Create directory structure
do_create_dir()
{
mkdir -p $(pwd)/bin
touch $(pwd)/bin/.gitkeep # A dummy file to keep directory structure in place
mkdir -p $(pwd)/inc
echo 'Your application header files (*.h).' > $(pwd)/inc/README
mkdir -p $(pwd)/lib
echo 'Place third-party source code or libraries here.' > $(pwd)/lib/README
mkdir -p $(pwd)/src
echo 'Your application source files (*.c, *.cpp, *.s).' > $(pwd)/src/README
}

##
# Deploy mbed SDK and tailor to fit STM32F4XX and GCC
do_deploy_mbed()
{
if [[ "$1" != "copy" ]]; then
	cp -sR $MBED $(pwd)/lib/mbed
else
	cp -LR $MBED $(pwd)/lib/mbed
fi
# Prune targets not(STM32F4XX or GCC)
find $(pwd)/lib/mbed/targets/cmsis -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_STM' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/cmsis/TARGET_STM -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_STM32F4XX' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/cmsis/TARGET_STM/TARGET_STM32F4XX -mindepth 1 -maxdepth 1 -type d -not -name 'TOOLCHAIN_GCC_ARM' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/hal -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_STM' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/hal/TARGET_STM -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_STM32F4XX' -exec rm -rf {} \;
if [[ "$1" != "copy" ]]; then
	# Linker script
	ln -s lib/mbed/targets/cmsis/TARGET_STM/TARGET_STM32F4XX/TOOLCHAIN_GCC_ARM/STM32F407.ld stm32f407.ld
	# Abs to Rel Symlinks
	symlinks -rc $(pwd) 1>/dev/null
else
	cp lib/mbed/targets/cmsis/TARGET_STM/TARGET_STM32F4XX/TOOLCHAIN_GCC_ARM/STM32F407.ld stm32f407.ld
fi
}

##
# Deploy FreeRTOS and tailor to fit STM32F4XX and GCC
do_deploy_freertos()
{
if [[ "$1" != "copy" ]]; then
	cp -sR $FREERTOS $(pwd)/lib/FreeRTOS
else
	cp -LR $FREERTOS $(pwd)/lib/FreeRTOS
fi
# Prune targets not(STM32F4XX or GCC)
find $(pwd)/lib/FreeRTOS -mindepth 1 -maxdepth 1 -type d -not -name 'Source' -exec rm -rf {} \;
find $(pwd)/lib/FreeRTOS/Source/portable -mindepth 1 -maxdepth 1 -type d -not -name 'GCC' -not -name 'MemMang' -exec rm -rf {} \;
find $(pwd)/lib/FreeRTOS/Source/portable/MemMang/*.c -not -name 'heap_1.c' -exec rm -rf {} \;
find $(pwd)/lib/FreeRTOS/Source/portable/GCC -mindepth 1 -maxdepth 1 -type d -not -name 'ARM_CM4F' -exec rm -rf {} \;
# Copy FreeRTOSConfig.h
mkdir $(pwd)/lib/FreeRTOS/config/
cp $SCRIPTDIR/freertos/FreeRTOSConfig.h $(pwd)/lib/FreeRTOS/config/FreeRTOSConfig.h
if [[ "$1" != "copy" ]]; then
	# Abs to Rel Symlinks
	symlinks -rc $(pwd) 1>/dev/null
fi
}

##
# Deploy mbedRTOS and tailor to fit STM32F4XX and GCC
do_deploy_mbedrots()
{
if [[ "$1" != "copy" ]]; then
	cp -sR $MBEDRTOS $(pwd)/lib/mbedrtos
else
	cp -LR $MBEDRTOS $(pwd)/lib/mbedrtos
fi
# Prune targets not(STM32F4XX or GCC)
find $(pwd)/lib/mbedrtos/rtx -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_M4' -exec rm -rf {} \;
find $(pwd)/lib/mbedrtos/rtx/TARGET_M4 -mindepth 1 -maxdepth 1 -type d -not -name 'TOOLCHAIN_GCC' -exec rm -rf {} \;
if [[ "$2" != "copy" ]]; then
	# Abs to Rel Symlinks
	symlinks -rc $(pwd) 1>/dev/null
fi
}

case "$1" in
  mbed-none)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-none ... creates a bare-metal project with mbed SDK" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	cp $SCRIPTDIR/mbed-none/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none/Makefile $(pwd)/Makefile
	;;
  mbed-none-lib)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-none-lib ... creates a bare-metal project with mbed SDK" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	cp $SCRIPTDIR/mbed/Makefile-lib $(pwd)/lib/mbed/Makefile
	cp $SCRIPTDIR/mbed-none/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none/Makefile-lib $(pwd)/Makefile
	;;
  mbed-freertos)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-freertos ... creates a FreeRTOS project with mbed SDK (/w libraries)" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	do_deploy_freertos
	cp $SCRIPTDIR/mbed-freertos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-freertos/Makefile $(pwd)/Makefile
	;;
  mbed-freertos-lib)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-freertos-lib ... creates a FreeRTOS project with mbed SDK (/w libraries)" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	cp $SCRIPTDIR/mbed/Makefile-lib $(pwd)/lib/mbed/Makefile
	do_deploy_freertos $2
	cp $SCRIPTDIR/freertos/Makefile-lib $(pwd)/lib/FreeRTOS/Makefile
	cp $SCRIPTDIR/mbed-freertos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-freertos/Makefile-lib $(pwd)/Makefile
	;;
  mbed-mbedrtos)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-mbedrtos ... creates a mbedRTOS project with mbed SDK" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	do_deploy_mbedrots $2
	cp $SCRIPTDIR/mbed-mbedrtos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-mbedrtos/Makefile $(pwd)/Makefile
	;;
  mbed-mbedrtos-lib)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-mbedrtos-lib ... creates a mbedRTOS project with mbed SDK (/w libraries)" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	cp $SCRIPTDIR/mbed/Makefile-lib $(pwd)/lib/mbed/Makefile
	do_deploy_mbedrots $2
	cp $SCRIPTDIR/mbedrtos/Makefile-lib $(pwd)/lib/mbedrtos/Makefile
	cp $SCRIPTDIR/mbed-mbedrtos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-mbedrtos/Makefile-lib $(pwd)/Makefile
	;;
  --help)
	echo "Usage: $SCRIPTNAME {mbed-none|mbed-none-lib|mbed-freertos|mbed-freertos-lib|mbed-mbedrtos|mbed-mbedrtos-lib} {|copy}"
	echo ""
	echo "   mbed-none ........... creates a bare-metal project with mbed SDK"
	echo "   mbed-none-lib ....... creates a bare-metal project with mbed SDK"
	echo "   mbed-freertos ....... creates a FreeRTOS project with mbed SDK (/w libraries)"
	echo "   mbed-freertos-lib ... creates a FreeRTOS project with mbed SDK (/w libraries)"
	echo "   mbed-mbedrtos ....... creates a mbedRTOS project with mbed SDK"
	echo "   mbed-mbedrtos-lib ... creates a mbedRTOS project with mbed SDK (/w libraries)"
	echo " "
	echo "   copy ................ copy files instead of symlinks (default)"
	echo " "
	;;
  *)
	echo "Usage: $SCRIPTNAME {mbed-none|mbed-none-lib|mbed-freertos|mbed-freertos-lib|mbed-mbedrtos|mbed-mbedrtos-lib} {|copy}"
	exit 3
	;;
esac

