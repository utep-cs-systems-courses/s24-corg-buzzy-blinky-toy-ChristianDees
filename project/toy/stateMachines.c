#include <msp430.h>
#include "stateMachines.h"
#include "led.h"
#include "libTimer.h"

int green_blinkLimit = 5;  //
int red_blinkLimit = 1;  // initially keep red on
int green_blinkCount = 0;  // cycles 0...blinkLimit-1
int red_blinkCount = 0;
int secondCount = 0;


State current_state = WAITING;




void state_waiting() {
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

void state_pregame() {
    
}

void state_duringgame() {
    
}


void state_gameover(){

  }

void transition(State next_state) {
    current_state = next_state;
    
}
