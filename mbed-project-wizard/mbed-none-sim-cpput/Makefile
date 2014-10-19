###
# Purpose: to create a bare-metal project with mbed SDK.

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
ASOURCES+=$(shell find -L $(LIBDIR) -name '*.s')
CSOURCES=$(shell find -L $(SRCDIR) -name '*.c')
CSOURCES+=$(shell find -L $(LIBDIR) -name '*.c')
CXXSOURCES=$(shell find -L $(SRCDIR) -name '*.cpp')
# Filter out mbed IO retarget. We use newlib rdimon IO retarget (via lib) that is 
# suitable for QEMU semihosted simulation
CXXSOURCES+=$(filter-out %retarget.cpp, $(shell find -L $(LIBDIR) -name '*.cpp'))
# Find header directories
INC=$(shell find -L $(INCDIR) -name '*.h' -exec dirname {} \; | uniq)
INC+=$(shell find -L $(LIBDIR) -name '*.h' -exec dirname {} \; | uniq)
INCLUDES=$(INC:%=-I%)
# Find libraries
INCLUDES_LIBS=
LINK_LIBS=-lrdimon
# Create object list
OBJECTS=$(ASOURCES:%.s=%.o)
OBJECTS+=$(CSOURCES:%.c=%.o)
OBJECTS+=$(CXXSOURCES:%.cpp=%.o)
# Define output files ELF & IHEX
BINELF=outp.elf
BINHEX=outp.hex

###
# MCU FLAGS
# QEMU currently supports only cortex-m3 CPU and soft FPU (but not cortex-m4 with hard FPU)
MCFLAGS=-mcpu=cortex-m3 -mthumb -mlittle-endian -mfloat-abi=soft -mthumb-interwork
# COMPILE FLAGS
DEFS=-DTARGET_STM32F407 -D__CORTEX_M4 -D__FPU_PRESENT -DWORDS_STACK_SIZE=200
CFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -std=c99
CXXFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -std=c++11
CXXFLAGS+=-U__STRICT_ANSI__ # Undefine __STRICT_ANSI__ to compile Stream.cpp using c++11. This is a dirty hack!
# LINKER FLAGS
LDFLAGS =$(MCFLAGS) --specs=rdimon.specs $(INCLUDES_LIBS) $(LINK_LIBS)

###
# Build Rules
.PHONY: all release release-memopt debug clean test test-release test-debug test-release-memopt test-release-memopt-blame test-deps test-deploy test-clean

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
release-memopt: CXXFLAGS+=-Os -fno-exceptions -ffunction-sections -fdata-sections -fno-builtin -fno-rtti # -flto
release-memopt: LDFLAGS+=-Os -Wl,-gc-sections #--specs=nano.specs # -flto
release-memopt: release

debug: CFLAGS+=-g
debug: CXXFLAGS+=-g
debug: LDFLAGS+=-g
debug: release

release: $(BINDIR)/$(BINHEX)

$(BINDIR)/$(BINHEX): $(BINDIR)/$(BINELF)
	$(CP) -O ihex $< $@
	@echo "Objcopy from ELF to IHEX complete!\n"

$(BINDIR)/$(BINELF): $(OBJECTS)
	$(CXX) $(OBJECTS) $(LDFLAGS) -o $@
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
	rm -f $(OBJECTS) $(BINDIR)/$(BINELF) $(BINDIR)/$(BINHEX) $(BINDIR)/output.map

test: test-release

test-release:
	$(MAKE) -f Makefile-test release

test-debug:
	$(MAKE) -f Makefile-test debug

test-release-memopt:
	$(MAKE) -f Makefile-test release-memopt

test-release-memopt-blame:
	$(MAKE) -f Makefile-test release-memopt-blame
	
test-deps:
	$(MAKE) -f Makefile-test deps-clean
	$(MAKE) -f Makefile-test deps

test-deploy:
	$(MAKE) -f Makefile-test deploy

test-clean:
	$(MAKE) -f Makefile-test clean

deploy:
	qemu-system-arm -cpu cortex-m3 -machine versatilepb -monitor null -serial null -semihosting -nographic -kernel bin/$(BINELF)
