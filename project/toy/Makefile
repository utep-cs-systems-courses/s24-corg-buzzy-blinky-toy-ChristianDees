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

combined.elf: ${COMMON_OBJECTS} led.o buzzer.o switches.o p2_interrupt_handler.o random_int.o state_machines.o vector_interrupt_handlers.o p1_interrupt_handler.o ../lib/libTimer.a
	${CC} ${CFLAGS} ${LDFLAGS} -o $@ $^

load: combined.elf
	msp430loader.sh $^

clean:
	rm -f *.o *.elf
