Prerequisites:
* Ubuntu 14.04 LTS
* STM32F4 Discovery Board

Install software dependencies:
* sudo apt-get install build-essential git binutils-arm-none-eabi gcc-arm-none-eabi libnewlib-arm-none-eabi openocd

Build:
* make clean && make release # OR
* make clean && make release-memopt # OR
* make clean && make debug

Deploy:
* make deploy

More info:
* [Deploy FreeRTOS Embedded OS under 10 seconds!](http://istarc.wordpress.com/2014/07/10/stm32f4-deploy-an-embedded-os-under-10-seconds/)
