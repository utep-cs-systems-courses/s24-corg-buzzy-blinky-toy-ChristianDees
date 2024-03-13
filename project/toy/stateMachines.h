#ifndef stateMachine_included
#define stateMachine_included
// Define states
typedef enum {
    WAITING,
    PREGAME,
    DURINGGAME,
    GAMEOVER
} State;

// Define function prototypes
void state_waiting();
void state_pregame();
void state_duringgame();
void state_gameover();
void transition(State next_state);
extern State current_state;

#endif // included
