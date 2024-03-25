#ifndef buzzer_included
#define buzzer_included

// prototype functions
void buzzer_init();
void buzzer_set_period(short cycles);
void buzz_once();
void buzz_four_times();
void buzz_game_over();
void mario_buzzer();

// external vars
extern int buzz_seconds;
extern char buzz_second_count;
extern char buzz_changes;
extern int buzz_speed_main;
extern char buzz_speed_quarter;

#endif
