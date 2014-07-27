Prerequisites:
* Ubuntu 14.04 LTS
* STM32F4 Discovery Board

Install software dependencies:
* sudo apt-get install build-essential git binutils-arm-none-eabi gcc-arm-none-eabi libnewlib-arm-none-eabi gdb-arm-none-eabi eclipse-cdt openocd

Build:
* make clean && make release # OR
* make clean && make release-memopt # OR
* make clean && make debug

Deploy:
* make deploy

More info:
* [Template Project with Generic Makefile](http://istarc.wordpress.com/2014/07/01/stm32f4/)
* [In-circuit Debugging](http://istarc.wordpress.com/2014/07/06/stm32f4-in-circuit-debugging/)
