Prerequisites:
* Ubuntu 14.04 LTS
* STM32F4 Discovery Board

Install software dependencies:
* `cd ~`
* `sudo add-apt-repository ppa:terry.guo/gcc-arm-embedded`
* `sudo apt-get update`
* `sudo apt-cache policy gcc-arm-none-eabi`
* `sudo apt-get install gcc-arm-none-eabi=4-8-2014q2-0trusty10` The latter packages contains GCC, GDB, binutils, newlib and newlib-nano libraries.
* `sudo apt-get install build-essential git openocd symlinks python3 octave`
* `git clone https://github.com/istarc/stm32.git`
* `cd ~/stm32`
* `git submodule update --init` This command is required to initialize submodules.

Build:
* `make clean`
* `make clean && make release-memopt # Use all available optimizations`
* `make clean && make release-memopt OPT='O1 O2 O3 O4 O4 O5 O6 O7 O8' # Manually select optimizations`

Identify space-wasting code:
* `make clean && make release-memopt-blame`

Deploy to target via OpenOCD:
* `make deploy`

Benchmark:
* `python3 benchmark-singleopt.py # Isolated optimizations`
* `python3 benchmark-multiopt.py  # Optimization combinations`
* `octave benchmark.m # Generate results.png`

More info:
* [Optimizations](http://istarc.wordpress.com/2014/07/26/stm32f4-optimizations/)
