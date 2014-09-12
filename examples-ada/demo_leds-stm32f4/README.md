# 1. Deploy GNAT for ARM
# 1.1 Download

- [Read this](http://www.adacore.com/press/gnat-gpl-for-bare-board-arm/)
- [Download GNAT GPL Ada gpl-2014](http://libre.adacore.com/download/configurations), select ARM ELF platform (2014 edition).

# 1.2 Install

    unzip AdaCore-Download-2014-09-12_1029.zip
    cd arm-elf-linux/adagpl-2014/gnatgpl
    tar xzf gnat-gpl-2014-arm-elf-linux-bin.tar.gz
    mv gnat-gpl-2014-arm-elf-linux-bin ~/gnat
    cd ~/gnat
    sudo ./doinstall #Enter, Enter, Y (confirm), Y (confirm)
    
# 2. Create a New Project

    git clone https://github.com/istarc/stm32.git
    git checkout ada
    cd ~/stm32/examples-ada
    cp -r /usr/gnat/share/examples/gnat-cross/demo_leds-stm32f4 .
    cd demo_leds-stm32f4

# 3. Build the New Project
# 3.1 Apply Hotfix

    vim demo_leds.gpr
    ... line 15 ...
       ("-g",
    --    "--RTS=/GNAT/2014/lib/gnat/arm-eabi/ravenscar-sfp-stm32f4");
    --    "--RTS=/GNATPRO/7.2.1/lib/gnat/arm-eabi/ravenscar-sfp-stm32f4");
          "--RTS=/usr/gnat/lib/gnat/arm-eabi/ravenscar-sfp-stm32f4");
    end Builder;
    ... line 19 ...

# 3.2 Build the Project

    export PATH=/usr/gnat/bin:$PATH
    gprbuild --target=arm-eabi -P demo_leds.gpr

# 3.3 Deploy the Project

    /opt/openocd/bin/openocd -f /opt/openocd/share/openocd/scripts/board/stm32f4discovery.cfg \
                             -c "program obj/demo" verify reset"

# 3.4 Clean the Project

   gprclean --target=arm-eabi -P demo_leds.gpr
