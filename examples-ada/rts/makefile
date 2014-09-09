# TODO: Use this until gnatmake can build a lib.
BOARD=stm32f4

DEBUG		=	-g
#DEBUG		=	-O2

TARGET		=	arm-none-eabi-
TARGETFLAGS	=	-mcpu=cortex-m4 -mthumb

# Add flags to force the compiler to conform to the standard, see
# S.12.6 of the GNAT Reference Manual.
CONFORMANCE	=	-gnato -gnatE -fstack-check

FLAGS		=	-c -gnat2005 $(TARGETFLAGS) $(DEBUG) -gnatg -gnata \
			$(CONFORMANCE) \
			-gnatyy \
			-ffunction-sections -fdata-sections \
			-nostdinc -nostdlib --RTS=./src/boards/$(BOARD)

#		-I./src/boards/$(BOARD)

LIBNAME		=	libgnat.a

OBJS		=	obj/ada.o \
			obj/a-unccon.o \
			obj/a-uncdea.o \
			obj/gnat.o \
			obj/g-souinf.o \
			obj/interfac.o \
			obj/s-stoele.o \
			obj/s-atacco.o \
			obj/s-maccod.o \
			obj/system.o 
#			obj/last_chance_handler.o
# obj/i-c.o
ALIS		=	$(OBJS:.o=.ali)

all: $(LIBNAME)

$(LIBNAME): $(OBJS) $(ALIS)
	$(TARGET)ar -rcs ./src/boards/$(BOARD)/adalib/$(LIBNAME) $(OBJS)
	cp ./obj/*.ali ./src/boards/$(BOARD)/adalib

obj/ada.o obj/ada.ali: src/common/ada.ads
	$(TARGET)gcc $(FLAGS) -gnatpg src/common/ada.ads -o obj/ada.o

obj/a-unccon.o obj/a-unccon.ali: src/common/a-unccon.ads
	$(TARGET)gcc $(FLAGS) -gnatpg src/common/a-unccon.ads -o obj/a-unccon.o

obj/a-uncdea.o obj/a-uncdea.ali: src/common/a-uncdea.ads
	$(TARGET)gcc $(FLAGS) -gnatpg src/common/a-uncdea.ads -o obj/a-uncdea.o

obj/gnat.o obj/gnat.ali: src/common/gnat.ads
	$(TARGET)gcc $(FLAGS) src/common/gnat.ads -o obj/gnat.o

obj/g-souinf.o obj/g-souinf.ali: src/common/g-souinf.ads
	$(TARGET)gcc $(FLAGS) src/common/g-souinf.ads -o obj/g-souinf.o

obj/interfac.o obj/interfac.ali: src/common/interfac.ads
	$(TARGET)gcc $(FLAGS) -gnatpg src/common/interfac.ads -o obj/interfac.o

# obj/i-c.o obj/i-c.ali: src/common/i-c.ads src/common/i-c.adb
# 	$(TARGET)gcc $(FLAGS) src/common/i-c.adb -o obj/i-c.o

obj/s-stoele.o obj/s-stoele.ali: src/common/s-stoele.ads src/common/s-stoele.adb
	$(TARGET)gcc $(FLAGS) -gnatpg src/common/s-stoele.adb -o obj/s-stoele.o

obj/s-atacco.o obj/s-atacco.ali: src/common/s-atacco.ads src/common/s-atacco.adb
	$(TARGET)gcc $(FLAGS) -gnatpg src/common/s-atacco.adb -o obj/s-atacco.o

obj/s-maccod.o obj/s-maccod.ali: src/common/s-maccod.ads
	$(TARGET)gcc $(FLAGS) -gnatpg src/common/s-maccod.ads -o obj/s-maccod.o

obj/system.o obj/system.ali: src/boards/$(BOARD)/system.ads
	$(TARGET)gcc $(FLAGS) -gnatpg src/boards/$(BOARD)/system.ads -o obj/system.o


#obj/last_chance_handler.o obj/last_chance_handler.ali: src/common/last_chance_handler.adb src/common/last_chance_handler.ads
#	$(TARGET)gcc $(FLAGS) src/common/last_chance_handler.adb -o obj/last_chance_handler.o

.PHONY: clean

clean:
	-rm obj/*
	-rm ./boards/$(BOARD)/adainclude/*
	-rm ./boards/$(BOARD)/adainclude/.symlinks
	-rm ./boards/$(BOARD)/adalib/*
