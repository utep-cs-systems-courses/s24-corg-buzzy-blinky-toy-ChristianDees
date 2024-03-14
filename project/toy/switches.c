#include <msp430.h>
#include "switches.h"
#include "led.h"
#include "stateMachines.h"

void
switch_update_interrupt_sense()
{
    char p1val = P1IN;
  /* update switch interrupt to detect changes from current buttons */
    P1IES |= (p1val & SW0);    /* if switch up, sense down */
    P1IES &= (p1val | ~SW0);    /* if switch down, sense up */
}

void
switch_init()            /* setup switch */
{
    P1REN |= SW0;        /* enables resistors for switches */
    P1IE |= SW0;        /* enable interrupts from switches */
    P1OUT |= SW0;        /* pull-ups for switches */
    P1DIR &= ~SW0;        /* set switches' bits for input */
    
    switch_update_interrupt_sense();
}

void
switch_interrupt_handler()
{
    char p1val = P1IN;
    if (current_state == WAITING){
        if (!(p1val & SW0)) {
            P1OUT &= ~LEDS;
            transition(PREGAME);
        }
    }
}

