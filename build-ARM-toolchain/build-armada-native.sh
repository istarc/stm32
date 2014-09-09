#!/bin/bash

# GNU ARM Cross-Toolchain Builder (Native)

###
# Builds GNU ARM Cross-Toolchain from Scratch
#
#  Host:   Ubuntu 14.04 LTS x86_64
#  Target: -||-
#
# Features:
# - GNU C (4.9.1)
# - GNU C++ (4.9.1, implements: C++14, C++11)
# -  with libstdc++ (4.9.1)

###
# Prerequisites:
# - Ubuntu 14.04 GNU/Linux.
#
# - Cloned stm32 repository.
#    - git clone https://github.com/istarc/stm32.git
#
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
export GCCV=gcc-4.9.1
export NEWLIB=newlib-2.1.0
export GDB=gdb-7.8
export BOOTSTR_GNAT=gnat-gpl-2014-x86_64-linux-bin
export BOOTSTR_GNAT_SRC='http://mirrors.cdn.adacore.com/art/7427735035ecc98968ebfcee17494161b0de28ef'
# 1.3 Build directory
export PREFIX=~/gcc
export PATH=$PREFIX/bin:/usr/local/bin:/usr/bin:$PATH
export LD_LIBRARY_PATH=$PREFIX/lib:$PREFIX/lib64:$LD_LIBRARY_PATH
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
if [ ! -f $GCCV.tar.gz ]; then
	wget ftp://ftp.gnu.org/gnu/gcc/$GCCV/$GCCV.tar.gz
fi
if [ ! -d $PREFIX/src/$GCCV ]; then
	cd $PREFIX/src
	tar xzf $PREFIX/orig/$GCCV.tar.gz
fi
# 2.3 Create build directories
cd $PREFIX/build
for x in $(ls $PREFIX/src); do
	if [ ! -d $x ]; then
		mkdir $x
	fi
done
# 2.2.8 Download boostrap GNAT
#cd $PREFIX/orig
#if [ ! -f $BOOTSTR_GNAT.tar.gz ]; then
#        wget --content-disposition $BOOTSTR_GNAT_SRC
#fi
# 2.2.9 Unpack bootstrap GNAT and setup PATH
#if [ ! -d $PREFIX/tmp/$BOOTSTR_GNAT ]; then
#        cd $PREFIX/tmp
#        tar xzf $PREFIX/orig/$BOOTSTR_GNAT.tar.gz
#fi
# 2.2.10 Setup Links to gnat
#cd $PREFIX/bin
#rm -f $PREFIX/bin/gnat* # Remove symlinks
#rm -f $PREFIX/bin/gcc
#cp -s $PREFIX/tmp/$BOOTSTR_GNAT/bin/gnat* $PREFIX/bin # Copy by symlinking files
#cp -s $PREFIX/tmp/$BOOTSTR_GNAT/bin/gcc $PREFIX/bin
#symlinks -rc $PREFIX/bin # Make symlinks relative
# 2.2.11 Check gcc version
#echo $(gnat --version) 
#read -r -p "Press a key to continue? [y/N] " response

### 
# 3. Build & install GNU ARM cross-toolchain
# 3.1 Build Binutils
#cd $PREFIX/build/$BINUTILS
#$PREFIX/src/$BINUTILS/configure --prefix=$PREFIX --with-gnu-as --with-gnu-ld 
#make clean
#make -j4 all
#make install

# 3.2 Build & install GCC
cd $PREFIX/build/$GCCV
$PREFIX/src/$GCCV/configure --prefix=$PREFIX --enable-multilib --enable-threads=posix --enable-shared --with-gnu-as --with-gnu-ld --enable-languages="c,c++,ada" --with-system-zlib --disable-nls
#make clean
make -j4 all
make install

echo ""
echo "### END ###"
echo ""

