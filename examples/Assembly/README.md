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
* Assembly: [Mixing C & Assembly for Fun and Profit]()
