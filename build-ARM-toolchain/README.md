This folder contains a script that builds GNU ARM cross-toolchain from scratch.

# 1. Setup the environment

Setup the complete environment (recommended).

    cd ~/stm32
    ./setup-env.sh

Or directly build the GNU ARM cross-toolchain.

    cd ~/stm32/build-ARM-toolchain
    bash build.sh

# 2. Test the Toolchain

    export PATH=~/arm/bin:$PATH
    cd ~stm32/examples/Template.mbed
    make clean
    make -j4
    sudo make deploy

# 3. More Info

See [Build Your Own GNU ARM Cross-Toolchain From Scratch](http://istarc.wordpress.com/2014/07/21/stm32f4-build-your-toolchain-from-scratch/).
