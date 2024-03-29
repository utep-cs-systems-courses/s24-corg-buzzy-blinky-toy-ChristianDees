#ifndef led_included
#define  led_included

#include <msp430.h>

#define LED_GREEN BIT0      // P1.0
#define LED_RED BIT6        // P1.6
#define LEDS (BIT0 | BIT6)  // P1.0 and P1.6

// prototype functions
void led_init();
void green_on();
void red_on();
void lights_on();
void lights_off();
void dtb_btd();
void mario_led();
void star_wars_led();
void blink_four_times();
void led_game();
void led_game_over();
void update_vars();
void update_game_over();

// external vars
extern char random_led;
extern char button_flag;
extern char easter_egg;
extern char interrupt_counter;

#endif
