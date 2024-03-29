#ifndef stateMachine_included
#define stateMachine_included

// states
typedef enum {
    WAITING = 0,
    EASTEREGG,
    SECONDEASTEREGG,
    PREGAME,
    DURINGGAME,
    GAMEOVER
} State;

// function prototypes
void state_waiting();
void state_pregame();
void state_easter_egg();
void state_second_easter_egg();
void state_duringgame();
void state_gameover();
void transition(State next_state);

// external vars
extern State current_state;

#endif
