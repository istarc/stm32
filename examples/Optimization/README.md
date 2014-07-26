Prerequisites:
* Ubuntu 14.04 LTS
* STM32F4 Discovery Board

Install software dependencies:
* sudo apt-get install build-essential git openocd
* libstdc++ library is missing in official arm-none-eabi toolchain, install the toolchain from the third-party PPA repository.
	* sudo apt-get purge binutils-arm-none-eabi gcc-arm-none-eabi gdb-arm-none-eabi libnewlib-arm-none-eabi
	* sudo add-apt-repository ppa:terry.guo/gcc-arm-embedded
	* sudo apt-get update
	* sudo apt-get policy gcc-arm-none-eabi # Check the PPA version
	* sudo apt-get install gcc-arm-none-eabi=4-8-2014q2-0trusty10
* sudo apt-get install python3 octave
* git clone https://github.com/istarc/stm32.git

Build:
* cd stm32/examples/Optimization
* make clean && make release-memopt # Use all available optimizations
* make clean && make release-memopt OPT='O1 O2 O3 O4 O4 O5 O6 O7 O8' # Manually select optimizations

Identify space-wasting code:
* make clean && make release-memopt-blame

Benchmark:
* python3 benchmark-singleopt.py # Isolated optimizations
* python3 benchmark-multiopt.py  # Optimization combinations
* octave benchmark.m # Generate results.png

Deploy:
* make deploy

More info:
* [Optimizations](http://istarc.wordpress.com/2014/07/26/stm32f4-optimizations/)
