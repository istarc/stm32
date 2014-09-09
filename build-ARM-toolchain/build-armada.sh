#!/bin/bash

# GNU ARM Cross-Toolchain Builder

###
# Builds GNU ARM Cross-Toolchain from Scratch
#
#  Host:   Ubuntu 14.04 LTS x86_64
#  Target: ARM cortex-m4f
#
# Features:
# - GNU C (4.9.1)
# -  with newlib (2.1.0)
# - GNU C++ (4.9.1, implements: C++14, C++11)
# -  with libstdc++ (4.9.1)
# - GDB (7.8)

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
#    export PATH=$PREFIX/bin:$PATH
#    cd stm32/examples/OOP
#    make clean && make all
#    make deploy

###
# Check My Blog
#  http://istarc.wordpress.com

###
# 0. Install dependencies
export DEBIAN_FRONTEND=noninteractive
#sudo apt-get update -q
#sudo apt-get install -y symlinks build-essential git libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev libtool 

###
# 1. Define Variables
# 1.1 GNU Toolchain
export BINUTILS=binutils-2.24
export GCC=gcc-4.9.1
export NEWLIB=newlib-2.1.0
export GDB=gdb-7.8
export BOOTSTR_GNAT=gnat-gpl-2014-x86_64-linux-bin
export BOOTSTR_GNAT_SRC='http://mirrors.cdn.adacore.com/art/7427735035ecc98968ebfcee17494161b0de28ef'
# 1.2 Target system
export TARGET=arm-none-eabi
# 1.3 Build directory
export PREFIX=~/arm
export PATH=$PREFIX/bin:$PATH
export SCRIPTDIR=$(pwd)
# 1.4 Stop on first error
set -e
# 1.5 Be verbose
set -x
# 1.6 Check if clean
if [ -d "$PREFIX" ]; then
        echo ""
        echo "The following directories may be overwritten."
        echo " - $PREFIX"
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

###
# 2. Prepare the build environment
# 2.1 Create the directory structure
if [ ! -d $PREFIX/bin ]; then
	mkdir -p $PREFIX/bin
fi
if [ ! -d $PREFIX/build ]; then
	mkdir -p $PREFIX/build
fi
if [ ! -d $PREFIX/orig ]; then
	mkdir -p $PREFIX/orig
fi
if [ ! -d $PREFIX/src ]; then
	mkdir -p $PREFIX/src
fi
if [ ! -d $PREFIX/tmp ]; then
        mkdir -p $PREFIX/tmp
fi
# 2.2 Download and unpack the source archives
# 2.2.1 Download Binutils
cd $PREFIX/orig
if [ ! -f $BINUTILS.tar.gz ]; then
	wget ftp://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.gz
fi
# 2.2.2 Unpack Binutils
if [ ! -d $PREFIX/src/$BINUTILS ]; then
	cd $PREFIX/src
	tar xzf $PREFIX/orig/$BINUTILS.tar.gz
fi
# 2.2.3 Download GCC
cd $PREFIX/orig
if [ ! -f $GCC.tar.gz ]; then
	wget ftp://ftp.gnu.org/gnu/gcc/$GCC/$GCC.tar.gz
fi
if [ ! -d $PREFIX/src/$GCC ]; then
	cd $PREFIX/src
	tar xzf $PREFIX/orig/$GCC.tar.gz
fi
# 2.2.4 Download Newlib
cd $PREFIX/orig
if [ ! -f $NEWLIB.tar.gz ]; then
	wget ftp://sources.redhat.com/pub/newlib/$NEWLIB.tar.gz
fi
# 2.2.5 Unpack Newlib
if [ ! -d $PREFIX/src/$NEWLIB ]; then
	cd $PREFIX/src
	tar xzf $PREFIX/orig/$NEWLIB.tar.gz
	if [ $NEWLIB -eq "newlib-2.1.0" ]; then
		cd $PREFIX/src/$NEWLIB
		patch -p0 < $SCRIPTDIR/newlib-2.1.0.patch/
	fi
fi
# 2.2.6 Download GDB
cd $PREFIX/orig
if [ ! -f $GDB.tar.gz ]; then
	wget ftp://ftp.gnu.org/gnu/gdb/$GDB.tar.gz
fi
# 2.2.7 Unpack GDB
if [ ! -d $PREFIX/src/$GDB ]; then
	cd $PREFIX/src
	tar xzf $PREFIX/orig/$GDB.tar.gz
fi
# 2.3 Create build directories
cd $PREFIX/build
for x in $(ls $PREFIX/src); do
	if [ ! -d $x ]; then
		mkdir $x
	fi
done
# 2.2.8 Download boostrap GNAT
cd $PREFIX/orig
if [ ! -f $BOOTSTR_GNAT.tar.gz ]; then
        wget --content-disposition $BOOTSTR_GNAT_SRC
fi
# 2.2.9 Unpack bootstrap GNAT and setup PATH
if [ ! -d $PREFIX/tmp/$BOOTSTR_GNAT ]; then
        cd $PREFIX/tmp
        tar xzf $PREFIX/orig/$BOOTSTR_GNAT.tar.gz
fi
# 2.2.10 Setup Links to gnat
cd $PREFIX/bin
rm -f $PREFIX/bin/gnat* # Remove symlinks
rm -f $PREFIX/bin/gcc
cp -s $PREFIX/tmp/$BOOTSTR_GNAT/bin/gnat* $PREFIX/bin # Copy by symlinking files
cp -s $PREFIX/tmp/$BOOTSTR_GNAT/bin/gcc $PREFIX/bin
symlinks -rc $PREFIX/bin # Make symlinks relative
# 2.2.11 Check gcc version
#echo $(gnat --version) 
#read -r -p "Press a key to continue? [y/N] " response

### 
# 3. Build & install GNU ARM cross-toolchain
# 3.1 Build Binutils
cd $PREFIX/build/$BINUTILS
$PREFIX/src/$BINUTILS/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --disable-multilib --with-gnu-as --with-gnu-ld --disable-nls
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
make clean
make -j4 all
make install

# 3.2 Build & install bootstrap GCC (C cross-compiler only)
cd $PREFIX/build/$GCC
$PREFIX/src/$GCC/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --disable-multilib --with-system-zlib --with-newlib --without-headers --disable-shared --disable-nls --with-gnu-as --with-gnu-ld --enable-languages="c"
# The meaning of flags (see https://gcc.gnu.org/install/configure.html):
# --with-system-zlib ...... use the system's zlib library

# The meaning of flags:
# --with-newlib ........... newlib is going to be used as the target C library
# --without-headers ....... do not use target headers from libc (newlib) when building, because newlib is not build yet.
# --disable-shared ........ only static libraries, because shared are not supported on the target platform
make clean
make -j4 all-gcc
make install-gcc

# 3.3 Build & install newlib library
cd $PREFIX/build/$NEWLIB
$PREFIX/src/$NEWLIB/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-multilib --disable-newlib-supplied-syscalls --with-gnu-as --with-gnu-ld --disable-nls --enable-newlib-nano-malloc
# The meaning of flags:
# --disable-newlib-supplied-syscalls ... disable syscalls, because we are building for bare-metal target.
# --enable-newlib-nano-malloc ... enable nano implementation of malloc suitable for devices with limited memory resources
make clean
make -j4 all
make install

# 3.4 Build & install GCC C, C++, libstdc++ with newlib library
cd $PREFIX/build/$GCC
$PREFIX/src/$GCC/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-clocale=gnu --with-system-zlib --with-newlib --disable-multilib --disable-shared --disable-nls --disable-threads --disable-lto --disable-libssp --disable-werror --with-gnu-as --with-gnu-ld --enable-languages="c,c++,ada" --enable-cross-gnattools --disable-libquadmath-support --disable-libstdcxx --disable-libgomp
make clean
make -j4 all all-gnattools
make install install-gnattools

# 3.5 Build & install GDB debugger
cd $PREFIX/build/$GDB
$PREFIX/src/$GDB/configure --target=$TARGET --prefix=$PREFIX
#make clean
#make -j4
#make install

echo ""
echo "### END ###"
echo ""

