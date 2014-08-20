###
# Build all projects

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
PROJECTS=$(shell find $(LIBDIR) -mindepth 1 -maxdepth 1 -type d)

###
# Build Rules
.PHONY: all $(PROJECTS)

all: $(PROJECTS) 

$(PROJECTS):
	$(MAKE) -C $@ clean
	$(MAKE) -C $@

