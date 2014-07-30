Prerequisites:
* Ubuntu 14.04 LTS
* STM32F4 Discovery Board

Install software dependencies:
* `sudo apt-get install build-essential git openocd`
* libstdc++ library is missing in official arm-none-eabi toolchain, install the toolchain from the third-party PPA repository.
   * `sudo add-apt-repository ppa:terry.guo/gcc-arm-embedded`
   * `sudo apt-get update`
   * `sudo apt-cache policy gcc-arm-embedded # Check the PPA version`
   * `sudo apt-get install gcc-arm-none-eabi=4-8-2014q2-0trusty10`
* `git clone https://github.com/istarc/stm32.git`
* `cd stm32`
* `git submodule update --init`

Build:
* `make clean && make release` # OR
* `make clean && make release-memopt` # OR
* `make clean && make debug`

Deploy:
* `make deploy`

More info:
* [Template Project with mbed SDK](http://istarc.wordpress.com/2014/07/28/stm32f4-template-project-with-the-mbed-sdk/)
* [Object-oriented Programming with Embedded Systems (C++ /w STL)](http://istarc.wordpress.com/2014/07/18/stm32f4-object-oriented-programming-c-with-embedded-systems/)

