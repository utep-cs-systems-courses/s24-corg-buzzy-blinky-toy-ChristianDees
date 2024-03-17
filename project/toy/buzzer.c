#include <msp430.h>
#include "libTimer.h"
#include <stdlib.h>
#include "buzzer.h"

int buzzSeconds = 0;
int buzzSecondCount = 0;
char buzzToggler = 0;


void buzzer_init()
{
    /*
       Direct timer A output "TA0.1" to P2.6.
        According to table 21 from data sheet:
          P2SEL2.6, P2SEL2.7, anmd P2SEL.7 must be zero
          P2SEL.6 must be 1
        Also: P2.6 direction must be output
    */
    timerAUpmode();        /* used to drive speaker */
    P2SEL2 &= ~(BIT6 | BIT7);
    P2SEL &= ~BIT7;
    P2SEL |= BIT6;
    P2DIR = BIT6;        /* enable output to speaker (P2.6) */
}

void buzzer_set_period(short cycles) /* buzzer clock = 2MHz.  (period of 1k results in 2kHz tone) */
{
  CCR0 = cycles;
  CCR1 = cycles >> 1;        /* one half cycle */
}


// buzz 3 times for pregame state
void buzz_four_times(){
    if (buzzSecondCount == 8)
        buzzSecondCount = 0;
    buzzSeconds++;
    if (buzzSeconds >= 125) { // once every half second
        buzzSeconds = 0;
        buzzSecondCount++;
        buzzToggler ^= 1; // "turn on/off" buzzer
        buzzer_set_period(4545);
        if (!(buzzToggler)) // if buzzer should be off, set frequency 0
          buzzer_set_period(0);
        if (buzzSecondCount==7) // on fourth buzz, buzz higher pitch
            buzzer_set_period(2000);
    }
}

// buzz once during game led change
void buzz_once(void){
    if(buzzSecondCount == 1){
        buzzSecondCount = 0;
    }
    buzzSeconds++;
    if(buzzSeconds >= 125){
        buzzer_set_period(0);
        if (buzzSeconds >= 500){
            buzzSeconds = 0;
            buzzer_set_period(4545);
            buzzSecondCount++;
        }
    }
}

// buzz 2 times when game ends
void buzz_game_over(){
    if (buzzSecondCount == 4){
        buzzSecondCount = 0;
    }
    buzzSeconds++;
    if (buzzSeconds >= 90) { // once every 90th of a second
        buzzSeconds = 0;
        buzzSecondCount++;
        buzzToggler ^= 1; // "toggle buzzer on/off"
        buzzer_set_period(8000);
        if (!(buzzToggler)) // if buzzer is not on, set frequency to 0
          buzzer_set_period(0);
        if (buzzSecondCount==3){ // on second buzz, make lower pitch
            buzzer_set_period(15000);
        }
    }
}
