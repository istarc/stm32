The [examples](https://github.com/istarc/stm32/tree/master/examples) folder contains several STM32F4-Discovery projects. Current test build status is [![Build Status](https://travis-ci.org/istarc/stm32.svg?branch=master)](https://travis-ci.org/istarc/stm32).

You may use these projects as a template or create a new project using a [project wizard](http://istarc.wordpress.com/2014/08/04/stm32f4-behold-the-project-wizard/).

# 1. Existing Projects

  - Assembly: [Mixing C & Assembly for Fun and Profit](http://istarc.wordpress.com/2014/08/07/stay-tuned/)
  - FreeRTOS: [Deploy FreeRTOS Embedded OS under 10 seconds!](http://istarc.wordpress.com/2014/08/07/stay-tuned/)
  - FreeRTOS.mbed: [mbed Your Code: Zero Switching Costs When Changing ARM Platforms](http://istarc.wordpress.com/2014/07/28/stm32f4-mbed-your-code/)
  - FreeRTOS.mbedlib: [Behold the Project Wizard!](http://istarc.wordpress.com/2014/08/04/stm32f4-behold-the-project-wizard/)
  - FreeRTOS.mbed-OSAL: [CMSIS-RTOS API: Zero Switching Cost When Changing OS](http://istarc.wordpress.com/2014/08/07/stay-tuned/)
  - FreeRTOS.mbed+OSAL: [CMSIS-RTOS API: Zero Switching Cost When Changing OS](http://istarc.wordpress.com/2014/08/07/stay-tuned/)
  - FreeRTOS.mbed-trace: [Code Optimization via Dynamic App Profiling](http://istarc.wordpress.com/2014/08/07/stay-tuned/)
  - mbedRTOS.mbed: [mbed Your Code: Zero Switching Costs When Changing ARM Platforms](http://istarc.wordpress.com/2014/07/28/stm32f4-mbed-your-code/)
  - mbedRTOS.mbedlib: [Behold the Project Wizard!](http://istarc.wordpress.com/2014/08/04/stm32f4-behold-the-project-wizard/)
  - OOP: [Object-oriented Programming with Embedded Systems (C++ /w STL)](http://istarc.wordpress.com/2014/07/18/stm32f4-object-oriented-programming-c-with-embedded-systems/)
  - OOP.mbed: [Behold the Project Wizard!](http://istarc.wordpress.com/2014/08/04/stm32f4-behold-the-project-wizard/)
  - OOP.mbedlib: [Behold the Project Wizard!](http://istarc.wordpress.com/2014/08/04/stm32f4-behold-the-project-wizard/)
  - Optimization: [Code Optimization](http://istarc.wordpress.com/2014/07/26/stm32f4-code-optimizations/)
  - Template: [Template Project with Generic Makefile](http://istarc.wordpress.com/2014/07/01/stm32f4/) & [In-circuit Debugging](http://istarc.wordpress.com/2014/07/06/stm32f4-in-circuit-debugging/).
  - Template.mbed: [mbed Your Code: Zero Switching Costs When Changing ARM Platforms](http://istarc.wordpress.com/2014/07/28/stm32f4-mbed-your-code/)
  - Template.mbedlib: [Behold the Project Wizard!](http://istarc.wordpress.com/2014/08/04/stm32f4-behold-the-project-wizard/)

# 2. Setup the Build and Test environment

    cd ~/stm32
    ./setup-env.sh

# 3. Build
# 3.1 Build All Existing Projects

    cd ~/stm32/examples
    make clean
    make -j4

# 3.2 Build and Deploy a Project

    cd ~/stm32/examples/Template.mbedlib
    make clean
    make -j4
    # Other build options:
    # make -j4 release
    # make -j4 release-memopt
    # make -j4 release-memopt-blame
    # make -j4 debug
    # make -j4 libs
    sudo make deploy

# 4 Create a New Project
# 4.1 Create a New Project via [Project Wizard](http://istarc.wordpress.com/2014/08/04/stm32f4-behold-the-project-wizard/)

    # Create a new project directory
    mkdir -p ~/stm32/examples/test
    cd ~/stm32/examples/test
    # Create a new project template via project wizard
    ../../mbed-project-wizard/gen-stm32f407-GCC-project.sh 
    # Usage:  {mbed-none|mbed-none-lib|
    #          mbed-freertos|mbed-freertos-lib|
    #          mbed-mbedrtos|mbed-mbedrtos-lib|
    #          none-safertos} {|copy}
    ../../mbed-project-wizard/gen-stm32f407-GCC-project.sh mbed-none
    # Edit source files
    vim src/main.cpp
    # Build and Deploy
    make clean
    make -j4
    sudo make deploy

# 4.2 Copy an Existing Project

    # Create a new project directory
    mkdir -p ~/stm32/examples/test
    cd ~/stm32/examples/test
    # Copy recursively and by *following symbolic links*
    cp -L -r ~/stm32/examples/Template.mbedlib/* ~/stm32/examples/test
    # Edit source files
    vim src/main.cpp
    # Build and Deploy
    make clean
    make -j4
    sudo make deploy

# 5. Automated Project Testing

See [Build & Test Automation for Embedded Systems](http://istarc.wordpress.com/2014/08/07/stay-tuned/).

