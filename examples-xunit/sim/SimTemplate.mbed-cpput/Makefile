###
# Purpose: to create a bare-metal with mbed SDK and cpputest suitable for QEMU simulation

###
# GNU ARM Embedded Toolchain
CC=arm-none-eabi-gcc
CXX=arm-none-eabi-g++
LD=arm-none-eabi-ld
AR=arm-none-eabi-ar
AS=arm-none-eabi-as
CP=arm-none-eabi-objcopy
OD=arm-none-eabi-objdump
NM=arm-none-eabi-nm
SIZE=arm-none-eabi-size
A2L=arm-none-eabi-addr2line

###
# Directory Structure
BINDIR=bin
INCDIR=inc
SRCDIR=src
LIBDIR=lib

###
# Find source files
ASOURCES=$(shell find -L $(SRCDIR) -name '*.s')
# Exclude startup_stm32f407xx.s (if exists). QEMU simulation uses different startup routine.
ASOURCES+=$(shell find -L $(LIBDIR) -name '*.s' -not -name 'startup_stm32f407xx.s')
CSOURCES=$(shell find -L $(SRCDIR) -name '*.c')
CSOURCES+=$(shell find -L $(LIBDIR) -name '*.c')
CXXSOURCES=$(shell find -L $(SRCDIR) -name '*.cpp')
# Filter retarget.cpp from mbed library, because it is already defined in librdimon,
# which is used to provide semihosted environment.
CXXSOURCES+=$(filter-out %retarget.cpp, $(shell find -L $(LIBDIR) -name '*.cpp'))
# Find header directories
INC=$(shell find -L $(INCDIR) -name '*.h' -exec dirname {} \; | uniq)
INC+=$(shell find -L $(LIBDIR) -name '*.h' -exec dirname {} \; | uniq)
INCLUDES=$(INC:%=-I%)
# Find libraries
LIBFILES=$(shell find $(LIBDIR) -type f -name '*.a')
INCLUDES_LIBS=$(patsubst %,-L%, $(dir $(LIBFILES)))
LINK_LIBS=$(patsubst lib%, -l%, $(basename $(notdir $(LIBFILES))))
LINK_LIBS+=-lrdimon
# Create object list
AOBJECTS=$(ASOURCES:%.s=%.o)
COBJECTS=$(CSOURCES:%.c=%.o)
CXXOBJECTS=$(CXXSOURCES:%.cpp=%.o)
# Define output files ELF & IHEX
BINELF=outp.elf
BINHEX=outp.hex

###
# MCU FLAGS
# QEMU currently supports only cortex-m3 CPU and soft FPU (but not cortex-m4 with hard FPU)
MCFLAGS=-mcpu=cortex-m3 -mthumb -mlittle-endian -mfloat-abi=soft -mthumb-interwork
# COMPILE FLAGS
DEFS=-DTARGET_STM32F407 -D__CORTEX_M4 -D__FPU_PRESENT
CFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -std=c99
CXXFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -std=c++11
# A dirty hack to build Stream.cpp according to C+11.
CXXFLAGS+=-U__STRICT_ANSI__
# LINKER FLAGS
LDFLAGS=$(MCFLAGS) $(INCLUDES_LIBS) $(LINK_LIBS) --specs=rdimon.specs --specs=nosys.specs

###
# Build Rules
.PHONY: all release release-memopt debug clean deploy test test-deps check check-coverage test-clean

all: release-memopt

release-memopt-blame: CFLAGS+=-g
release-memopt-blame: CXXFLAGS+=-g
release-memopt-blame: LDFLAGS+=-g -Wl,-Map=$(BINDIR)/output.map
release-memopt-blame: release-memopt
release-memopt-blame:
	@echo "Top 10 space consuming symbols from the object code ...\n"
	$(NM) -A -l -C -td --reverse-sort --size-sort $(BINDIR)/$(BINELF) | head -n10 | cat -n # Output legend: man nm
	@echo "\n... and corresponging source files to blame.\n"
	$(NM) --reverse-sort --size-sort -S -tx $(BINDIR)/$(BINELF) | head -10 | cut -d':' -f2 | cut -d' ' -f1 | $(A2L) -e $(BINDIR)/$(BINELF) | cat -n # Output legend: man addr2line

release-memopt: DEFS+=-DCUSTOM_NEW -DNO_EXCEPTIONS
release-memopt: CFLAGS+=-Os -ffunction-sections -fdata-sections -fno-builtin # -flto
release-memopt: CXXFLAGS+=-Os -ffunction-sections -fdata-sections -fno-builtin #-fno-exceptions -fno-rtti # -flto
release-memopt: LDFLAGS+=-Os -Wl,-gc-sections --specs=nano.specs # -flto
release-memopt: release

debug: CFLAGS+=-g
debug: CXXFLAGS+=-g
debug: LDFLAGS+=-g
debug: release

release: $(BINDIR)/$(BINHEX)

$(BINDIR)/$(BINHEX): $(BINDIR)/$(BINELF)
	$(CP) -O ihex $< $@
	@echo "Objcopy from ELF to IHEX complete!\n"

$(BINDIR)/$(BINELF): $(AOBJECTS) $(COBJECTS) $(CXXOBJECTS)
	$(CXX) $(AOBJECTS) $(COBJECTS) $(CXXOBJECTS) $(LDFLAGS) -o $@
	@echo "Linking complete!\n"
	$(SIZE) $(BINDIR)/$(BINELF)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
	@echo "Compiled "$<"!\n"

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@
	@echo "Compiled "$<"!\n"

%.o: %.s
	$(CC) $(CFLAGS) $< -o $@
	@echo "Assambled "$<"!\n"

clean:
	rm -f $(AOBJECTS) $(COBJECTS) $(CXXOBJECTS) $(BINDIR)/$(BINELF) $(BINDIR)/$(BINHEX) $(BINDIR)/output.map

test:
	$(MAKE) -f Makefile-test test

test-deps:
	$(MAKE) -f Makefile-test test-deps

check:
	$(MAKE) -f Makefile-test check

check-coverage:
	$(MAKE) -f Makefile-test check-coverage

test-clean:
	$(MAKE) -f Makefile-test test-clean

deploy:
	qemu-system-arm -cpu cortex-m3 -machine versatilepb -monitor null -serial null -semihosting -nographic -kernel bin/$(BINELF)
