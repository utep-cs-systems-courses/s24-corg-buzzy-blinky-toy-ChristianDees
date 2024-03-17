#ifndef buzzer_included
#define buzzer_included

// prototype functions
void buzzer_init();
void buzzer_set_period(short cycles);
void buzz_once();
void buzz_four_times();
void buzz_game_over();

// external var
extern int buzzSeconds;

#endif
