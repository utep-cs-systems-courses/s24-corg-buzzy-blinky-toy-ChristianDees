#ifndef switches_included
#define switches_included

#define SW0 BIT3


void switch_update_interrupt_sense();
void switch_init();
void switch_interrupt_handler();

#endif // included
