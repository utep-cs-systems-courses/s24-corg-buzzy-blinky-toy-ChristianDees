#include <msp430.h>
#include "led.h"
#include "stateMachines.h"
#include "buzzer.h"
#include "randomInt.h"
#include "libTimer.h"

// dtb_btd() vars
char green_blink_limit = 5;  // initially keep green dim
char red_blink_limit = 1;    // initially keep red bright
char green_blink_count = 0;  // total times green blinked
char red_blink_count = 0;    // total times red blinked

// led vars
int led_seconds = 0;        // counts each interrupt occuring
char led_second_count = 0;  // total seconds passed
char random_led = 0;        // random led 1-4
int led_speed = 500;        // easy level speed
char led_changes = 0;       // total led changes, used for speeding up led
char button_flag = 0;       // button pressed flag

// easter egg flag
char easter_egg = 0;
int easter_egg_seconds = 0;

// side button timers
int interrupt_seconds = 0;
char interrupt_counter = 0;

// mario theme lights
char mario_lights[49] = {2,0,2,0,0,2,0,0,1,0,
     2,0,1,1,0,0,1,0,0,2,0,0,1,0,0,2,0,0,1,0,
     1,0,1,0,2,0,1,0,2,0,1,0,2,0,1,0,1,0,0};

// star wars leds
char star_wars_lights[26] = {2,2,0,2,2,0,2,2,0,
            1,1,0,2,0,1,1,0,2,2,0,1,0,2,2,2,2};


/*
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
*/
// green starts dim, gradually getting brighter
// red starts bright, gradually getting dimmer
/*
void dtb_btd(){
    // begin counter once button released
    if (interrupt_counter)
        interrupt_seconds++;
    // begin counter once button pressed
    if (easter_egg)
        easter_egg_seconds++;
    // move to easter egg state
    // after button held for 3 seconds
    if (led_second_count == 3){
        transition(EASTEREGG);
    // if user presses button twice within 70/250 seconds
    // move to second easter egg state
    } else if (interrupt_counter == 2 && interrupt_seconds <= 70){
        transition(SECONDEASTEREGG);
    // if user presses button only once
    // move to pregame state
    }else if (interrupt_counter == 1 && interrupt_seconds > 70){
        transition(PREGAME);
    }else {
        green_blink_count++;
        if (green_blink_count >= green_blink_limit) { // on for 1 interrupt period
            green_blink_count = 0;
            P1OUT |= LED_GREEN;   // set green
        } else if (green_blink_count < green_blink_limit)
            P1OUT &= ~LED_GREEN;  // clear green
        if (red_blink_count >= red_blink_limit){
            red_blink_count = 0;
            P1OUT |=  LED_RED;    // set red
        } else if (red_blink_count < red_blink_limit)
            P1OUT &= ~LED_RED;    // clear red
        red_blink_count++;
        led_seconds ++;
        // count total seconds button held down
        if (easter_egg_seconds >= 250){ // once each second
            led_second_count++;
            easter_egg_seconds = 0;
        }
        if (led_seconds >= 250) {     // once each second
            led_seconds = 0;
            red_blink_limit ++;        // make red blink more (get dimmer)
            green_blink_limit --;      // make green blink less (get less dim)
            if (green_blink_limit <= 0)
                green_blink_limit = 5; // reset green to 5 blinks
            if (red_blink_limit > 5)
                red_blink_limit = 1;   // reset red to 1 blink
        }
    }
}
*/
/*
// light show to match the mario theme
void mario_led(){
    if (led_second_count == 49){
        transition(WAITING);    // go back to waiting state when done
    } else {
        led_seconds++;
        if (led_seconds>=31){   // every 31th of a second
            led_seconds = 0;
            led_second_count++;
            char index = led_second_count - 1;
            if (mario_lights[index] == 0)
                lights_off();
            if (mario_lights[index] == 1)
                green_on();
            if (mario_lights[index] == 2)
                red_on();
        }
    }
}
*/
/*
// light show to match the star wars theme
void star_wars_led(){
    if (led_second_count == 26){
        transition(WAITING);    // go back to waiting state when done
    } else {
        led_seconds++;
        if (led_seconds>=60){   // every 60th of a second
            led_seconds = 0;
            led_second_count++;
            char index = led_second_count - 1;
            if (star_wars_lights[index] == 0)
                lights_off();
            if (star_wars_lights[index] == 1)
                green_on();
            if (star_wars_lights[index] == 2)
                red_on();
        }
    }
}
*/
// blink countdown (red, red, red, green)
/*
void blink_four_times(){
    if (led_second_count == 8){
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
*/
// random led changes
/*
void led_game(){
    led_seconds++;
    if (led_seconds >= led_speed) {   // once every led_speed
        if (led_second_count){        // leds have changed once
            if (!button_flag){        // if no user input, end game
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
        if (led_changes <= 10) {
            if ((led_changes & 1) == 0 && led_changes != 0) { // Check if buzz_changes is even (excluding 0)
                led_speed -= led_speed >> 3;       // Equivalent to buzz_speed_main / 8
            }
        }
    }
}
 */
/*
// resets all vars before transitioning to new state
void update_vars(){
    lights_off();
    
    green_blink_limit = 5;
    red_blink_limit = 1;
    green_blink_count = 0;
    red_blink_count = 0;
    
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
    easter_egg_seconds = 0;
    
    interrupt_counter = 0;
    interrupt_seconds = 0;
}
*/
