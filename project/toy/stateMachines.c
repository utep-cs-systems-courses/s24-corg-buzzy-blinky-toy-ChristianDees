#include <msp430.h>
#include "stateMachines.h"
#include "led.h"
#include "buzzer.h"

// default current state to waiting state
State current_state = WAITING;

// waiting state: dim leds
void state_waiting() {
    dtb_btd();
}

// pregame state: countdown
void state_pregame() {
    buzz_four_times();
    blink_four_times();
}

// during game state: change leds
void state_duringgame() {
    buzz_once();
    led_game();
}

// during game over: blink/buzz twice
void state_gameover(){
    buzz_game_over();
    led_game_over();
}

// transition to next state
void transition(State next_state) {
    current_state = next_state;
    
}
