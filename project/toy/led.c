#include <msp430.h>
#include "led.h"
#include "stateMachines.h"
#include "buzzer.h"
#include "randomInt.h"
#include "libTimer.h"


// dtb_btd() vars
int green_blinkLimit = 5; // initially keep green dim
int red_blinkLimit = 1;  // initially keep red bright
int green_blinkCount = 0;
int red_blinkCount = 0;
int secondCount = 0;

// blink_four_times() vars
int countSeconds = 0;
int thirdCount = 0;

// ledGame() vars
int random_led = 0;
int second = 0;


// ledGameOver() vars
int gameOverSeconds = 0;
int gameOverCount = 0;


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
    secondCount ++;
    if (secondCount >= 250) {  // once each second
      secondCount = 0;
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
    if (thirdCount == 8){
        countSeconds = 0;
        thirdCount = 0;
        P1OUT &= ~LEDS;
        transition(DURINGGAME); // once done blinking, start game
    }
    countSeconds ++;
    if (countSeconds >= 125) {     // once each second
      countSeconds = 0; // reset count
      thirdCount++;
        if (thirdCount > 6){
            P1OUT &= ~LED_RED;
            P1OUT |= LED_GREEN; // turn green on last blink
        } else {
            P1OUT ^= LED_RED; // blink red 3 times
        }
    }
}

// random leds every 2 seconds
void ledGame(){
    second++;
    if (second >= 500) { // once every 2 seconds
        second = 0;
        random_led = random_int_generator();
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


// prerequisites to switching state to gameover
void updateGameOver(){
    buzzer_set_period(0);
    lightsOff();
    transition(GAMEOVER);
}
// prerequisites to switching state to PREGAME
void updatePreGame(){
    lightsOff();
    green_blinkLimit = 5;
    red_blinkLimit = 1;
    green_blinkCount = 0;
    red_blinkCount = 0;
    secondCount = 0;
    transition(PREGAME);
}

