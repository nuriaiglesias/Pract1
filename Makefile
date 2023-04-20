#TOOLCHAIN=~/toolchain/gcc-arm-none-eabi-4_9-2014q4/bin
#PREFIX=$(TOOLCHAIN)/arm-none-eabi-
PREFIX=arm-none-eabi-

ARCHFLAGS=-mthumb -mcpu=cortex-m0plus
COMMONFLAGS=-g3 -Og -Wall -Werror $(ARCHFLAGS)

CFLAGS=-I./includes -I./drivers $(COMMONFLAGS)
LDFLAGS=$(COMMONFLAGS) --specs=nano.specs -Wl,--gc-sections,-Map,$(TARGET).map,-Tlink.ld
LDLIBS=

CC=$(PREFIX)gcc
LD=$(PREFIX)gcc
OBJCOPY=$(PREFIX)objcopy
SIZE=$(PREFIX)size
RM=rm -f

TARGET=main

SRC=$(wildcard *.c drivers/*.c)
OBJ=$(patsubst %.c, %.o, $(SRC))
ASM = asm.o

all: build size
build: $(TARGET).elf $(TARGET).srec $(TARGET).bin

clean:
	$(RM) $(TARGET).srec $(TARGET).elf $(TARGET).bin $(TARGET).map $(OBJ) $(ASM)

$(TARGET).elf: $(OBJ) $(ASM)
	$(CC) $(LDFLAGS) $(OBJ) $(ASM) $(LDLIBS) -o $@

$(OBJ): %.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(ASM): %.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET).srec: $(TARGET).elf
	$(OBJCOPY) -O srec $< $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

size:
	$(SIZE) $(TARGET).elf

flash: all
	openocd -f openocd.cfg -c "program $(TARGET).elf verify reset exit"
