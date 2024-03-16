#include <msp430.h>
#include "stateMachines.h"

void
__interrupt_vec(WDT_VECTOR) WDT()   // 250 times per second
{
    // switch state when necessary
    switch (current_state) {
        case WAITING:   // default state
            state_waiting();
            break;
        case PREGAME:   // countdown to game state
            state_pregame();
            break;
        case DURINGGAME:    // game is playing state
            state_duringgame();
            break;
        case GAMEOVER:  // state once game over
            state_gameover();
            break;
    }
}
