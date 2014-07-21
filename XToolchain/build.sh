#!/bin/bash
#
# Build ARM Toolchain From Scratch on Ubuntu 14.04 GNU/Linux.
# Author: Iztok Starc <iztok.st...
#
# This script is based on http://hermann-uwe.de/files/build-arm-toolchain
# 
# Install Prerequisties:
# sudo apt-get install build-essential git libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev
# git clone https://github.com/istarc/stm32.git
#
# Remove Official Toolchain or Change PATH Precedence
# sudo apt-get purge binutils-arm-none-eabi gcc-arm-none-eabi gdb-arm-none-eabi libnewlib-arm-none-eabi
#

# Define Variables
export BINUTILS=binutils-2.24
export GCC=gcc-4.9.1
export NEWLIB=newlib-2.1.0
export GDB=gdb-7.7

export TARGET=arm-none-eabi

export PREFIX=~/arm
export PATH=$PATH:$PREFIX/bin
export SCRIPTDIR=`pwd`

# Create Build directory structure
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/build
mkdir -p $PREFIX/orig
mkdir -p $PREFIX/src

# Download the Latest Source Archives
cd $PREFIX/orig
wget ftp://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.gz
wget ftp://ftp.gnu.org/gnu/gcc/$GCC.tar.gz
wget ftp://sources.redhat.com/pub/newlib/$NEWLIB.tar.gz
wget ftp://ftp.gnu.org/gnu/gdb/$GDB.tar.gz

# Unpack Tar Source Archives
cd $PREFIX/src
ls $PREFIX/orig/*tar.gz | xargs -i tar xzf {}
# Patch the Newlib if Version = 2.1.0
if [ $NEWLIB -eq "newlib-2.1.0" ]; then
	cd $PREFIX/src/$NEWLIB
	patch -p0 < $SCRIPTDIR/newlib-2.1.0.patch
fi

# Create Build Directories
cd $PREFIX/build
mkdir `ls $PREFIX/src`

## Build & Install the Cross-Toolchain
# Build Binutils
cd $PREFIX/build/$BINUTILS
$PREFIX/src/$BINUTILS/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-multilib --with-gnu-as --with-gnu-ld --disable-nls

make -j8 all
make install

# Build & Install Bootstrap GCC (C Compiler Only)
cd $PREFIX/build/$GCC
$PREFIX/src/$GCC/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-multilib --enable-languages="c" --with-system-zlib --with-newlib --without-headers --disable-shared --disable-nls --with-gnu-as --with-gnu-ld

make -j8 all-gcc
make install-gcc

# Build & Install Newlib Library
cd $PREFIX/build/$NEWLIB
$PREFIX/src/$NEWLIB/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-multilib --disable-newlib-supplied-syscalls --with-gnu-as --with-gnu-ld --disable-nls

make -j8 all
make install

# Build & Install GCC C, C++, libstdc++ /w newlib
cd $PREFIX/build/$GCC
$PREFIX/src/$GCC/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-interwork --enable-multilib --enable-languages="c,c++" --with-system-zlib --with-newlib --disable-shared --disable-nls --with-gnu-as --with-gnu-ld

make -j8 all
make install

# Build & Install GDB
$PREFIX/src/$GDB/configure --target=$TARGET --prefix=$PREFIX --enable-interwork --enable-multilib

make -j8 all
make install

## Test the Toolchain
#cd ~stm32/examples/Assembly
#make clean && make -j 8 release
#make clean && make -j 8 release-memopt
#make clean && make -j 8 debug

