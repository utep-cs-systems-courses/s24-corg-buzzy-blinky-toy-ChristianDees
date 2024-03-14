#include <msp430.h>
#include "stateMachines.h"
#include "led.h"
#include "libTimer.h"

State current_state = WAITING;

void state_waiting() {
    dtb_btd();
}

void state_pregame() {
    // add buzz three time sounds
    blink_four_times();
}

void state_duringgame() {
    // add buzz once sounds
    // add game function
}

void state_gameover(){
    // add buzz game over sounds
    ledGameOver();
}

void transition(State next_state) {
    current_state = next_state;
    
}
