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
ASOURCES=$(shell find -L $(SRCDIR) -name '*.s')
CSOURCES+=$(shell find -L $(SRCDIR) -name '*.c')
CXXSOURCES+=$(shell find -L $(SRCDIR) -name '*.cpp')
# Find header directories
INC=$(shell find -L . -name '*.h' -exec dirname {} \; | uniq)
INCLUDES=$(INC:%=-I%)
# Create object list
OBJECTS=$(ASOURCES:%.s=%.o)
OBJECTS+=$(CSOURCES:%.c=%.o)
OBJECTS+=$(CXXSOURCES:%.cpp=%.o)
# Define output files ELF & IHEX
LIBDIRNAME=$(notdir $(shell pwd))
LIB=$(LIBDIRNAME:%=lib%.a)

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
# Optimizations
OPT?='O1 O2 O3 O4 O6' # Link time optimization (O5) is disabled by default disabled due to binary code increase

ifneq ($(findstring lib-memopt,$(MAKECMDGOALS)),)

ifneq ($(filter O1,$(OPT)),)
CXXFLAGS+=-fno-exceptions # Uncomment to disable exception handling
endif

ifneq ($(filter O2,$(OPT)),)
CFLAGS+=-Os # Optimize for size https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
CXXFLAGS+=-Os
LDFLAGS+=-Os # Optimize for size https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
endif

ifneq ($(filter O3,$(OPT)),)
CFLAGS+=-ffunction-sections -fdata-sections # Place each function or data item into its own section in the output file
CXXFLAGS+=-ffunction-sections -fdata-sections # -||-
LDFLAGS+=-Wl,-gc-sections # Remove isolated unused sections
endif

ifneq ($(filter O4,$(OPT)),)
CFLAGS+=-fno-builtin # Disable C++ exception handling
CXXFLAGS+=-fno-builtin # Disable C++ exception handling
endif

ifneq ($(filter O5,$(OPT)),)
CFLAGS+=-flto # Enable link time optimization
CXXFLAGS+=-flto # Enable link time optimization
LDFLAGS+=-flto # Enable link time optimization
endif

ifneq ($(filter O6,$(OPT)),)
CXXFLAGS+=-fno-rtti # Disable type introspection
endif

endif

###
# Build Rules
.PHONY: all lib lib-memopt clean

all: lib-memopt

lib-memopt: $(LIBDIR)/$(LIB)

lib: $(LIBDIR)/$(LIB)

$(LIBDIR)/$(LIB): $(OBJECTS)
	$(AR) rcs $@ $(OBJECTS)
	@echo "Library created!\n"

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

