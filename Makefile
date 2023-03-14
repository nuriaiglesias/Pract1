#TOOLCHAIN=~/toolchain/gcc-arm-none-eabi-4_9-2014q4/bin
#PREFIX=$(TOOLCHAIN)/arm-none-eabi-
PREFIX=arm-none-eabi-

ARCHFLAGS=-mthumb -mcpu=cortex-m0plus
COMMONFLAGS=-g3 -Og -Wall -Werror $(ARCHFLAGS)

CFLAGS=-I./drivers $(COMMONFLAGS) -D CPU_MKL46Z256VLL4
LDFLAGS=$(COMMONFLAGS) --specs=nano.specs -Wl,--gc-sections,-Tlink.ld
LDLIBS=

CC=$(PREFIX)gcc
LD=$(PREFIX)gcc
OBJCOPY=$(PREFIX)objcopy
SIZE=$(PREFIX)size
RM=rm -f

TARGET_HELLO=hello_world
TARGET_LED=led_blinky

SRC_HELLO := $(filter-out drivers/pin_mux_led.c led_blinky.c, $(wildcard drivers/*.c *.c))
SRC_LED := $(filter-out drivers/pin_mux_hello.c hello_world.c, $(wildcard drivers/*.c *.c))
OBJ_HELLO=$(patsubst %.c, %.o, $(SRC_HELLO))
OBJ_LED=$(patsubst %.c, %.o, $(SRC_LED))

all: build size
build: elf
elf: $(TARGET_HELLO).elf $(TARGET_LED).elf


$(TARGET_HELLO).elf: $(OBJ_HELLO)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJ_HELLO) $(LDLIBS) -o $@

$(TARGET_LED).elf: $(OBJ_LED)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJ_LED) $(LDLIBS) -o $@

size:
	$(SIZE) $(TARGET_HELLO).elf $(TARGET_LED).elf

flash_hello: $(TARGET_HELLO).elf
	openocd -f openocd.cfg -c "program $(TARGET_HELLO).elf verify reset exit"

flash_led: $(TARGET_LED).elf
	openocd -f openocd.cfg -c "program $(TARGET_LED).elf verify reset exit"

clean:
	$(RM) $(TARGET_HELLO).srec $(TARGET_HELLO).elf $(TARGET_HELLO).bin $(TARGET_HELLO).map $(TARGET_LED).srec $(TARGET_LED).elf $(TARGET_LED).bin $(TARGET_LED).map $(OBJ_HELLO) $(OBJ_LED)