#include <msp430.h>
#include "libTimer.h"
#include <stdlib.h>
#include "buzzer.h"

// buzz_four_times() vars
int second4 = 0;
int buzzCounter = 0;
char toggle_buzzer = 0;
int interruptCount = 0;

// buzz_once() vars
int buzzSecond3 = 0;
int buzzOnceCounter = 0;


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
    if (interruptCount == 8){ // stop after 4th buzz
        interruptCount = 0;
        buzzCounter = 0;
        toggle_buzzer = 0;
        second4 = 0;
    }
    second4++;
    if (second4 >= 125) { // once every half second
        second4 = 0;
        interruptCount++;
        toggle_buzzer ^= 1; // "turn on/off" buzzer
        buzzer_set_period(4545);
        if (!(toggle_buzzer)) // if buzzer should be off, set frequency 0
          buzzer_set_period(0);
        if (interruptCount==7) // on fourth buzz, buzz higher pitch
            buzzer_set_period(2000);
    }
}

// buzz once during game led change
void buzz_once(void){
    if(buzzOnceCounter == 1){
        buzzSecond3 = 0;
        buzzOnceCounter = 0;
    }
    buzzSecond3++;
    if(buzzSecond3 >= 125){
        buzzer_set_period(0);
        if (buzzSecond3 >= 500){
            buzzSecond3 = 0;
            buzzer_set_period(4545);
            buzzOnceCounter++;
        }
    }
}

// buzz 2 times when game ends
void buzz_game_over(){

}
