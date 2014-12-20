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

set -e
#set -x

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
mkdir -p $(pwd)/test-bin
touch $(pwd)/test-bin/.gitkeep # A dummy file to keep directory structure in place
mkdir -p $(pwd)/inc
echo 'Your application header files (*.h).' > $(pwd)/inc/README
mkdir -p $(pwd)/lib
echo 'Place third-party source code or libraries here.' > $(pwd)/lib/README
mkdir -p $(pwd)/src
echo 'Your application source files (*.c, *.cpp, *.s).' > $(pwd)/src/README
mkdir -p $(pwd)/test-src
echo 'Your test source files (*.c, *.cpp).' > $(pwd)/test-src/README
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
	echo "" >> $(pwd)/README
	echo "Git info:" >> $(pwd)/README
	echo "   stm32:    "$(cd $BASEDIR && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   mbed:     "$(cd $BASEDIR/mbed && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/mbed && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	cp $SCRIPTDIR/mbed-none/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none/Makefile $(pwd)/Makefile
	# Print usage instructions
	cat README
	;;
  mbed-none-BB)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-none-BB ... creates a bare-metal project with mbed SDK, cpputest support and redirected STDIO tailored to STM32F4-BB expansion board" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage [app]:  make clean && make && sudo make deploy" >> $(pwd)/README
	echo "Usage [test]: make test-clean && make test-deps && make test && sudo make check"  >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "              Works with STM32F4-Disocvery /w STM32F4-BB" >> $(pwd)/README
	echo "              Unit Test Results are Displayed on UART 6 Serial Device (that is routed to RS-232 interface of the STM32F4-BB board)" >> $(pwd)/README
	echo "              cat /dev/ttyS0 (cat /dev/ttyUSB0)" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Git info:" >> $(pwd)/README
	echo "   stm32:    "$(cd $BASEDIR && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   mbed:     "$(cd $BASEDIR/mbed && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/mbed && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   cpput:    "$(cd $BASEDIR/cpputest && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/cpputest && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	do_create_tdir $2
	do_deploy_mbed $2
	# Deploy project files
	cp $SCRIPTDIR/mbed-none-BB/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none-BB/add.cpp $(pwd)/src/add.cpp
	cp $SCRIPTDIR/mbed-none-BB/dadd.cpp $(pwd)/src/dadd.cpp
	cp $SCRIPTDIR/mbed-none-BB/add.h $(pwd)/inc/add.h
	cp $SCRIPTDIR/mbed-none-BB/dadd.h $(pwd)/inc/dadd.h
	# Deploy test files
	cp $SCRIPTDIR/mbed-none-BB/test-main.cpp $(pwd)/test-src/test-main.cpp
	cp $SCRIPTDIR/mbed-none-BB/test-fail.cpp $(pwd)/test-src/test-fail.cpp
	cp $SCRIPTDIR/mbed-none-BB/test-add.cpp $(pwd)/test-src/test-dadd.cpp
	cp $SCRIPTDIR/mbed-none-BB/test-dadd.cpp $(pwd)/test-src/test-add.cpp
	# Deploy Makefiles
	cp $SCRIPTDIR/mbed-none-BB/Makefile $(pwd)/Makefile
	cp $SCRIPTDIR/mbed-none-BB/Makefile-test $(pwd)/Makefile-test
	# Patch mbed library (retarget STDIO)
	patch -p1 < $SCRIPTDIR/mbed-none-BB/PeripheralNames.patch
	# Copy cpputest src (exluding .git)
	rsync -a --exclude .git $BASEDIR/cpputest/ $(pwd)/test-cpputest
	# Print usage instructions
	cat README
	;;
  mbed-none-sh)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-none-sh[|cpput] ... creates a bare-metal project with mbed SDK, cpputest and ARM semihosting support." >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage [app]:  make clean && make && sudo make deploy" >> $(pwd)/README
	echo "Usage [test]: make test-clean && make test-deps && make test && sudo make check"  >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Git info:" >> $(pwd)/README
	echo "   stm32:    "$(cd $BASEDIR && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   mbed:     "$(cd $BASEDIR/mbed && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/mbed && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   cpputest: "$(cd $BASEDIR/cpputest && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/cpputest && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	do_create_tdir $2
	do_deploy_mbed $2
	# Deploy project files
	cp $SCRIPTDIR/mbed-none-sh/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none-sh/add.cpp $(pwd)/src/add.cpp
	cp $SCRIPTDIR/mbed-none-sh/dadd.cpp $(pwd)/src/dadd.cpp
	cp $SCRIPTDIR/mbed-none-sh/add.h $(pwd)/inc/add.h
	cp $SCRIPTDIR/mbed-none-sh/dadd.h $(pwd)/inc/dadd.h
	# Deploy test files
	cp $SCRIPTDIR/mbed-none-sh/test-main.cpp $(pwd)/test-src/test-main.cpp
	cp $SCRIPTDIR/mbed-none-sh/test-fail.cpp $(pwd)/test-src/test-fail.cpp
	cp $SCRIPTDIR/mbed-none-sh/test-add.cpp $(pwd)/test-src/test-dadd.cpp
	cp $SCRIPTDIR/mbed-none-sh/test-dadd.cpp $(pwd)/test-src/test-add.cpp
	# Deploy Makefiles, automated unit test check script (with the corresponding OpenOCD script)
	cp $SCRIPTDIR/mbed-none-sh/Makefile $(pwd)/Makefile
	cp $SCRIPTDIR/mbed-none-sh/Makefile-test $(pwd)/Makefile-test
	cp $SCRIPTDIR/mbed-none-sh/check.exp $(pwd)/check.exp
	cp $SCRIPTDIR/mbed-none-sh/check.cfg $(pwd)/check.cfg
	cp $SCRIPTDIR/mbed-none-sh/deploy.cfg $(pwd)/deploy.cfg
	cp $SCRIPTDIR/mbed-none-sh/gprof.cfg $(pwd)/gprof.cfg
	cp $SCRIPTDIR/mbed-none-sh/test-gprof.cfg $(pwd)/test-gprof.cfg
	# Copy cpputest src (exluding .git)
	rsync -a --exclude .git $BASEDIR/cpputest/ $(pwd)/test-cpputest
	# Print usage instructions
	cat README
	;;
	mbed-none-shcpput)
	mbed-none-sh
	;;
	mbed-none-shgtest)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-none-shgtest ... creates a bare-metal project with mbed SDK, googletest and ARM semihosting support." >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage [app]:  make clean && make && sudo make deploy" >> $(pwd)/README
	echo "Usage [test]: make test-clean && make test-deps && make test && sudo make check"  >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Git info:" >> $(pwd)/README
	echo "   stm32:    "$(cd $BASEDIR && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   mbed:     "$(cd $BASEDIR/mbed && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/mbed && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   gtest:    "$(cd $BASEDIR/googletest && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/googletest && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	do_create_tdir $2
	do_deploy_mbed $2
	# Deploy project files
	cp $SCRIPTDIR/mbed-none-shgtest/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none-shgtest/add.cpp $(pwd)/src/add.cpp
	cp $SCRIPTDIR/mbed-none-shgtest/dadd.cpp $(pwd)/src/dadd.cpp
	cp $SCRIPTDIR/mbed-none-shgtest/add.h $(pwd)/inc/add.h
	cp $SCRIPTDIR/mbed-none-shgtest/dadd.h $(pwd)/inc/dadd.h
	# Deploy test files
	cp $SCRIPTDIR/mbed-none-shgtest/test-main.cpp $(pwd)/test-src/test-main.cpp
	cp $SCRIPTDIR/mbed-none-shgtest/test-fail.cpp $(pwd)/test-src/test-fail.cpp
	cp $SCRIPTDIR/mbed-none-shgtest/test-add.cpp $(pwd)/test-src/test-dadd.cpp
	cp $SCRIPTDIR/mbed-none-shgtest/test-dadd.cpp $(pwd)/test-src/test-add.cpp
	# Deploy Makefiles, automated unit test check script (with the corresponding OpenOCD script)
	cp $SCRIPTDIR/mbed-none-shgtest/Makefile $(pwd)/Makefile
	cp $SCRIPTDIR/mbed-none-shgtest/Makefile-test $(pwd)/Makefile-test
	cp $SCRIPTDIR/mbed-none-shgtest/check.exp $(pwd)/check.exp
	cp $SCRIPTDIR/mbed-none-shgtest/check.cfg $(pwd)/check.cfg
	cp $SCRIPTDIR/mbed-none-shgtest/deploy.cfg $(pwd)/deploy.cfg
	cp $SCRIPTDIR/mbed-none-shgtest/gprof.cfg $(pwd)/gprof.cfg
	cp $SCRIPTDIR/mbed-none-shgtest/test-gprof.cfg $(pwd)/test-gprof.cfg
	# Copy cpputest src (exluding .git)
	rsync -a --exclude .git $BASEDIR/googletest/ $(pwd)/test-googletest
	# Add GTEST_OS_NONE Profile, which disables POSIX calls getcwd and mkdir.
	patch $(pwd)/test-googletest/src/gtest-filepath.cc < $SCRIPTDIR/mbed-none-shgtest/gtest-filepath.cc.patch
	# Print usage instructions
	cat README
	;;
  mbed-none-shsim)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-none-shsim[|cpput] ... creates a bare-metal project with mbed SDK and cpputest support suitable for (ARM semihosted) QEMU simulation" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage [app]:  make clean && make && sudo make deploy" >> $(pwd)/README
	echo "Usage [test]: make test-clean && make test-deps && make test && make check"  >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Git info:" >> $(pwd)/README
	echo "   stm32:    "$(cd $BASEDIR && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   mbed:     "$(cd $BASEDIR/mbed && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/mbed && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   cpputest: "$(cd $BASEDIR/cpputest && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/cpputest && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	do_create_tdir $2
	do_deploy_mbed $2
	# Deploy project files
	cp $SCRIPTDIR/mbed-none-shsim/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none-shsim/add.cpp $(pwd)/src/add.cpp
	cp $SCRIPTDIR/mbed-none-shsim/dadd.cpp $(pwd)/src/dadd.cpp
	cp $SCRIPTDIR/mbed-none-shsim/add.h $(pwd)/inc/add.h
	cp $SCRIPTDIR/mbed-none-shsim/dadd.h $(pwd)/inc/dadd.h
	# Deploy test files
	cp $SCRIPTDIR/mbed-none-shsim/test-main.cpp $(pwd)/test-src/test-main.cpp
	cp $SCRIPTDIR/mbed-none-shsim/test-fail.cpp $(pwd)/test-src/test-fail.cpp
	cp $SCRIPTDIR/mbed-none-shsim/test-add.cpp $(pwd)/test-src/test-add.cpp
	cp $SCRIPTDIR/mbed-none-shsim/test-dadd.cpp $(pwd)/test-src/test-dadd.cpp
	# Deploy Makefiles, automated unit test check script
	cp $SCRIPTDIR/mbed-none-shsim/Makefile $(pwd)/Makefile
	cp $SCRIPTDIR/mbed-none-shsim/Makefile-test $(pwd)/Makefile-test
	cp $SCRIPTDIR/mbed-none-shsim/check.exp $(pwd)/check.exp
	# Copy cpputest src (exluding .git)
	rsync -a --exclude .git $BASEDIR/cpputest/ $(pwd)/test-cpputest
	# Delete the linker script
	rm *.ld
	# Print usage instructions
	cat README
	;;
	mbed-none-shsimcpput)
	mbed-none-shsim
	;;
	mbed-none-shsimgtest)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-none-shsimgtest ... creates a bare-metal project with mbed SDK and googletest support suitable for (ARM semihosted) QEMU simulation" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage [app]:  make clean && make && sudo make deploy" >> $(pwd)/README
	echo "Usage [test]: make test-clean && make test-deps && make test && make check"  >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Git info:" >> $(pwd)/README
	echo "   stm32:    "$(cd $BASEDIR && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   mbed:     "$(cd $BASEDIR/mbed && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/mbed && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   gtest:    "$(cd $BASEDIR/googletest && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/googletest && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	do_create_tdir $2
	do_deploy_mbed $2
	# Deploy project files
	cp $SCRIPTDIR/mbed-none-shsimgtest/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none-shsimgtest/add.cpp $(pwd)/src/add.cpp
	cp $SCRIPTDIR/mbed-none-shsimgtest/dadd.cpp $(pwd)/src/dadd.cpp
	cp $SCRIPTDIR/mbed-none-shsimgtest/add.h $(pwd)/inc/add.h
	cp $SCRIPTDIR/mbed-none-shsimgtest/dadd.h $(pwd)/inc/dadd.h
	# Deploy test files
	cp $SCRIPTDIR/mbed-none-shsimgtest/test-main.cpp $(pwd)/test-src/test-main.cpp
	cp $SCRIPTDIR/mbed-none-shsimgtest/test-fail.cpp $(pwd)/test-src/test-fail.cpp
	cp $SCRIPTDIR/mbed-none-shsimgtest/test-add.cpp $(pwd)/test-src/test-add.cpp
	cp $SCRIPTDIR/mbed-none-shsimgtest/test-dadd.cpp $(pwd)/test-src/test-dadd.cpp
	# Deploy Makefiles, automated unit test check script
	cp $SCRIPTDIR/mbed-none-shsimgtest/Makefile $(pwd)/Makefile
	cp $SCRIPTDIR/mbed-none-shsimgtest/Makefile-test $(pwd)/Makefile-test
	cp $SCRIPTDIR/mbed-none-shsimgtest/check.exp $(pwd)/check.exp
	# Copy cpputest src (exluding .git)
	rsync -a --exclude .git $BASEDIR/googletest/ $(pwd)/test-googletest
	# Add GTEST_OS_NONE Profile, which disables POSIX calls getcwd and mkdir.
	patch $(pwd)/test-googletest/src/gtest-filepath.cc < $SCRIPTDIR/mbed-none-shsimgtest/gtest-filepath.cc.patch
	# Delete the linker script
	rm *.ld
	# Print usage instructions
	cat README
	;;
  mbed-none-lib)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-none-lib ... creates a bare-metal project with mbed SDK" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage: make && sudo make deploy" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Git info:" >> $(pwd)/README
	echo "   stm32:    "$(cd $BASEDIR && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   mbed:     "$(cd $BASEDIR/mbed && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/mbed && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
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
	echo "" >> $(pwd)/README
	echo "Git info:" >> $(pwd)/README
	echo "   stm32:    "$(cd $BASEDIR && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   mbed:     "$(cd $BASEDIR/mbed && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/mbed && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   freertos: "$(cd $BASEDIR/cpputest && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/cpputest && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	do_deploy_freertos
	cp $SCRIPTDIR/mbed-freertos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-freertos/Makefile $(pwd)/Makefile
	# Print usage instructions
	cat README
	;;
  mbed-freertos-lib)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-freertos-lib ... creates a FreeRTOS project with mbed SDK (/w libraries)" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage: make && sudo make deploy" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Git info:" >> $(pwd)/README
	echo "   stm32:    "$(cd $BASEDIR && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   mbed:     "$(cd $BASEDIR/mbed && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/mbed && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   freertos: "$(cd $BASEDIR/cpputest && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/cpputest && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	cp $SCRIPTDIR/mbed/Makefile-lib $(pwd)/lib/mbed/Makefile
	do_deploy_freertos $2
	cp $SCRIPTDIR/freertos/Makefile-lib $(pwd)/lib/FreeRTOS/Makefile
	cp $SCRIPTDIR/mbed-freertos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-freertos/Makefile-lib $(pwd)/Makefile
	# Print usage instructions
	cat README
	;;
  mbed-mbedrtos)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-mbedrtos ... creates a mbedRTOS project with mbed SDK" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage: make && sudo make deploy" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Git info:" >> $(pwd)/README
	echo "   stm32:    "$(cd $BASEDIR && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   mbed:     "$(cd $BASEDIR/mbed && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/mbed && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	do_deploy_mbedrots $2
	cp $SCRIPTDIR/mbed-mbedrtos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-mbedrtos/Makefile $(pwd)/Makefile
	# Print usage instructions
	cat README
	;;
  mbed-mbedrtos-lib)
	echo "Project template created by ${0##*/} $1" > $(pwd)/README
	echo "   mbed-mbedrtos-lib ... creates a mbedRTOS project with mbed SDK (/w libraries)" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Usage: make && sudo make deploy" >> $(pwd)/README
	echo "" >> $(pwd)/README
	echo "Git info:" >> $(pwd)/README
	echo "   stm32:    "$(cd $BASEDIR && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	echo "   mbed:     "$(cd $BASEDIR/mbed && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR/mbed && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	do_create_dir $2
	do_deploy_mbed $2
	cp $SCRIPTDIR/mbed/Makefile-lib $(pwd)/lib/mbed/Makefile
	do_deploy_mbedrots $2
	cp $SCRIPTDIR/mbedrtos/Makefile-lib $(pwd)/lib/mbedrtos/Makefile
	cp $SCRIPTDIR/mbed-mbedrtos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-mbedrtos/Makefile-lib $(pwd)/Makefile
	# Print usage instructions
	cat README
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
	echo "" >> $(pwd)/README
	echo "Git info:" >> $(pwd)/README
	echo "   stm32:    "$(cd $BASEDIR && git rev-parse --short=10 HEAD)" ("$(cd $BASEDIR && git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")" >> $(pwd)/README
	do_create_dir $2
	do_deploy_safertos $2
	cp $SCRIPTDIR/none-safertos/Makefile $(pwd)/Makefile
	# Print usage instructions
	cat README
	;;
  --help)
	echo "Usage: $SCRIPTNAME {mbed-none|mbed-none-cpput|mbed-none-sim|mbed-none-lib|mbed-freertos|mbed-freertos-lib|mbed-mbedrtos|mbed-mbedrtos-lib|none-safertos} {|link}"
	echo ""
	echo "   mbed-none ................. creates a bare-metal project with mbed SDK"
	echo "   mbed-none-BB .............. creates a bare-metal project with mbed SDK, cpputest support and redirected STDIO tailored to STM32F4-BB expansion board"
	echo "   mbed-none-sh[|cpput] ...... creates a bare-metal project with mbed SDK, cpputest and ARM semihosting support"
	echo "   mbed-none-shgtest ......... creates a bare-metal project with mbed SDK, googletest and ARM semihosting support"
	echo "   mbed-none-shsim[|cpput] ... creates a bare-metal project with mbed SDK and cpputest support suitable for (ARM semihosted) QEMU simulation"
	echo "   mbed-none-shsimgtest ...... creates a bare-metal project with mbed SDK and googletest support suitable for (ARM semihosted) QEMU simulation"
	echo "   mbed-none-lib ............. creates a bare-metal project with mbed SDK"
	echo "   mbed-freertos ............. creates a FreeRTOS project with mbed SDK (/w libraries)"
	echo "   mbed-freertos-lib ......... creates a FreeRTOS project with mbed SDK (/w libraries)"
	echo "   mbed-mbedrtos ............. creates a mbedRTOS project with mbed SDK"
	echo "   mbed-mbedrtos-lib ......... creates a mbedRTOS project with mbed SDK (/w libraries)"
	echo "   none-safertos ............. creates a SafeRTOS project"
	echo " "
	echo "   link ...................... symlink files instead of copy"
	echo " "
	;;
  *)
	echo "Usage: $SCRIPTNAME {mbed-none|mbed-none-BB|mbed-none-lib|"
	echo "                    mbed-none-sh|mbed-none-shcpput|mbed-none-shgtest|"
	echo "                    mbed-none-shsim|mbed-none-shsimcpput|mbed-none-shsimgtest"
	echo "                    mbed-freertos|mbed-freertos-lib|"
	echo "                    mbed-mbedrtos|mbed-mbedrtos-lib|"
	echo "                    none-safertos} {|link}"
	exit 3
	;;
esac
