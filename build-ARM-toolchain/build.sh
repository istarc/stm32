#!/bin/bash
# GNU ARM Cross-Toolchain Builder

###
# Builds GNU ARM Cross-Toolchain from Scratch
#  Host:   x86_64
#  Target: cortex-m4f

###
# Prerequisites:
# - Ubuntu 14.04 GNU/Linux.
#
# - Cloned stm32 repository.
#    - git clone https://github.com/istarc/stm32.git
#
# - It may depend on newlib-2.1.0.patch. Run from stm32/build-ARM-toolchain directory.
#
# - Before running this script make sure that:
#    - You install dependencies:
#        sudo apt-get install build-essential git libgmp-dev 
#                             libmpfr-dev libmpc-dev zlib1g-dev
#
#    - Due to the potential conflicts:
#        - Remove the official toolchain:
#           sudo apt-get purge binutils-arm-none-eabi gcc-arm-none-eabi 
#                              gdb-arm-none-eabi libnewlib-arm-none-eabi
#
#        - OR change the PATH variable precedence:
#           export PATH=$PREFIX/bin:$PATH

###
# Test the Toolchain
# - Connect STM32F4 Discovery Board
# - Open a new console and type
#    export PATH=$PATH:$PREFIX/bin
#    cd stm32/examples/OOP
#    make clean && make all
#    make deploy

###
# Check My Blog ;-)
#  istarc.wordpress.com

###
# 1. Define Variables
# 1.1 GNU Toolchain
export BINUTILS=binutils-2.24
export GCC=gcc-4.9.1
export NEWLIB=newlib-2.1.0
export GDB=gdb-7.7
# 1.2 Target system
export TARGET=arm-none-eabi
# 1.3 Build directory
export PREFIX=~/arm
export PATH=$PATH:$PREFIX/bin
export SCRIPTDIR=`pwd`

###
# 2. Prepare the build environment
# 2.1 Create the directory structure
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/build
mkdir -p $PREFIX/orig
mkdir -p $PREFIX/src
# 2.2 Download and untar the source archives
cd $PREFIX/orig
if [ ! -f $BINUTILS.tar.gz ]; then
	wget ftp://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.gz
	cd $PREFIX/src
	tar xzf $PREFIX/orig/$BINUTILS.tar.gz
fi

cd $PREFIX/orig
if [ ! -f $GCC.tar.gz ]; then
	wget ftp://ftp.gnu.org/gnu/gcc/$GCC/$GCC.tar.gz
	cd $PREFIX/src
	tar xzf $PREFIX/orig/$GCC.tar.gz
fi

cd $PREFIX/orig
if [ ! -f $NEWLIB.tar.gz ]; then
	wget ftp://sources.redhat.com/pub/newlib/$NEWLIB.tar.gz
	cd $PREFIX/src
	tar xzf $PREFIX/orig/$NEWLIB.tar.gz
	if [ $NEWLIB -eq "newlib-2.1.0" ]; then
		cd $PREFIX/src/$NEWLIB
		patch -p0 < $SCRIPTDIR/newlib-2.1.0.patch/
	fi
fi

cd $PREFIX/orig
if [ ! -f $GDB.tar.gz ]; then
	wget ftp://ftp.gnu.org/gnu/gdb/$GDB.tar.gz
	cd $PREFIX/src
	tar xzf $PREFIX/orig/$GDB.tar.gz
fi
# 2.5 Create the build directories
cd $PREFIX/build
mkdir `ls $PREFIX/src`

### 
# 3. Build & install GNU ARM cross-toolchain
# 3.1 Build Binutils
cd $PREFIX/build/$BINUTILS
make clean
$PREFIX/src/$BINUTILS/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-multilib --with-gnu-as --with-gnu-ld --disable-nls
# The meaning of flags:
# --with-cpu=cortex-m4 ..... cortex-m4 CPU
# --with-fpu=fpv4-sp-d16 ... this CPU has fpv4-sp-d16 FPU
# --with-float=hard ........ use HW FPU (do not simulate in SW)
# --with-mode=thumb ........ use Thumb instruction set
# --enable-interwork ....... supports calling between ARM and Thumb instruction set
# --enable-multilib ........ builds for any other unspecified configuration
# --with-gnu-as ............ use only GNU Assembler
# --with-gnu-ld ............ use only GNU Linker
# --disable-nls ............ output only in English
make -j4 all
make install
# 3.2 Build & install bootstrap GCC (C cross-compiler only)
cd $PREFIX/build/$GCC
make clean
$PREFIX/src/$GCC/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-multilib --enable-languages="c" --with-system-zlib --with-newlib --without-headers --disable-shared --disable-nls --with-gnu-as --with-gnu-ld
# The meaning of flags (see https://gcc.gnu.org/install/configure.html):
# --with-system-zlib ...... use the system's zlib library

# The meaning of flags:
# --with-newlib ........... newlib is going to be used as the target C library
# --without-headers ....... do not use target headers from libc (newlib) when building, because newlib is not build yet.
# --disable-shared ........ only static libraries, because shared are not supported on the target platform
make -j4 all-gcc
make install-gcc
# 3.3 Build & install newlib library
cd $PREFIX/build/$NEWLIB
make clean
$PREFIX/src/$NEWLIB/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-multilib --disable-newlib-supplied-syscalls --with-gnu-as --with-gnu-ld --disable-nls
# The meaning of flags:
# --disable-newlib-supplied-syscalls ... disable syscalls, because we are building for bare-metal target.
make -j4 all
make install
# Build & install GCC C, C++, libstdc++ with newlib library
cd $PREFIX/build/$GCC
$PREFIX/src/$GCC/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-interwork --enable-multilib --enable-languages="c,c++" --with-system-zlib --with-newlib --disable-shared --disable-nls --with-gnu-as --with-gnu-ld
make -j4 all
make install
# Build & install GDB debugger
$PREFIX/src/$GDB/configure --target=$TARGET --prefix=$PREFIX --enable-interwork --enable-multilib
make -j4 all
make install

