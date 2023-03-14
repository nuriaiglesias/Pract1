#TOOLCHAIN=~/toolchain/gcc-arm-none-eabi-4_9-2014q4/bin
#PREFIX=$(TOOLCHAIN)/arm-none-eabi-
PREFIX=arm-none-eabi-

ARCHFLAGS=-mthumb -mcpu=cortex-m0plus
COMMONFLAGS=-g3 -Og -Wall -Werror $(ARCHFLAGS)

CFLAGS=-I./drivers $(COMMONFLAGS) -D CPU_MKL46Z256VLL4
LDFLAGS=$(COMMONFLAGS) --specs=nano.specs -Wl,--gc-sections,-Tlink.ld

CC=$(PREFIX)gcc
LD=$(PREFIX)gcc
RM=rm -f

TARGET_HELLO=hello_world
TARGET_LED=led_blinky

SRC_HELLO= $(filter-out drivers/pin_mux_led.c led_blinky.c, $(wildcard drivers/*.c *.c))
SRC_LED= $(filter-out drivers/pin_mux_hello.c hello_world.c, $(wildcard drivers/*.c *.c))
OBJ_HELLO=$(patsubst %.c, %.o, $(SRC_HELLO))
OBJ_LED=$(patsubst %.c, %.o, $(SRC_LED))

$(TARGET_HELLO).elf: $(OBJ_HELLO)
	$(LD) $(LDFLAGS) $(OBJ_HELLO) -o $@

$(TARGET_LED).elf: $(OBJ_LED)
	$(LD) $(LDFLAGS) $(OBJ_LED) -o $@

flash_hello: $(TARGET_HELLO).elf
	openocd -f openocd.cfg -c "program $(TARGET_HELLO).elf verify reset exit"

flash_led: $(TARGET_LED).elf
	openocd -f openocd.cfg -c "program $(TARGET_LED).elf verify reset exit"

clean:
	rm -f *.elf *.o drivers/*.o