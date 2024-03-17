#include <msp430.h>
#include "libTimer.h"
#include <stdlib.h>
#include "buzzer.h"

// buzzer vars
int buzzSeconds = 0;        // number of times function is called during each interrupt
char buzzSecondCount = 0;   // count of buzzSeconds var
char buzzToggler = 0;       // char toggler indicating when buzzer should be on/off


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

// buzz 3 times for pregame state
void buzz_four_times(){
    if (buzzSecondCount == 8)
        buzzSecondCount = 0;    // reset total second counter
    buzzSeconds++;
    if (buzzSeconds >= 125) {   // once every half second
        buzzSeconds = 0;
        buzzSecondCount++;
        buzzToggler ^= 1;       // "turn on/off" buzzer
        buzzer_set_period(4545);
        if (!(buzzToggler))     // if buzzer should be off, set frequency 0
          buzzer_set_period(0);
        if (buzzSecondCount==7) // on fourth buzz, buzz higher pitch
            buzzer_set_period(2000);
    }
}

// buzz once during game led change
void buzz_once(void){
    if(buzzSecondCount == 1){
        buzzSecondCount = 0;     // reset total second counter
    }
    buzzSeconds++;
    if(buzzSeconds >= 125){      // turn buzzer off after half a second
        buzzer_set_period(0);
        if (buzzSeconds >= 500){ // buzzer on after 1 second
            buzzSeconds = 0;
            buzzer_set_period(4545);
            buzzSecondCount++;
        }
    }
}

// buzz 2 times when game ends
void buzz_game_over(){
    if (buzzSecondCount == 4){
        buzzSecondCount = 0;     // reset total second counter
    }
    buzzSeconds++;
    if (buzzSeconds >= 90) {     // once every 90th of a second
        buzzSeconds = 0;
        buzzSecondCount++;
        buzzToggler ^= 1;        // "toggle buzzer on/off"
        buzzer_set_period(8000);
        if (!(buzzToggler))      // if buzzer is not on, set frequency to 0
          buzzer_set_period(0);
        if (buzzSecondCount==3){ // on second buzz, make lower pitch
            buzzer_set_period(15000);
        }
    }
}
