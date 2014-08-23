This folder contains a script that builds GNU ARM cross-toolchain from scratch.

# 1. Setup the Build and Test environment

    cd ~/stm32
    ./setup-env.sh

# 2. Install Software Dependencies:
 
    sudo apt-get purge binutils-arm-none-eabi gcc-arm-none-eabi libnewlib-arm-none-eabi gdb-arm-none-eabi # You may remove offical toolchain to avoid potential conflicts
    sudo apt-get install build-essential git openocd
    sudo apt-get install libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev # Required to build GCC

# 3. Build the Toolchain

    bash build.sh

# 4. Test the Toolchain

    export PATH=~/arm/bin:$PATH
    cd ~stm32/examples/Template.mbed
    make clean
    make -j4
    # Other build options:
    # make -j4 release
    # make -j4 release-memopt
    # make -j4 release-memopt-blame
    # make -j4 debug
    # make -j4 libs
    sudo make deploy

# 5. More Info

See [Build Your Own GNU ARM Cross-Toolchain From Scratch](http://istarc.wordpress.com/2014/07/21/stm32f4-build-your-toolchain-from-scratch/).
