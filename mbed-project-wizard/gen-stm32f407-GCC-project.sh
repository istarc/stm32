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
# SafeRTOS
#
# To use SafeRTOS (proprietary) install the source first.
# 1. Install wine
#	sudo apt-get install wine
# 2. Download STM32F4xx_atollic_SafeRTOS_Library_Demo.exe (SafeRTOS 4.7) from http://www.highintegritysystems.com/safertos/
# 3. Install via wine (use default installation)
#	wine STM32F4xx_atollic_SafeRTOS_Library_Demo.exe

##
# Depends on:
# freertos/*, mbed/*, mbed-freertos/*, mbed-none/*, mbed-mbedrtos/*, none-safertos/*

##
# Options:
# - mbed-none[-lib] - Bare-metal project /w mbed SDK [with library].
# - mbed-freertos[-lib] - FreeRTOS project /w mbed SDK [with library].
# - mbed-mbedrtos[-lib] - mbedRTOS project /w mbed SDK [with library].
# - none-safertos - SafeRTOS project

##
# Variables:
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASEDIR=$SCRIPTDIR/..
CMSIS=$BASEDIR/STM32F4-Discovery_FW_V1.0.0
MBED=$BASEDIR/mbed/libraries/mbed
MBEDRTOS=$BASEDIR/mbed/libraries/rtos
FREERTOS=$BASEDIR/freertos/FreeRTOS
SAFERTOS=~/.wine/drive_c/HighIntegritySystems/SafeRTOS_Atollic_STM32F4xx_Lib_Demo/SafeRTOS_Atollic_STM32F4xx_Lib_Demo

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
# Create directory structure /w unit test support
do_create_tdir()
{
mkdir -p $(pwd)/bin
touch $(pwd)/bin/.gitkeep # A dummy file to keep directory structure in place
mkdir -p $(pwd)/inc
echo 'Your application header files (*.h).' > $(pwd)/inc/README
mkdir -p $(pwd)/lib
echo 'Place third-party source code or libraries here.' > $(pwd)/lib/README
mkdir -p $(pwd)/src
echo 'Your application source files (*.c, *.cpp, *.s).' > $(pwd)/src/README
mkdir -p $(pwd)/test
echo 'Your test source files (*.c, *.cpp).' > $(pwd)/test/README
}

##
# Deploy mbed SDK and tailor to fit STM32F4XX and GCC
do_deploy_mbed()
{
if [[ "$1" == "link" ]]; then
	cp -sR $MBED $(pwd)/lib/mbed
else
	cp -LR $MBED $(pwd)/lib/mbed
fi
# Prune targets not(STM32F4XX or GCC)
find $(pwd)/lib/mbed/targets/cmsis -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_STM' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/cmsis/TARGET_STM -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_STM32F407VG' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/cmsis/TARGET_STM/TARGET_STM32F407VG -mindepth 1 -maxdepth 1 -type d -not -name 'TOOLCHAIN_GCC_ARM' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/hal -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_STM' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/hal/TARGET_STM -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_STM32F407VG' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/hal/TARGET_STM/TARGET_STM32F407VG -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_DISCO_F407VG' -exec rm -rf {} \;
if [[ "$1" == "link" ]]; then
	# Linker script
	ln -s lib/mbed/targets/cmsis/TARGET_STM/TARGET_STM32F407VG/TOOLCHAIN_GCC_ARM/STM32F407.ld stm32f407.ld
	# Abs to Rel Symlinks
	symlinks -rc $(pwd) 1>/dev/null
else
	cp lib/mbed/targets/cmsis/TARGET_STM/TARGET_STM32F407VG/TOOLCHAIN_GCC_ARM/STM32F407.ld stm32f407.ld
fi
}

##
# Deploy FreeRTOS and tailor to fit STM32F4XX and GCC
do_deploy_freertos()
{
if [[ "$1" == "link" ]]; then
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
if [[ "$1" == "link" ]]; then
	# Abs to Rel Symlinks
	symlinks -rc $(pwd) 1>/dev/null
fi
}

##
# Deploy mbedRTOS and tailor to fit STM32F4XX and GCC
do_deploy_mbedrots()
{
if [[ "$1" == "link" ]]; then
	cp -sR $MBEDRTOS $(pwd)/lib/mbedrtos
else
	cp -LR $MBEDRTOS $(pwd)/lib/mbedrtos
fi
# Prune targets not(STM32F4XX or GCC)
find $(pwd)/lib/mbedrtos/rtx -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_M4' -exec rm -rf {} \;
find $(pwd)/lib/mbedrtos/rtx/TARGET_M4 -mindepth 1 -maxdepth 1 -type d -not -name 'TOOLCHAIN_GCC' -exec rm -rf {} \;
if [[ "$2" == "link" ]]; then
	# Abs to Rel Symlinks
	symlinks -rc $(pwd) 1>/dev/null
fi
}

##
# Deploy FreeRTOS and tailor to fit STM32F4XX and GCC
do_deploy_safertos()
{
if [[ "$1" == "link" ]]; then
	cp -sR $SAFERTOS $(pwd)/lib/SafeRTOS
else
	cp -LR $SAFERTOS $(pwd)/lib/SafeRTOS
fi
# Prune targets not(STM32F4XX or GCC)
find $(pwd)/lib/SafeRTOS -mindepth 1 -maxdepth 1 -not -name 'src' -exec rm -rf {} \;
find $(pwd)/lib/SafeRTOS/src -mindepth 1 -maxdepth 1 -name 'source' -exec rm -rf {} \;
# Deploy demo application
if [[ "$1" == "link" ]]; then
	cp -sR $SAFERTOS/src/source/* $(pwd)/src
	ln -s $SAFERTOS/SafeRTOS_STM32F407VG_FLASH.ld stm32f407.ld
	# Patch copy of main.c (Header files are case sensitive in Linux)
	rm -f $(pwd)/src/main.c
	cp -L $SAFERTOS/src/source/main.c $(pwd)/src/main.c
	chmod a+wr $(pwd)/src/main.c
	patch -p0 < $SCRIPTDIR/safertos/safertos.patch
	# Remove test stub
	rm $(pwd)/lib/SafeRTOS/src/common/comtest.c
else
	cp -LR $SAFERTOS/src/source/* $(pwd)/src
	cp $SAFERTOS/SafeRTOS_STM32F407VG_FLASH.ld stm32f407.ld
fi
if [[ "$1" == "link" ]]; then
	# Abs to Rel Symlinks
	symlinks -rc $(pwd) 1>/dev/null
fi
}


case "$1" in
  mbed-none)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-none ... creates a bare-metal project with mbed SDK" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage: make && sudo make deploy" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	cp $SCRIPTDIR/mbed-none/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none/Makefile $(pwd)/Makefile
	;;
  mbed-none-cpput)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-none-cpput ... creates a bare-metal project with mbed SDK and cpputest support" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage [app]:  make clean && make && sudo make deploy" >> $(pwd)/README
	echo "Usage [test]: make clean && make test-deps && make test && sudo make test-deploy"  >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "              Works with STM32F4-Disocvery /w STM32F4-BB" >> $(pwd)/README
	echo "              Unit Test Results are Displayed on UART 6 Serial Device (that is routed to RS-232 interface of the STM32F4-BB board)" >> $(pwd)/README
	echo "              cat /dev/ttyS0 (cat /dev/ttyUSB0)" >> $(pwd)/README
	do_create_tdir $2
	do_deploy_mbed $2
	# Deploy project files
	cp $SCRIPTDIR/mbed-none-cpput/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none-cpput/add.cpp $(pwd)/src/add.cpp
	cp $SCRIPTDIR/mbed-none-cpput/add.h $(pwd)/inc/add.h
	# Deploy test files
	cp $SCRIPTDIR/mbed-none-cpput/test-main.cpp $(pwd)/test/test-main.cpp
	cp $SCRIPTDIR/mbed-none-cpput/test-fail.cpp $(pwd)/test/test-fail.cpp
	cp $SCRIPTDIR/mbed-none-cpput/test-add.cpp $(pwd)/test/test-add.cpp
	# Deploy Makefiles
	cp $SCRIPTDIR/mbed-none-cpput/Makefile $(pwd)/Makefile
	cp $SCRIPTDIR/mbed-none-cpput/Makefile-test $(pwd)/Makefile-test
	# Patch mbed library (retarget STDIO)
	patch -p1 < $SCRIPTDIR/mbed-none-cpput/PeripheralNames.patch
	;;
  mbed-none-sim)
    echo "Project template created by ${0##*/} $1" > $(pwd)/README
    echo "   mbed-none-sim ... creates a bare-metal project with mbed SDK suitable for QEMU simulation" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage: make && sudo make deploy" >> $(pwd)/README
        do_create_dir $2
        do_deploy_mbed $2
        cp $SCRIPTDIR/mbed-none-sim/main.cpp $(pwd)/src/main.cpp
        cp $SCRIPTDIR/mbed-none-sim/Makefile $(pwd)/Makefile
	rm *.ld # Delete the linker script
        ;;
  mbed-none-lib)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-none-lib ... creates a bare-metal project with mbed SDK" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage: make && sudo make deploy" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	cp $SCRIPTDIR/mbed/Makefile-lib $(pwd)/lib/mbed/Makefile
	cp $SCRIPTDIR/mbed-none/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none/Makefile-lib $(pwd)/Makefile
	;;
  mbed-freertos)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-freertos ... creates a FreeRTOS project with mbed SDK (/w libraries)" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage: make && sudo make deploy" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	do_deploy_freertos
	cp $SCRIPTDIR/mbed-freertos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-freertos/Makefile $(pwd)/Makefile
	;;
  mbed-freertos-lib)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-freertos-lib ... creates a FreeRTOS project with mbed SDK (/w libraries)" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage: make && sudo make deploy" >> $(pwd)/README
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
	echo "" >> $(pwd)/README
	echo "Usage: make && sudo make deploy" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	do_deploy_mbedrots $2
	cp $SCRIPTDIR/mbed-mbedrtos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-mbedrtos/Makefile $(pwd)/Makefile
	;;
  mbed-mbedrtos-lib)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-mbedrtos-lib ... creates a mbedRTOS project with mbed SDK (/w libraries)" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage: make && sudo make deploy" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	cp $SCRIPTDIR/mbed/Makefile-lib $(pwd)/lib/mbed/Makefile
	do_deploy_mbedrots $2
	cp $SCRIPTDIR/mbedrtos/Makefile-lib $(pwd)/lib/mbedrtos/Makefile
	cp $SCRIPTDIR/mbed-mbedrtos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-mbedrtos/Makefile-lib $(pwd)/Makefile
	;;
  none-safertos)
	if [ ! -d "$SAFERTOS" ]; then
		echo "Install SafeRTOS first at http://www.highintegritysystems.com/safertos"
		echo "Or update SAFERTOS variable"
		exit 1
	fi
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   none-safertos ... creates a SafeRTOS project with mbed SDK (/w libraries)" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage: make && sudo make deploy" >> $(pwd)/README
	do_create_dir $2
	do_deploy_safertos $2
	cp $SCRIPTDIR/none-safertos/Makefile $(pwd)/Makefile
	;;
  --help)
	echo "Usage: $SCRIPTNAME {mbed-none|mbed-none-cpput|mbed-none-sim|mbed-none-lib|mbed-freertos|mbed-freertos-lib|mbed-mbedrtos|mbed-mbedrtos-lib|none-safertos} {|link}"
	echo ""
	echo "   mbed-none ........... creates a bare-metal project with mbed SDK"
	echo "   mbed-none-cpput ..... creates a bare-metal project with mbed SDK and cpputest support"
	echo "   mbed-none-sim ....... creates a bare-metal project with mbed SDK suitable for QEMU simulation"
	echo "   mbed-none-lib ....... creates a bare-metal project with mbed SDK"
	echo "   mbed-freertos ....... creates a FreeRTOS project with mbed SDK (/w libraries)"
	echo "   mbed-freertos-lib ... creates a FreeRTOS project with mbed SDK (/w libraries)"
	echo "   mbed-mbedrtos ....... creates a mbedRTOS project with mbed SDK"
	echo "   mbed-mbedrtos-lib ... creates a mbedRTOS project with mbed SDK (/w libraries)"
	echo "   none-safertos ....... creates a SafeRTOS project"
	echo " "
	echo "   link ................ symlink files instead of copy"
	echo " "
	;;
  *)
	echo "Usage: $SCRIPTNAME {mbed-none|mbed-none-cpput|mbed-none-sim|mbed-none-lib|mbed-freertos|mbed-freertos-lib|mbed-mbedrtos|mbed-mbedrtos-lib|none-safertos} {|link}"
	exit 3
	;;
esac
