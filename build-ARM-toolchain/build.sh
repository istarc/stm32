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
sudo apt-get update -q
sudo apt-get install -y build-essential git libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev libtool

###
# 1. Define Variables
# 1.1 GNU Toolchain
export BINUTILS=binutils-2.25
export GCC=gcc-4.9.2
export NEWLIB=newlib-2.1.0
export NEWLIB_NANO=newlib-nano-2.1.0
export GDB=gdb-7.8
# 1.2 Target system
export TARGET=arm-none-eabi
# 1.3 Build directory
export PREFIX=~/arm
OLDPATH=$PATH
export PATH=$PREFIX/bin:$OLDPATH
export SCRIPTDIR=$(pwd)
# 1.4 Stop on first error
set -e
# 1.5 Be verbose
# set -x
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
# 2.2.6 Download Newlib-nano
cd $PREFIX/orig
if [ ! -d $NEWLIB_NANO ]; then
	git clone --depth 1 --branch master https://github.com/istarc/newlib-nano-2.git $NEWLIB_NANO
else
	cd $NEWLIB_NANO && git pull
fi
# 2.2.7 Copy Newlib-nano
if [ ! -d $PREFIX/src/$NEWLIB_NANO ]; then
	cd $PREFIX/src
	rsync -a --exclude .git $PREFIX/orig/$NEWLIB_NANO/ $(pwd)/$NEWLIB_NANO
	chmod +x $(pwd)/$NEWLIB_NANO/configure
	# Hotfix: copy missing config.h from newlib to newlib-nano
	cp $PREFIX/src/$NEWLIB/newlib/libc/include/sys/config.h $PREFIX/src/$NEWLIB_NANO/newlib/libc/include/sys/config.h
fi
# 2.2.8 Download GDB
cd $PREFIX/orig
if [ ! -f $GDB.tar.gz ]; then
	wget ftp://ftp.gnu.org/gnu/gdb/$GDB.tar.gz
fi
# 2.2.9 Unpack GDB
if [ ! -d $PREFIX/src/$GDB ]; then
	cd $PREFIX/src
	tar xzf $PREFIX/orig/$GDB.tar.gz
fi
# 2.3 Create build directories
cd $PREFIX/build
mkdir -p $BINUTILS
mkdir -p $BINUTILS-nano
mkdir -p $GCC-boot
mkdir -p $GCC-nanoboot
mkdir -p $NEWLIB
mkdir -p $NEWLIB_NANO
mkdir -p $GCC
mkdir -p $GCC-nano
mkdir -p $GDB

### 
# 3. Build & install GNU ARM cross-toolchain
#
#              START 
#                |
# [build GCC /w  |          [build GCC /w
#        newlib] |           newlib-nano]
#   +<-----------+----------->+
#   |                         |
# BINUTILS 3.1              BINUTILS 3.2
#   |                         |
# GCC-boot 3.3              GCC-nanoboot 3.4
#   |                         |
# NEWLIB 3.5                NEWLIB_NANO 3.6
#   |                         |
# GCC 3.7                   GCC-nano 3.8
#   |                         |
#   +<--[copy nano-libs 3.9]--+
#   |
#   +------------+
#                |
#               GDB 3.10
#                |
#               END
#
# 3.1 Build Binutils
export PATH=$PREFIX/bin:$OLDPATH
cd $PREFIX/build/$BINUTILS
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
# make clean
make -j4 all
make install

# 3.2 Build Binutils-nano
export PATH=$PREFIX/build/nano-libs/bin:$OLDPATH
cd $PREFIX/build/$BINUTILS-nano
$PREFIX/src/$BINUTILS/configure --target=$TARGET --prefix=$PREFIX/build/nano-libs --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-multilib --with-gnu-as --with-gnu-ld --disable-nls
# make clean
make -j4 all
make install

# 3.3 Build & install bootstrap GCC (C cross-compiler only)
export PATH=$PREFIX/bin:$OLDPATH
cd $PREFIX/build/$GCC-boot
$PREFIX/src/$GCC/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-multilib --with-system-zlib --with-newlib --without-headers --disable-shared --disable-nls --with-gnu-as --with-gnu-ld --enable-languages="c"
# The meaning of flags (see https://gcc.gnu.org/install/configure.html):
# --with-system-zlib ...... use the system's zlib library
# The meaning of flags:
# --with-newlib ........... newlib is going to be used as the target C library
# --without-headers ....... do not use target headers from libc (newlib) when building, because newlib is not build yet.
# --disable-shared ........ only static libraries, because shared are not supported on the target platform
# make clean
make -j4 all-gcc
make install-gcc

# 3.4 Build & install bootstrap GCC-nanoboot (C cross-compiler only)
export PATH=$PREFIX/build/nano-libs/bin:$OLDPATH
cd $PREFIX/build/$GCC-nanoboot
$PREFIX/src/$GCC/configure --target=$TARGET --prefix=$PREFIX/build/nano-libs --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-multilib --with-system-zlib --with-newlib --without-headers --disable-shared --disable-nls --with-gnu-as --with-gnu-ld --enable-languages="c"
# make clean
make -j4 all-gcc
make install-gcc

# 3.5 Build & install newlib library
export PATH=$PREFIX/bin:$OLDPATH
cd $PREFIX/build/$NEWLIB
$PREFIX/src/$NEWLIB/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-multilib --disable-newlib-supplied-syscalls --with-gnu-as --with-gnu-ld --disable-nls --enable-newlib-nano-malloc
# The meaning of flags:
# --disable-newlib-supplied-syscalls ... disable syscalls, because we are building for bare-metal target.
# --enable-newlib-nano-malloc ... enable nano implementation of malloc suitable for devices with limited memory resources
# make clean
make -j4 all
make install

# 3.6 Build & install newlib library
export PATH=$PREFIX/build/nano-libs/bin:$OLDPATH
cd $PREFIX/build/$NEWLIB_NANO
$PREFIX/src/$NEWLIB_NANO/configure --target=$TARGET --prefix=$PREFIX/build/nano-libs  --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-multilib --with-gnu-as --with-gnu-ld --disable-nls --disable-newlib-supplied-syscalls --enable-newlib-reent-small --disable-newlib-fvwrite-in-streamio --disable-newlib-fseek-optimization --disable-newlib-wide-orient --enable-newlib-nano-malloc --disable-newlib-unbuf-stream-opt --enable-lite-exit --enable-newlib-global-atexit
# The meaning of flags:
# --disable-newlib-supplied-syscalls ... disable syscalls, because we are building for bare-metal target.
# --enable-newlib-nano-malloc ... enable nano implementation of malloc suitable for devices with limited memory resources
make -j4 all
make install

# 3.7 Build & install GCC C, C++, libstdc++ with newlib library
export PATH=$PREFIX/bin:$OLDPATH
cd $PREFIX/build/$GCC
$PREFIX/src/$GCC/configure --target=$TARGET --prefix=$PREFIX --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-interwork --enable-multilib --with-system-zlib --with-newlib --disable-shared --disable-nls --with-gnu-as --with-gnu-ld --enable-languages="c,c++"
# make clean
make -j4 all
make install

# 3.8 Build & install GCC C, C++, libstdc++ with newlib-nano library
export PATH=$PREFIX/build/nano-libs/bin:$OLDPATH
cd $PREFIX/build/$GCC-nano
$PREFIX/src/$GCC/configure --target=$TARGET --prefix=$PREFIX/build/nano-libs --with-cpu=cortex-m4 --with-fpu=fpv4-sp-d16 --with-float=hard --with-mode=thumb --enable-interwork --enable-interwork --enable-multilib --with-system-zlib --with-newlib --disable-shared --disable-nls --with-gnu-as --with-gnu-ld --enable-languages="c,c++"
# make clean
make -j4 all
make install # To $PREFIX/build/nano-libs

# 3.9 Install newlib-nano multilibs to $PREFIX path
#     according to nano.specs naming convention
SRCDIR=$PREFIX/build/nano-libs/arm-none-eabi/lib
DSTDIR=$PREFIX/arm-none-eabi/lib 
cp $SRCDIR/./libstdc++.a $DSTDIR/./libstdc++_s.a
cp $SRCDIR/./libsupc++.a $DSTDIR/./libsupc++_s.a
for mldir in "." "fpu" "thumb"; do
	cp $SRCDIR/$mldir/libc.a $DSTDIR/$mldir/libc_s.a
	cp $SRCDIR/$mldir/libg.a $DSTDIR/$mldir/libg_s.a
	cp $SRCDIR/$mldir/librdimon.a $DSTDIR/$mldir/librdimon_s.a
	cp $SRCDIR/$mldir/nano.specs $DSTDIR/$mldir/
	cp $SRCDIR/$mldir/rdimon.specs $DSTDIR/$mldir/
	cp $SRCDIR/$mldir/nosys.specs $DSTDIR/$mldir/
	cp $SRCDIR/$mldir/*crt0.o $DSTDIR/$mldir/
done

# 3.10 Build & install GDB debugger
export PATH=$PREFIX/bin:$OLDPATH
cd $PREFIX/build/$GDB
$PREFIX/src/$GDB/configure --target=$TARGET --prefix=$PREFIX
# make clean
make -j4
make install

echo ""
echo "### END ###"
echo ""
cat << EOF | tee $PREFIX/README
Created by ${0##*/}

Includes:
	$BINUTILS
	$GCC
	$NEWLIB
	$NEWLIB_NANO
	$GDB

Usage:
	export PATH=~/arm/bin:\$PATH
	arm-none-eabi-gcc -v
	arm-none-eabi-g++ -v

Build an Example:
	export PATH=~/arm/bin:\$PATH
	cd ~
	git clone https://github.com/istarc/stm32.git
	cd ~/stm32
	git submodule update --init
	make

Git info:
	stm32: "$(git rev-parse --short=10 HEAD)" ("$(git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>/dev/null)")
EOF
