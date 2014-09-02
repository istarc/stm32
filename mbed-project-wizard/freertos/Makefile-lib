###
# Purpose: to build FreeRTOS library

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
LIBDIR=.
INCDIR=.
SRCDIR=.

###
# Find source files
ASOURCES=$(shell find -L . -name '*.s')
CSOURCES=$(shell find -L . -name '*.c')
CXXSOURCES=$(shell find -L . -name '*.cpp')
# Find header directories
INC=$(shell find -L . -name '*.h' -exec dirname {} \; | uniq)
INC+=$(shell find -L ../mbed -name '*.h' -exec dirname {} \; | uniq)
INCLUDES=$(INC:%=-I%)
# Find libraries
INCLUDES_LIBS=
LINK_LIBS=
# Create object list
OBJECTS=$(ASOURCES:%.s=%.o)
OBJECTS+=$(CSOURCES:%.c=%.o)
OBJECTS+=$(CXXSOURCES:%.cpp=%.o)
# Define output files ELF & IHEX
DIRNAME=$(notdir $(shell pwd))
LIB=$(DIRNAME:%=lib%.a)

###
# MCU FLAGS
MCFLAGS=-mcpu=cortex-m4 -mthumb -mlittle-endian \
-mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork
# COMPILE FLAGS
DEFS=
CFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -std=c99
CXXFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -std=c++11 
CXXFLAGS+=-U__STRICT_ANSI__ # Undefine __STRICT_ANSI__ to compile Stream.cpp using c++11. This is a dirty hack!

###
# Build Rules
.PHONY: all release release-memopt debug clean 

all: release-memopt

release-memopt: CFLAGS+=-Os -ffunction-sections -fdata-sections -fno-builtin # -flto
release-memopt: CXXFLAGS+=-Os -fno-exceptions -ffunction-sections -fdata-sections -fno-builtin -fno-rtti # -flto
release-memopt: LDFLAGS+=-Os -Wl,-gc-sections #--specs=nano.specs # -flto
release-memopt: release

debug: CFLAGS+=-g
debug: CXXFLAGS+=-g
debug: LDFLAGS+=-g
debug: release

release: $(LIBDIR)/$(LIB)

$(LIBDIR)/$(LIB): $(OBJECTS)
	$(AR) rcs $@ $(OBJECTS)
	@echo "Library Created!\n"

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
	rm -f $(OBJECTS) $(LIBDIR)/$(LIB)

