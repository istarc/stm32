This is project generation utility for ARM embedded devices. 

Prerequisites:
* Ubuntu 14.04 LTS
* STM32F4 Discovery Board

Install software dependencies:
* `sudo apt-get install build-essential git binutils-arm-none-eabi gcc-arm-none-eabi libnewlib-arm-none-eabi gdb-arm-none-eabi openocd symlink`
* `git clone https://github.com/istarc/stm32.git`
* `cd stm32 && git submodule update --init`

Scripts:
* gen-stm32f407-GCC-project.sh
	* mbed-none\[-lib\] - Bare-metal project /w mbed SDK \[with library\].
	* mbed-freertos\[-lib\] - FreeRTOS project /w mbed SDK \[with library\].
	* mbed-mbedrtos\[-lib\] - mbedRTOS project /w mbed SDK \[with library\].

	* Use case 1:
		* `mkdir -p stm32/examples/test`
		* `cd stm32/examples/test`
		* `../../createProject/gen-stm32f407-GCC-project.sh mbed-mbedrtos`
		* `make clean`
		* `make make -j4`
		* `make deploy`

	* Use case 2:
		* `mkdir -p stm32/examples/test`
		* `cd stm32/examples/test`
		* `../../createProject/gen-stm32f407-GCC-project.sh mbed-mbedrtos-lib`
		* `make clean`
		* `make -j4 libs`
		* `make -j4`
		* `make deploy`


