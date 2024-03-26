#include <msp430.h>
#include "libTimer.h"
#include <stdlib.h>
#include "buzzer.h"

// buzzer vars
int buzz_seconds = 0;           // number of times function is called during each interrupt
char buzz_second_count = 0;     // count of buzz_seconds var
char buzz_toggler = 0;          // char toggler indicating when buzzer should be on/off
char buzz_changes = 0;          // total buzzer changes, used for speeding up buzz
int buzz_speed_main = 500;      // default buzzer speed: easy level
char buzz_speed_quarter = 125;  // default turn off buzzer speed

// initialize the buzzer and config timer A to generate PWM (pulse with modulation)
// for driving the buzzer
void buzzer_init()
{
    timerAUpmode();             // set timer A in up mode for PWM
    P2SEL2 &= ~(BIT6 | BIT7);   // clear P2SEL2.6 and 7 for pin config
    P2SEL &= ~BIT7;             // clear P2SEL.7 for config
    P2SEL |= BIT6;              // set P2SEL.6 for timer A output
    P2DIR = BIT6;               // set P2.6 direction as output for driving the buzzer
}

// set period of the PWM signal
// this buzzer clock is 2MHz
void buzzer_set_period(short cycles)
{
  // capture compare registers
  CCR0 = cycles;        // set period of PWM (how often PWM repeats itself)
  CCR1 = cycles >> 1;   // signal is on same time it is off (making a stable waveform)
}

// buzz mario theme
void mario_buzzer(){
    int notes[49] = {6060, 0, 6060, 0, 0, 6060, 0, 0, 7640, 
        0, 6060, 0, 5100,5100,0,0,5100,0,0,7640,0,0,5100,0,
        0,6060,0,0,4540,0,4040,0,4040,0,4540,0,5100,0,6060,
        0,5100,0,4540,0,5720,0, 5100,0,0};
    buzz_seconds++;
    if (buzz_seconds >= 31) {   // every 31th of a second
        buzz_seconds = 0;
        buzz_second_count++;
        int index = buzz_second_count - 1;
        buzzer_set_period(notes[index]);    // play current note of song
    }
}

// buzz imperial march theme
void star_wars_buzzer(){
    int notes[26]={6500,6500,0,6500,6500,
        0,6500,6500,0,9000,9000,0,5500,0,
        6500,6500,0,9000,9000,0,5500,0,
        6500,6500,6500,6500};
    buzz_seconds++;
    if (buzz_seconds >= 60) {   // every 31th of a second
        buzz_seconds = 0;
        buzz_second_count++;
        int index = buzz_second_count - 1;
        buzzer_set_period(notes[index]);    // play current note of song
    }
}

// buzz 3 times for pregame state
void buzz_four_times(){
    buzz_seconds++;
    if (buzz_seconds >= 125) {    // once every half second
        buzz_seconds = 0;
        buzz_second_count++;
        buzz_toggler ^= 1;        // "turn on/off" buzzer
        buzzer_set_period(4545);
        if (!(buzz_toggler))      // if buzzer should be off, set frequency 0
          buzzer_set_period(0);
        if (buzz_second_count==7) // on fourth buzz, buzz higher pitch
            buzzer_set_period(2000);
    }
}

// buzz once during game led change
void buzz_once(void){
    buzz_seconds++;
    if(buzz_seconds >= buzz_speed_quarter){   // turn buzzer off after quarter of main time
        buzzer_set_period(0);
        if (buzz_seconds >= buzz_speed_main){ // buzzer on after set speed
            if(buzz_second_count){            // after the first buzz
                if (buzz_changes < 16)    // increment only up to 15
                    buzz_changes++;
                buzz_second_count = 0;    // reset total second counter
            } else {
                buzz_second_count++;
                buzz_seconds = 0;
                buzzer_set_period(4545);  // if there is input, buzz for next set of leds
            }
            if (((buzz_changes % 3)==0) && buzz_changes <= 15){ // 6 levels of the game
                buzz_speed_main -= .10*buzz_speed_main;         // turn on buzz faster
                buzz_speed_quarter = .25*buzz_speed_main;       // turn off buzz faster
            }
        }
    }
}

// buzz 2 times when game ends
void buzz_game_over(){
    buzz_seconds++;
    if (buzz_seconds >= 90) {      // once every 90th of a second
        buzz_seconds = 0;
        buzz_second_count++;
        buzz_toggler ^= 1;         // "toggle buzzer on/off"
        buzzer_set_period(8000);
        if (!(buzz_toggler))       // if buzzer is not on, set frequency to 0
          buzzer_set_period(0);
        if (buzz_second_count==3){ // on second buzz, make lower pitch
            buzzer_set_period(15000);
        }
    }
}
