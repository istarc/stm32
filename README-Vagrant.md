Build and Test Environment based on Ubuntu 14.04 LTS for the STM32F4-Discovery board.

# 1. File Organization

- [examples](https://github.com/istarc/stm32/tree/master/examples) have the following status: [![Build Status](https://travis-ci.org/istarc/stm32.svg?branch=master)](https://travis-ci.org/istarc/stm32)
- [build-ARM-toolchain](http://istarc.wordpress.com/2014/07/21/stm32f4-build-your-toolchain-from-scratch/)
- [freertos](https://github.com/istarc/freertos) library
- [mbed](http://mbed.org/) library
- [mbed-project-wizard](http://istarc.wordpress.com/2014/08/04/stm32f4-behold-the-project-wizard/)
- [STM32F4-Discovery_FW_V1.1.0 library](http://www.st.com/web/catalog/tools/FM116/SC959/SS1532/PF252419) library
- [test]()

# 2. How to Setup the Environment Via Vagrant

## 2.1 Prerequisites

    vagrant --version
    Vagrant 1.6.3 # Issues with version < 1.5.0
    # Install Vagrant by following instructions at https://www.vagrantup.com/downloads.html

## 2.2 Install software dependencies

    # Install VirtualBox (https://www.virtualbox.org/)
    sudo apt-get install build-essential virtualbox virtualbox-dkms virtualbox-guest-dkms \
                         virtualbox-guest-utils virtualbox-guest-x11 virtualbox-qt
    # Download VirtualBox extension pack (https://www.virtualbox.org/wiki/Downloads)
    wget http://download.virtualbox.org/virtualbox/4.3.14/Oracle_VM_VirtualBox_Extension_Pack-4.3.14-95030.vbox-extpack
    # Install the extension pack
    VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-4.3.14-95030.vbox-extpack

An alternative is to build the image from scratch. See the [Vagrantfile](https://github.com/istarc/stm32/blob/master/Vagrantfile) for details.

# 3. Basic usage
## 3.1 Run the VirtualBox Image

    cd ~
    vagrant init istarc/stm32
    vagrant up
    # Manually enable ST-Link: Devices -> USB Devices -> STMicroelectronics STM32 STLink

## 3.2 Build Existing Projects:

    # Switch to VirtualBox Container
    cd ~/stm32/
    make clean
    make -j4

## 3.3 Deploy Existing Project:

    # Switch to VirtualBox Container
    cd ~/stm32/examples/Template.mbed
    make clean
    make -j4
    # Manually enable ST-Link: Devices -> USB Devices -> STMicroelectronics STM32 STLink
    sudo make deploy

## 3.4 Test Build Existing Projects via Buildbot:

    # Switch to VirtualBox Container
    cd ~/stm32bb
    buildbot start master
    buildslave start slave
    firefox http://localhost:8010
    # Login U: admin P: admin (Upper right corner)
    Click: Waterfall -> test-build-local -> [Use default options] -> Force Build
    # Test builds examples in /home/admin/stm32/examples
    Click: Waterfall -> test-build-repo -> [Use default options] -> Force Build
    # Test builds examples from the https://github.com/istarc/stm32.git repository
    Check: Waterfall -> F5 to Refresh

## 3.5 More info:
  - http://istarc.wordpress.com
  - https://github.com/istarc/stm32
  - https://vagrantcloud.com/istarc/stm32

