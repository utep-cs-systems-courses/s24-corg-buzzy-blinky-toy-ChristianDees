#ifndef switches_included
#define switches_included

#define SW0 BIT3//p1.3                /* switch1 is p1.3 */


void switch_update_interrupt_sense();
void switch_init();
void switch_interrupt_handler();

#endif // included
