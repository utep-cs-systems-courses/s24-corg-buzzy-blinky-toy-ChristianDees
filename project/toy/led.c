#include <msp430.h>
#include "led.h"
#include "stateMachines.h"
#include "buzzer.h"
#include "randomInt.h"
#include "libTimer.h"

// dtb_btd() vars
char green_blinkLimit = 5;  // initially keep green dim
char red_blinkLimit = 1;    // initially keep red bright
char green_blinkCount = 0;  // total times green blinked
char red_blinkCount = 0;    // total times red blinked

// led vars
int led_seconds = 0;        // counts each interrupt occuring
char led_second_count = 0;  // total seconds passed
char random_led = 0;        // random led 1-4
int led_speed = 500;        // easy level speed
char led_changes = 0;       // total led changes, used for speeding up led
char button_flag = 0;       // button pressed flag

// easter egg flag
char easter_egg = 0;


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
    if (led_second_count == 3){
        update_vars();
        transition(EASTEREGG);
    } else {
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
            P1OUT &= ~LED_RED;    // clear red
        red_blinkCount++;
        led_seconds ++;
        if (led_seconds >= 250) { // once each second
            if (easter_egg)
                led_second_count++;
            led_seconds = 0;
            red_blinkLimit ++;        // make red blink more (get dimmer)
            green_blinkLimit --;      // make green blink less (get less dim)
            if (green_blinkLimit <= 0)
                green_blinkLimit = 5; // reset green to 5 blinks
            if (red_blinkLimit > 5)
                red_blinkLimit = 1;   // reset red to 1 blink
        }
    }
}

// mario theme lights
// 0 = lights off
// 1 = green on
// 2 = red on
char lights[58] = {2, 0, 2, 0, 0, 2, 0, 0, 1,
    0, 2, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1,
    0, 0, 2, 0, 0, 1, 0, 2, 0, 2, 0, 1, 0, 1,
    0, 2, 0, 1, 0, 1, 0, 2, 0, 1, 0, 0, 2, 0,
    1, 0, 1, 0, 2, 0, 0};

// light show to match the mario theme
void mario_led(){
    if (led_second_count == 58){
        update_vars();          // update all variables
        transition(WAITING);    // go back to waiting state when done
    } else {
        led_seconds++;
        if (led_seconds>=31){
            led_seconds = 0;
            led_second_count++;
            int index = led_second_count - 1;
            if (lights[index] == 0)
                lights_off();
            if (lights[index] == 1)
                green_on();
            if (lights[index] == 2)
                red_on();
        }
    }
}

// blink countdown (red, red, red, green)
void blink_four_times(){
    if (led_second_count == 8){
        update_vars();             // update all variables
        transition(DURINGGAME);    // start game
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

// random led changes
void led_game(){
    led_seconds++;
    if (led_seconds >= led_speed) {   // once every led_speed
        if (led_second_count){        // leds have changed once
            if (!button_flag){        // if no user input, end game
                update_vars();
                transition(GAMEOVER);
            }
            if (led_changes < 16) // increment only up to 15
                led_changes++;    
            button_flag = 0;      // reset button flag
            led_second_count = 0; // reset total second counter
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
        if (((led_changes % 3)==0) && led_changes <= 15) // 6 levels, increasingly getting faster
            led_speed -= .10*led_speed; // leds change faster
    }
}

// resets all vars before transitioning to new state
void update_vars(){
    
    lights_off();
    
    green_blinkLimit = 5;
    red_blinkLimit = 1;
    green_blinkCount = 0;
    red_blinkCount = 0;
    
    led_seconds = 0;
    led_second_count = 0;
    led_changes = 0;
    led_speed = 500;
    
    buzz_seconds = 0;
    buzz_second_count = 0;
    buzz_changes = 0;
    buzz_speed_main = 500;
    buzz_speed_quarter = 125;
    buzzer_set_period(0);
    
    button_flag = 0;
    easter_egg = 0;
}
