#ifndef led_included
#define  led_included

#include <msp430.h>

#define LED_GREEN BIT0               // P1.0
#define LED_RED BIT6             // P1.6
#define LEDS (BIT0 | BIT6)

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

extern int random_led;
#endif
