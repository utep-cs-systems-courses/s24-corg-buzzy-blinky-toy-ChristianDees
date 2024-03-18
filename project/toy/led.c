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
int led_seconds = 0;        // counts each interrupt occuring
char led_second_count = 0;  // total seconds passed
char random_led = 0;        // random led 1-4
int led_speed = 500;        // easy level speed
int led_changes = 0;        // total led changes, used for speeding up led
char button_flag = 0;       // button pressed flag

// initialize leds
void led_init()
{
    P1DIR |= LEDS;
    P1OUT &= ~LEDS;
}

// turn green led on
void green_on(){
    P1OUT &= ~LEDS;
    P1OUT |= LED_GREEN;
}

//turn red led on
void red_on(){
    P1OUT &= ~LEDS;
    P1OUT |= LED_RED;
}

// turn both leds on
void lights_on(){
    P1OUT &= ~LEDS;
    P1OUT |= LEDS;
}

// turn both leds off
void lights_off(){
    P1OUT &= ~LEDS;
}

// green starts dim, gradually getting brighter
// red starts bright, gradually getting dimmer
void dtb_btd(){
    green_blinkCount++;
    if (green_blinkCount >= green_blinkLimit) { // on for 1 interrupt period
      green_blinkCount = 0;
      P1OUT |= LED_GREEN;   // set green
    } else if (green_blinkCount < green_blinkLimit)
      P1OUT &= ~LED_GREEN;  // clear green
    if (red_blinkCount >= red_blinkLimit){
      red_blinkCount = 0;
      P1OUT |=  LED_RED;    // set red
    } else if (red_blinkCount < red_blinkLimit)
    P1OUT &= ~LED_RED;      // clear red
    red_blinkCount++;
    led_seconds ++;
    if (led_seconds >= 250) {  // once each second
      led_seconds = 0;
      red_blinkLimit ++;       // make red blink more (get dimmer)
      green_blinkLimit --;     // make green blink less (get less dim)
      if (green_blinkLimit <= 0)
         green_blinkLimit = 5; // reset green to 5 blinks
      if (red_blinkLimit > 5)
         red_blinkLimit = 1;   // reset red to 1 blink
    }
}

// blink countdown (red, red, red, green)
void blink_four_times(){
    if (led_second_count == 8){
        update_during_game();      // once done blinking, start game
    } else {
        led_seconds ++;
        if (led_seconds >= 125) {  // once each second
            led_seconds = 0;
            led_second_count++;
            if (led_second_count > 6){
                green_on();        // turn green on last blink
            } else {
                P1OUT ^= LED_RED;  // blink red 3 times
            }
        }
    }
}

// random leds every 2 seconds
void led_game(){
    led_seconds++;
    if (led_seconds >= led_speed) {   // once every 2 seconds
        if (led_second_count){        // leds have changed once
            if (!button_flag){        // if no user input, end game
                update_game_over();
            } else{
                if (led_changes < 10) // only increase led_changes to 10
                    led_changes++;    //
                button_flag = 0;      // reset button flag
                led_second_count = 0; // reset total second counter
            }
        } else {
            led_second_count++;
            led_seconds = 0;
            random_led = random_int_generator(); // get random int (1-4)
            switch (random_led) {
                case 1:
                    green_on();   // Turn on green LED
                    break;
                case 2:
                    red_on();     // Turn on red LED
                    break;
                case 3:
                    lights_on();  // Turn on both LEDs
                    break;
                case 4:
                    lights_off(); // Turn off both LEDs
                    break;
            }
        }
        if (((led_changes % 3)==0) && led_changes <= 6){ // medium levels
            led_speed -= 50; // make led change faster
        } else if (led_changes == 9) // hard level
            led_speed -= 10; // make led change even faster
    }
}

// prerequisites to switching state to PREGAME
// resets WAITING vars once interrupted
void update_pre_game(){
    // reset all vars required for pre game
    // reset all waiting vars
    lights_off();
    green_blinkLimit = 5;
    red_blinkLimit = 1;
    green_blinkCount = 0;
    red_blinkCount = 0;
    buzz_seconds = 0;
    led_seconds = 0;
    transition(PREGAME);
}

// prerequisites to switching state to duringgame
void update_during_game(){
    lights_off();
    // reset all led vars
    led_seconds = 0;
    led_second_count = 0;
    led_changes = 0;
    led_speed = 500;
    // reset all buzzer vars
    buzz_seconds = 0;
    buzz_second_count = 0;
    buzz_changes = 0;
    buzz_speed_main = 500;
    buzz_speed_quarter = 125;
    transition(DURINGGAME);
}

// prerequisites to switching state to gameover
void update_game_over(){
    // reset all vars required for game over
    buzzer_set_period(0);
    lights_off();
    led_seconds = 0;
    buzz_seconds = 0;
    led_second_count = 0;
    buzz_second_count = 0;
    transition(GAMEOVER);
}
