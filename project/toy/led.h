#ifndef led_included
#define  led_included

#include <msp430.h>

#define LED_GREEN BIT0      // P1.0
#define LED_RED BIT6        // P1.6
#define LEDS (BIT0 | BIT6)  // P1.0 and P1.6

// prototype functions
void led_init();
void greenOn();
void redOn();
void lightsOn();
void lightsOff();
void dtb_btd();
void blink_four_times();
void ledGame();
void ledGameOver();
void updateGameOver();
void updatePreGame();

// external vars
extern char random_led;
extern char buttonFlag;

#endif
