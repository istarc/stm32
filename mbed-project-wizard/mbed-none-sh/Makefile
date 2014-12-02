###
# Purpose: to create a bare-metal project with mbed SDK in ARM semihosting environment.

#########################
# Configuration Options #
#########################

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
GCOV=arm-none-eabi-gcov
GPROF=arm-none-eabi-gprof

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
# Filter retarget.cpp from mbed library, because it is already defined in librdimon,
# which is used to provide semihosted enviornment.
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
MCFLAGS=-mcpu=cortex-m4 -mthumb -mlittle-endian \
-mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork
# COMPILE FLAGS
DEFS=-DTARGET_STM32F407 -D__CORTEX_M4 -D__FPU_PRESENT
CFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -std=c99
CXXFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -std=c++11
# A dirty hack to build Stream.cpp according to C+11.
CXXFLAGS+=-U__STRICT_ANSI__
# LINKER FLAGS
LDSCRIPT=stm32f407.ld
LDFLAGS=-T $(LDSCRIPT) $(MCFLAGS) $(INCLUDES_LIBS) $(LINK_LIBS) --specs=rdimon.specs --specs=nosys.specs

###############
# Build Rules #
###############

##
# Build flavors
.PHONY: all
all: release-memopt

.PHONY: release-memopt
release-memopt: DEFS+=-DCUSTOM_NEW -DNO_EXCEPTIONS
release-memopt: CFLAGS+=-Os -ffunction-sections -fdata-sections -fno-builtin # -flto
release-memopt: CXXFLAGS+=-Os -ffunction-sections -fdata-sections -fno-builtin #-fno-exceptions -fno-rtti # -flto
release-memopt: LDFLAGS+=-Os -Wl,-gc-sections --specs=nano.specs # -flto
release-memopt: release

.PHONY: debug
debug: CFLAGS+=-g
debug: CXXFLAGS+=-g
debug: LDFLAGS+=-g
debug: release

.PHONY: release
release: $(BINDIR)/$(BINHEX)

##
# General build rules
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

##
# Clean rules
.PHONY: clean
clean:
	rm -f $(AOBJECTS) $(COBJECTS) $(CXXOBJECTS) $(BINDIR)/$(BINELF) $(BINDIR)/$(BINHEX) $(BINDIR)/output.map

###########################
# Deploy & Profile Rules  #
###########################

##
# Deploy the binary
# Usage: make clean && make && make deploy
.PHONY: deploy
deploy:
ifeq ($(wildcard /opt/openocd/bin/openocd),)
	/usr/bin/openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -f deploy.cfg
else
	/opt/openocd/bin/openocd -f /opt/openocd/share/openocd/scripts/board/stm32f4discovery.cfg -f deploy.cfg
endif

##
# Profile code size
# Usage: make clean && make profile-code-size
.PHONY: profile-code-size
profile-code-size: CFLAGS+=-g
profile-code-size: CXXFLAGS+=-g
profile-code-size: LDFLAGS+=-g -Wl,-Map=$(BINDIR)/output.map
profile-code-size: release-memopt
profile-code-size:
	@echo "Top 10 space consuming symbols from the object code ...\n"
	$(NM) -A -l -C -td --reverse-sort --size-sort $(BINDIR)/$(BINELF) | head -n10 | cat -n # Output legend: man nm
	@echo "\n... and corresponging source files to blame.\n"
	$(NM) --reverse-sort --size-sort -S -tx $(BINDIR)/$(BINELF) | head -10 | cut -d':' -f2 | cut -d' ' -f1 | $(A2L) -e $(BINDIR)/$(BINELF) | cat -n # Output legend: man addr2line

##
# Profile execution time
# Usage: make clean && make && make profile-exec-time
.PHONY: profile-exec-time
profile-exec-time:
	test -e $(BINDIR)/$(BINELF)
	find . -type f -name '*.gmon' -exec rm -f {} \;
ifeq ($(wildcard /opt/openocd/bin/openocd),)
	/usr/bin/openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -f gprof.cfg
else
	/opt/openocd/bin/openocd -f /opt/openocd/share/openocd/scripts/board/stm32f4discovery.cfg -f gprof.cfg
endif
	$(GPROF) $(BINDIR)/$(BINELF) gmon.out

################################
# Test Script Rule Invocation  #
################################

.PHONY: test-deps
test-deps:
	$(MAKE) -f Makefile-test test-deps

.PHONY: test
test:
	$(MAKE) -f Makefile-test test

.PHONY: check
check:
	$(MAKE) -f Makefile-test check

.PHONY: check-exec-coverage
check-exec-coverage:
	$(MAKE) -f Makefile-test check-exec-coverage

.PHONY: check-code-size
check-code-size:
	$(MAKE) -f Makefile-test check-code-size

.PHONY: check-exec-time
check-exec-time:
	$(MAKE) -f Makefile-test check-exec-time

.PHONY: test-clean
test-clean:
	$(MAKE) -f Makefile-test test-clean


