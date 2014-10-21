#!/bin/bash

# Setups Buildbot Environment

###
# Setups Buildbot Environment
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
if [ -d "$PREFIX/stm32bb" ]; then
	echo ""
	echo "The following directories may be overwritten."
	echo " - $PREFIX/stm32bb"
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
# 1.2.1 Buildbot
sudo apt-get install -y buildbot buildbot-slave
# 2. Setup buildbot master and workers
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

echo ""
echo "### END ###"
echo ""
