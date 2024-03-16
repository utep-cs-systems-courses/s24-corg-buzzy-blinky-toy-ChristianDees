#ifndef switches_included
#define switches_included

#define SW0 BIT3        // side switch p1.3
#define SW1 BIT0        // button 1, p2.0
#define SW2 BIT1        // button 2, p2.1
#define SW3 BIT2        // button 3, p2.2
#define SW4 BIT3        // button 4, p2.3

#define SWITCHES (SW1|SW2|SW3|SW4)  // all of port 2 switches

// prototype functions
void switch_update_interrupt_sense();
void switch_init();
void switch_interrupt_handler();
void updateGameOver();

#endif // included
