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
BINELF=outp.elf
BINHEX=outp.hex

###
# MCU FLAGS
MCFLAGS=-mcpu=cortex-m4 -mthumb -mlittle-endian \
-mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork
# COMPILE FLAGS
DEFS=-DUSE_STDPERIPH_DRIVER -DSTM32F4XX
#DEFS+=-DLIST # Uncomment to use std::list instead of std::deque container
CFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES)
CXXFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -std=c++11
# LINKER FLAGS
LDSCRIPT= stm32_flash.ld
LDFLAGS =-T $(LDSCRIPT) $(MCFLAGS) --specs=nosys.specs

###
# Build Rules
.PHONY: all release release-memopt debug clean

all: release-memopt

release: $(BINDIR)/$(BINHEX)

##
# Optimizations
release-memopt: CXXFLAGS+=$(CFLAGS) # DON'T TOUCH
release-memopt: release # DON'T TOUCH
# O1 (new and delete replacement with malloc and free)
release-memopt: DEFS+=-DCUSTOM_NEW # Uncomment to use malloc instead of new, and free instead of delete
# O2 (Disable C++ exception handling)
release-memopt: CXXFLAGS+=-fno-exceptions # Uncomment to disable exception handling
release-memopt: DEFS+=-DNO_EXCEPTIONS # The source code has to comply with this rule
# O3 (Size optimization)
release-memopt: CFLAGS+=-Os # Optimize for size https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
release-memopt: LDFLAGS+=-Os # Optimize for size https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
# O4 (Link time dead code elimination) -- WARNING -- May break things if linked to 3rd party static libraries that use magic sections (http://elinux.org/images/2/2d/ELC2010-gc-sections_Denys_Vlasenko.pdf)
release-memopt: CFLAGS+=-ffunction-sections -fdata-sections # Place each function or data item into its own section in the output file
release-memopt: LDFLAGS+=-Wl,-gc-sections # Remove isolated unused sections
# O5 (Disable GCC built-in functions)
release-memopt: CFLAGS+=-fno-builtin
# O6 (Link time optimization)
release-memopt: CFLAGS+=-flto # Enable link time optimization
release-memopt: LDFLAGS+=-flto # Enable link time optimisation
# O7 (Disable type introspection)
release-memopt: CXXFLAGS+=-fno-rtti # Disable generation of information about every class with virtual functions
# O8 (Size optimized newlib)
release-memopt: LDFLAGS+=--specs=nano.specs # Use size optimized newlib

##
# The list of top 10 space consuming symbols from the object and
# corresponging source files to blame.
blame: CFLAGS+=-g
blame: CXXFLAGS+=-g
blame: LDFLAGS+=-g -Wl,-Map=$(BINDIR)/output.map
blame: release-memopt
blame:
	@echo "Top 10 space consuming symbols from the object code ...\n"
	$(NM) -A -l -C -td --reverse-sort --size-sort $(BINDIR)/$(BINELF) | head -n10 | cat -n # Output legend: man nm
	@echo "\n... and corresponging source files to blame.\n"
	$(NM) --reverse-sort --size-sort -S -tx $(BINDIR)/$(BINELF) | head -10 | cut -d':' -f2 | cut -d' ' -f1 | $(A2L) -e $(BINDIR)/$(BINELF) | cat -n # Output legend: man addr2line

debug: CFLAGS+=-g
debug: CXXFLAGS+=-g
debug: LDFLAGS+=-g
debug: release

$(BINDIR)/$(BINHEX): $(BINDIR)/$(BINELF)
	$(CP) -O ihex $< $@
	@echo "Objcopy from ELF to IHEX complete!\n"

$(BINDIR)/$(BINELF): $(OBJECTS)
	$(CXX) $(LDFLAGS) $(OBJECTS) -o $@
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

deploy:
ifeq ($(wildcard /opt/openocd/bin/openocd),)
	/usr/bin/openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -c "program bin/"$(BINELF)" verify reset"
else
	/opt/openocd/bin/openocd -f /opt/openocd/share/openocd/scripts/board/stm32f4discovery.cfg -c "program bin/"$(BINELF)" verify reset"
endif
