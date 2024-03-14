#include <msp430.h>
#include "switches.h"
#include "led.h"
#include "stateMachines.h"

void
switch_update_interrupt_sense()
{
    char p1val = P1IN;
    char p2val = P2IN;
  /* update switch interrupt to detect changes from current buttons */
    P1IES |= (p1val & SW0);    /* if switch up, sense down */
    P1IES &= (p1val | ~SW0);    /* if switch down, sense up */
    P2IES |= (p2val & SWITCHES);    /* if switch up, sense down */
    P2IES &= (p2val | ~SWITCHES);    /* if switch down, sense up */
}

void
switch_init()            /* setup switch */
{
    P1REN |= SW0;        /* enables resistors for switches */
    P1IE |= SW0;        /* enable interrupts from switches */
    P1OUT |= SW0;        /* pull-ups for switches */
    P1DIR &= ~SW0;        /* set switches' bits for input */
    
    
    P2REN |= SWITCHES;
    P2IE = SWITCHES;
    P2OUT |= SWITCHES;
    P2DIR &= ~SWITCHES;
    
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
    char p2val = P2IN;
    
    char button1 = (p2val & SW1) ? 0 : SW1;
        char button2 = (p2val & SW2) ? 0 : SW2;
        char button3 = (p2val & SW3) ? 0 : SW3;
        char button4 = (p2val & SW4) ? 0 : SW4;
    if (current_state == DURINGGAME){
        if (button1) {
            if ((P1OUT & LED_GREEN) && !(P1OUT & LED_RED) && !(P1OUT & LEDS))
                goto CONTINUE;
            goto END;
        } else if (button2) {
            if ((P1OUT & LED_RED) && !(P1OUT & LED_GREEN) && !(P1OUT & LEDS))
                goto CONTINUE;
            goto END;

        } else if (button3) {
            if ((P1OUT & LED_GREEN) && (P1OUT & LED_RED) && !(P1OUT & ~LEDS))
                goto CONTINUE;
            goto END;
        } else if (button4) {
            if (!(P1OUT & LED_GREEN) && !(P1OUT & LED_RED) && !(P1OUT & ~LEDS))
                goto CONTINUE;
            goto END;
        }
        goto CONTINUE;
    END:
        P1OUT &= ~LEDS;
        transition(GAMEOVER);
    CONTINUE:
        return;
    }
}

