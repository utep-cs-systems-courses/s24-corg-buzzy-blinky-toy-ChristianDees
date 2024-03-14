#include <msp430.h>
#include "led.h"
#include "stateMachines.h"

int random_led = 0;
int green_blinkLimit = 5;  //
int red_blinkLimit = 1;  // initially keep red on
int green_blinkCount = 0;  // cycles 0...blinkLimit-1
int red_blinkCount = 0;
int secondCount = 0;

int countSeconds = 0;
int thirdCount = 0;


int second = 0;


// gameover vars

int gameOverSeconds = 0;
int gameOverCount = 0;


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

void dtb_btd(){
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

void blink_four_times(){
    if (thirdCount == 8){
        countSeconds = 0;
        thirdCount = 0;
        P1OUT &= ~LEDS;
        transition(DURINGGAME);
    }
    countSeconds ++;
    if (countSeconds >= 125) {     /* once each sec... */
      countSeconds = 0; // reset count
      thirdCount++;
        if (thirdCount > 6){
            P1OUT &= ~LED_RED;
            P1OUT |= LED_GREEN;
        } else {
            P1OUT ^= LED_RED;
        }
    }
}

void ledGameOver(){
    if (gameOverCount == 4){
        gameOverSeconds = 0;
        gameOverCount = 0;
        P1OUT &= ~LEDS;
        transition(WAITING);
    }
    gameOverSeconds ++;
    if (gameOverSeconds >= 125) {     /* once each sec... */
        gameOverSeconds = 0; // reset count
        gameOverCount++;
      P1OUT ^= LED_RED;
        
    }
}
