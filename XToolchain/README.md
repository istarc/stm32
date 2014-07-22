Prerequisites:
* Ubuntu 14.04 LTS
* STM32F4 Discovery Board

Install software dependencies:
* sudo apt-get purge binutils-arm-none-eabi gcc-arm-none-eabi libnewlib-arm-none-eabi gdb-arm-none-eabi # You may remove offical toolchain to avoid potential conflicts
* sudo apt-get install build-essential git openocd
* sudo apt-get install libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev # Required to build GCC

Build:
* bash build.sh

Test:
* export PATH=$PATH
* cd ../examples/Assembly (or GPIO, FreeRTOS, OOP)
* make clean && make release # OR
* make clean && make release-memopt # OR
* make clean && make debug
* make deploy

More info:
* [Build Your Own GNU ARM Cross-Toolchain From Scratch](http://istarc.wordpress.com/2014/07/21/stm32f4-build-your-toolchain-from-scratch/)
