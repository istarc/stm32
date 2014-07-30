Prerequisites:
* Ubuntu 14.04 LTS
* STM32F4 Discovery Board

Install software dependencies:
* sudo apt-get install build-essential git binutils-arm-none-eabi gcc-arm-none-eabi libnewlib-arm-none-eabi gdb-arm-none-eabi openocd
* git clone https://github.com/istarc/stm32.git && cd stm32 && git submodule update --init

Build:
* make clean && make release # OR
* make clean && make release-memopt # OR
* make clean && make debug

Deploy:
* make deploy

More info:
* [Template Project with mbed SDK](http://istarc.wordpress.com/2014/07/28/stm32f4-template-project-with-the-mbed-sdk/)
