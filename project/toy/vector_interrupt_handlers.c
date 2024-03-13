#include <msp430.h>
#include "led.h"
#include "stateMachines.h"


void
__interrupt_vec(WDT_VECTOR) WDT()       /* 250 interrupts/sec */
{
    switch (current_state) {
    case WAITING:
        state_waiting();
        break;
    case PREGAME:
        state_pregame();
        break;
    case DURINGGAME:
        state_duringgame();
        break;
    case GAMEOVER:
        state_gameover();
        break;
    default:
        break;
    }
     
}
