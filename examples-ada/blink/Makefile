###
# Toolchain
CC=arm-none-eabi-gcc
LD=arm-none-eabi-ld
AR=arm-none-eabi-ar
AS=arm-none-eabi-as
CP=arm-none-eabi-objcopy
OD=arm-none-eabi-objdump
SIZE=arm-none-eabi-size
GNATMAKE=arm-none-eabi-gnatmake
GNATLINK=arm-none-eabi-gnatlink

###
# Directory Structure
BINDIR=bin
INCDIR=/home/iztok/arm/lib/gcc/arm-none-eabi/4.9.1/adainclude
SRCDIR=src
LIBDIR=/home/iztok/arm/lib/gcc/arm-none-eabi/4.9.1/adalib

###
# Find source file
ADASOURCES=$(shell find -L $(SRCDIR) -name '*.adb')
ASMSOURCES=$(shell find -L $(SRCDIR) -name '*.s')
# Includes
INC=$(shell find -L $(INCDIR) -name '*.ads' -exec dirname {} \; | uniq)
INCLUDES=$(INC:%=-I%)
# Create object list
OBJECTS=$(ADASOURCES:%.adb=%.o)
OBJECTS+=$(ASMSOURCES:%.s=%.o)
# Define output files ELF
BINELF=outp.elf

###
# MCU FLAGS
MCFLAGS=-mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork
# COMPILE FLAGS
ASMFLAGS=-c $(MCFLAGS)
GNATFLAGS=$(MCFLAGS) $(INCLUDES) -gnat2005 -gnatv
# LINKER FLAGS
LDSCRIPT=stm32_flash.ld
LDFLAGS=-T$(LDSCRIPT) $(MCFLAGS) $(INCLUDES) -L$(LIBDIR) -L.

###
# Build Rules
.PHONY: all release release-memopt debug clean

all: release

release: $(BINDIR)/$(BINELF)
	$(GNATLINK) $(LDFLAGS) $(SRCDIR)/blink.adb

$(BINDIR)/$(BINELF): $(OBJECTS)

%.o: %.adb
	$(GNATMAKE) $(GNATFLAGS) $<
	@echo "Compiled "$<"!\n"

%.o: %.s
	$(CC) $(ASMFLAGS) $<
	@echo "Assambled "$<"!\n"

clean:
	rm -rf *.o *.ali

deploy:
ifeq ($(wildcard /opt/openocd/bin/openocd),)
	/usr/bin/openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -c "program bin/"$(BINELF)" verify reset"
else
	/opt/openocd/bin/openocd -f /opt/openocd/share/openocd/scripts/board/stm32f4discovery.cfg -c "program bin/"$(BINELF)" verify reset"
endif

