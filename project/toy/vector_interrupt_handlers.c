#include <msp430.h>
#include "stateMachines.h"

void
__interrupt_vec(WDT_VECTOR) WDT()   // 250 times per second
{
    // switch state when necessary
    switch (current_state) {
        case WAITING:       // default state: dimming lights
            state_waiting();
            break;
        case EASTEREGG:     // play mario theme
            state_easter_egg();
            break;
        case SECONDEASTEREGG: // play star wars theme
            state_second_easter_egg();
            break;
        case PREGAME:       // countdown to game
            state_pregame();
            break;
        case DURINGGAME:    // game is playing
            state_duringgame();
            break;
        case GAMEOVER:      // game over state
            state_gameover();
            break;
    }
}
