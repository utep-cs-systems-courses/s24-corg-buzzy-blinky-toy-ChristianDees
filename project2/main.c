#include <msp430.h>
#include "libTimer.h"

#define LED_GREEN BIT0               // P1.0
#define LED_RED BIT6             // P1.6
#define LEDS (BIT0 | BIT6)

#define SW1 BIT3		/* switch1 is p1.3 */
#define SWITCHES SW1		/* only 1 switch on this board */


static int ISRdim = 0; // Flag to enable/disable the first ISR
static int ISRblink = 0; // Flag to enable/disable the second ISR
void main(void) 
{  
  configureClocks();

  P1DIR |= LEDS;
  P1OUT &= ~LEDS;		/* leds initially off */
  enableWDTInterrupts();
  ISRdim = 1;

  
  P1REN |= SWITCHES;		/* enables resistors for switches */
  P1IE |= SWITCHES;		/* enable interrupts from switches */
  P1OUT |= SWITCHES;		/* pull-ups for switches */
  P1DIR &= ~SWITCHES;		/* set switches' bits for input */

  or_sr(0x18);  // CPU off, GIE on
} 


int green_blinkLimit = 5;  // 
int red_blinkLimit = 1;  // initially keep red on 
int green_blinkCount = 0;  // cycles 0...blinkLimit-1
int red_blinkCount = 0;
int secondCount = 0; // state var representing repeating time 0…1s

int second = 0;
int thirdCount = 0;

void
__interrupt_vec(WDT_VECTOR) WDT()       /* 250 interrupts/sec */
{
  if(ISRdim){
  // handle blinking
  green_blinkCount++;
  if (green_blinkCount >= green_blinkLimit) { // on for 1 interrupt period
    green_blinkCount = 0;
    P1OUT |= LED_GREEN; // set green
  } else if (green_blinkCount < green_blinkLimit)                          // off for blinkLimit - 1 interrupt periods
    P1OUT &= ~LED_GREEN; // clear green
  if (red_blinkCount >= red_blinkLimit){
    red_blinkCount = 0;
    P1OUT |=  LED_RED; // set red
  } else if (red_blinkCount < red_blinkLimit)
    P1OUT &= ~LED_RED; // clear red
  // measure a second
  red_blinkCount++;
  secondCount ++;
  if (secondCount >= 250) {  // once each second
    secondCount = 0;
    red_blinkLimit ++;
    green_blinkLimit --;           // reduce duty cycle
    if (green_blinkLimit <= 0)     // but don't let duty cycle go below 1/7.
      green_blinkLimit = 5;
    if (red_blinkLimit > 5)
      red_blinkLimit = 1;
  }
  }


  if(ISRblink){
  if (thirdCount == 6){
    P1OUT &= ~LED_RED;
    P1OUT |= LED_GREEN;
   
    //WDTCTL = WDTPW | WDTHOLD;
    ISRblink = 0;
    ISRdim = 0;
  }
  second ++;
  if (second >= 250) {     /* once each sec... */
    second = 0;/* reset count */
    thirdCount++;
    P1OUT ^= LED_RED;
  }
  }

  
}
/*
int thirdCount = 0;
int second = 0;
void
__interrupt_vec(WDT_VECTOR) WDT_BLINK_RED(void) {
 // flash the red led 3 times, one each second
  if(ISRblink){
  if (thirdCount == 6){
    P1OUT |= LED_GREEN;
    //WDTCTL = WDTPW | WDTHOLD;
    ISRblink = 0;
  }
  second ++;
  if (second >= 250) {     /* once each sec... */
//  second = 0;/* reset count */
//  thirdCount++;
//  P1OUT ^= LED_RED;
//}
//}
//}






void
switch_interrupt_handler()
{
  char p1val = P1IN;		/* switch is in P1 */

/* update switch interrupt sense to detect changes from current buttons */
  P1IES |= (p1val & SWITCHES);	/* if switch up, sense down */
  P1IES &= (p1val | ~SWITCHES);	/* if switch down, sense up */
 
/* up=red, down=green */

/* button pressed = red */
/* button NOT pressed = green */
  if (p1val & SW1) // if button is pressed flash 3 times
    P1OUT &= ~LEDS;
    ISRblink = 1;
}


/* Switch on P1 (S2) */
void
__interrupt_vec(PORT1_VECTOR) Port_1(){
  if (P1IFG & SWITCHES) {	      /* did a button cause this interrupt? */
    ISRdim = 0;
    P1IFG &= ~SWITCHES;		      /* clear pending sw interrupts */
    switch_interrupt_handler();	/* single handler for all switches */
  }
}


