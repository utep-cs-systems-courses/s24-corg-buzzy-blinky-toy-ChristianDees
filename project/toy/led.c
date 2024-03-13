#include <msp430.h>
#include "led.h"
#include "switches.h"


void led_init()
{
    P1DIR |= LEDS;        // bits attached to leds are output
    P1OUT &= ~LEDS;
}

void greenOn(){
    P1OUT &= ~LEDS;
    P1OUT |= LED_GREEN;
}
void redOn(){
    P1OUT &= ~LEDS;
    P1OUT |= LED_RED;
}
void lightsOn(){
    P1OUT &= ~LEDS;
    P1OUT |= LEDS;
}
void lightsOff(){
    P1OUT &= ~LEDS;
}
