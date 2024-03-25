#include <msp430.h>
#include "switches.h"
#include "led.h"
#include "stateMachines.h"


// return change based on switch interrupt in port 1
// configure port 1 interrupt edge select
char
switch_update_interrupt_sense_1()
{
    char p1val = P1IN;
    P1IES |= (p1val & SW0);       // activate interrupt if low to high (rising edge)
    P1IES &= (p1val | ~SW0);      // activate interrupt if high to low (falling edge)
    return p1val;
}

// return change based on switch interrupt in port 2
// configure port 2 interrupt edge select
char
switch_update_interrupt_sense_2()
{
    char p2val = P2IN;
    P2IES |= (p2val & SWITCHES);  // activate interrupt if low to high (rising edge)
    return p2val;
}

// initialize switches
void
switch_init()
{
    // port 1 switch setup
    P1REN |= SW0;        // enables resistors for side button
    P1IE |= SW0;         // enable interrupts from side button
    P1OUT |= SW0;        // pull-ups for side button
    P1DIR &= ~SW0;       // set side button's bits for input
    
    // port 2 switch setup
    P2REN |= SWITCHES;   // enables resistors for main buttons
    P2IE |= SWITCHES;    // enable interrupts from main buttons
    P2OUT |= SWITCHES;   // pull-ups for main buttons
    P2DIR &= ~SWITCHES;  // set main button's bits for input
}

// switch handler
void
switch_interrupt_handler()
{
    // store values of current state of switches
    char p1val = switch_update_interrupt_sense_1();
    char p2val = switch_update_interrupt_sense_2();
    
    // if side button is pressed, transition to pregame state
    if (current_state == WAITING){
        if (!(p1val & SW0)) {
            easter_egg = 1;
        } else {
            
            update_pre_game();
        }
    }
    // set button value to 1 if pressed
    char button1 = (p2val & SW1) ? 0 : 1;
    char button2 = (p2val & SW2) ? 0 : 1;
    char button3 = (p2val & SW3) ? 0 : 1;
    char button4 = (p2val & SW4) ? 0 : 1;
    if (current_state == DURINGGAME){
        // if any button is pressed, set button flag on
        if (button1 | button2 | button3 | button4)
            button_flag = 1;
        // if button is pressed, check if answer is correct
        // if answer does not match current output, exit the game
        if (button1) {
            if ((random_led) != 1)
                update_game_over();
        } else if (button2) {
            if ((random_led) != 2)
                update_game_over();
        } else if (button3) {
            if ((random_led) != 3)
                update_game_over();
        } else if (button4) {
            if ((random_led) != 4)
                update_game_over();
        }
    }
}
