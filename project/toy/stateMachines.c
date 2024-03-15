#include <msp430.h>
#include "stateMachines.h"
#include "led.h"
#include "libTimer.h"
#include "buzzer.h"

State current_state = WAITING;

void state_waiting() {
    dtb_btd();
}

void state_pregame() {
    buzz_four_times();
    blink_four_times();
}

void state_duringgame() {
    buzz_once();
    ledGame();
}

void state_gameover(){
    // add buzz game over sounds
    ledGameOver();
}

void transition(State next_state) {
    current_state = next_state;
    
}
