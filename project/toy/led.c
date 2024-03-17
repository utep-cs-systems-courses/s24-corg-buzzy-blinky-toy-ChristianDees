#include <msp430.h>
#include "led.h"
#include "stateMachines.h"
#include "buzzer.h"
#include "randomInt.h"
#include "libTimer.h"


// dtb_btd() vars
char green_blinkLimit = 5; // initially keep green dim
char red_blinkLimit = 1;  // initially keep red bright
char green_blinkCount = 0;
char red_blinkCount = 0;

// led vars
int ledSeconds = 0;
char ledSecondCount = 0;
char random_led = 0;

char buttonFlag = 0;

// initialize leds
void led_init()
{
    P1DIR |= LEDS;
    P1OUT &= ~LEDS;
}

// turn green led on
void greenOn(){
    P1OUT &= ~LEDS;
    P1OUT |= LED_GREEN;
}

//turn red led on
void redOn(){
    P1OUT &= ~LEDS;
    P1OUT |= LED_RED;
}

// turn both leds on
void lightsOn(){
    P1OUT &= ~LEDS;
    P1OUT |= LEDS;
}

// turn both leds off
void lightsOff(){
    P1OUT &= ~LEDS;
}

// green starts dim, gradually getting brighter
// red starts bright, gradually getting dimmer
void dtb_btd(){
    green_blinkCount++;
    if (green_blinkCount >= green_blinkLimit) { // on for 1 interrupt period
      green_blinkCount = 0;
      P1OUT |= LED_GREEN; // set green
    } else if (green_blinkCount < green_blinkLimit)
      P1OUT &= ~LED_GREEN; // clear green
    if (red_blinkCount >= red_blinkLimit){
      red_blinkCount = 0;
      P1OUT |=  LED_RED; // set red
    } else if (red_blinkCount < red_blinkLimit)
    P1OUT &= ~LED_RED; // clear red
    red_blinkCount++;
    ledSeconds ++;
    if (ledSeconds >= 250) {  // once each second
      ledSeconds = 0;
      red_blinkLimit ++;// make red blink more (get dimmer)
      green_blinkLimit --; // make green blink less (get less dim)
      if (green_blinkLimit <= 0)
         green_blinkLimit = 5; // reset green to 5 blinks
      if (red_blinkLimit > 5)
         red_blinkLimit = 1; // reset red to 1 blink
    }
}

// blink countdown (red, red, red, green)
void blink_four_times(){
    if (ledSecondCount == 8){
        ledSecondCount = 0;     // reset total second counter
        lightsOff();            // turn lights off before starting game
        transition(DURINGGAME); // once done blinking, start game
    }
    ledSeconds ++;
    if (ledSeconds >= 125) {    // once each second
        ledSeconds = 0;
        ledSecondCount++;
        if (ledSecondCount > 6){
            P1OUT &= ~LED_RED;
            P1OUT |= LED_GREEN; // turn green on last blink
        } else {
            P1OUT ^= LED_RED; // blink red 3 times
        }
    }
}

// random leds every 2 seconds
void ledGame(){
    ledSeconds++;
    if (ledSeconds >= 500) { // once every 2 seconds
        if (ledSecondCount){    // leds have changed once
            if (!buttonFlag){   // if no user input, end game
                updateGameOver();
            }
            buttonFlag = 0;     // reset button flag
            ledSecondCount = 0; // reset total second counter
        } else {
            ledSecondCount++;
            ledSeconds = 0;
            random_led = random_int_generator(); // get random int (1-4)
            switch (random_led) {
                case 1:
                    greenOn(); // Turn on green LED
                    break;
                case 2:
                    redOn(); // Turn on red LED
                    break;
                case 3:
                    lightsOn(); // Turn on both LEDs
                    break;
                case 4:
                    lightsOff(); // Turn off both LEDs
                    break;
            }
        }
    }
}


// prerequisites to switching state to gameover
void updateGameOver(){
    buzzer_set_period(0);
    lightsOff();
    ledSeconds = 0;
    buzzSeconds = 0;
    ledSecondCount = 0;
    buzzSecondCount = 0;
    transition(GAMEOVER);
}

// prerequisites to switching state to PREGAME
// resets WAITING vars once interrupted
void updatePreGame(){
    lightsOff();
    green_blinkLimit = 5;
    red_blinkLimit = 1;
    green_blinkCount = 0;
    red_blinkCount = 0;
    buzzSeconds = 0;
    ledSeconds = 0;
    transition(PREGAME);
}

