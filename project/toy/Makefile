# makfile configuration
COMMON_OBJECTS  = main.o
CPU             = msp430g2553
CFLAGS          = -mmcu=${CPU} -I../h
LDFLAGS		= -L/opt/ti/msp430_gcc/include

#switch the compiler (for the internal make rules)
CC              = msp430-elf-gcc
AS              = msp430-elf-as

all: combined.elf 

#additional rules for files

combined.elf: ${COMMON_OBJECTS} randomInt.o buzzer.o stateMachines.o vector_interrupt_handlers.o p1_interrupt_handler.o led.o switches.o ../lib/libTimer.a
	${CC} ${CFLAGS} ${LDFLAGS} -o $@ $^

load: combined.elf
	msp430loader.sh $^

clean:
	rm -f *.o *.elf

buzzer.c: buzzer.h
stateMachines.c: stateMachines.h led.h buzzer.h
switches.c: switches.h led.h stateMachines.h buzzer.h
main.c: led.h switches.h buzzer.h randomInt.h
led.c: led.h switches.h stateMachines.h buzzer.h randomInt.h
p1_interrupt_handler.c: switches.h
vector_interrupt_handlers.c: stateMachines.h
