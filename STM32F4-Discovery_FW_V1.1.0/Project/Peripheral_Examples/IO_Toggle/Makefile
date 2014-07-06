# GNU ARM Embedded Toolchain
CC=arm-none-eabi-gcc
LD=arm-none-eabi-ld
AR=arm-none-eabi-ar
AS=arm-none-eabi-as
CP=arm-none-eabi-objcopy
OD=arm-none-eabi-objdump

# Build Parameters: MCU Flags, Definitions, Includes, 
#                   Compile Flags, Linker Script, Linker Flags
MCFLAGS=-mcpu=cortex-m4 -mthumb -mlittle-endian \
-mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork
DEFS=-DUSE_STDPERIPH_DRIVER -DSTM32F4XX
INCLUDES=-I. \
-I../../../Libraries/CMSIS/ST/STM32F4xx/Include \
-I../../../Utilities/STM32F4-Discovery \
-I../../../Libraries/CMSIS/Include \
-I../../../Libraries/STM32F4xx_StdPeriph_Driver/inc
CFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -g
LDSCRIPT = TrueSTUDIO/IO_Toggle/stm32_flash.ld
LDFLAGS=-T $(LDSCRIPT) --specs=nosys.specs $(MCFLAGS)

# Inputs: C Sources, Assembler Sources
SOURCES=main.c stm32f4xx_it.c system_stm32f4xx.c \
../../../Utilities/STM32F4-Discovery/stm32f4_discovery.c \
../../../Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_syscfg.c \
../../../Libraries/STM32F4xx_StdPeriph_Driver/src/misc.c \
../../../Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_gpio.c \
../../../Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_rcc.c \
../../../Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_exti.c 
ASMSOURCES=../../../Libraries/CMSIS/ST/STM32F4xx/Source/Templates/gcc_ride7/startup_stm32f4xx.s

# Outputs: Object Files, ELF Executable & 
#          Converted ELF Executable to Intel HEX format
OBJECTS=$(SOURCES:%.c=%.o)
OBJECTS+=$(ASMSOURCES:%.s=%.o)
EXECUTABLE=iotoggle.elf
TARGET=iotoggle.hex

# Build Rules
all: $(TARGET)

$(TARGET): $(EXECUTABLE)
	$(CP) -O ihex $< $@
	@echo "Objcopy from ELF to IHEX complete!\n"

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@
	@echo "Linking complete!\n"

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@
	@echo "Compiled "$<"!\n"

%.o: %.s
	$(CC) $(CFLAGS) $< -o $@
	@echo "Assambled "$<"!\n"

.PHONY: clean

clean:
	rm -f $(OBJECTS) $(EXECUTABLE) $(TARGET)
