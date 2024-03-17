#include <msp430.h>
#include "switches.h"
#include "led.h"
#include "stateMachines.h"


// return change based on switch interrupt in port 1
char
switch_update_interrupt_sense_1()
{
    char p1val = P1IN;
    P1IES |= (p1val & SW0);    // if switch up, sense down
    P1IES &= (p1val | ~SW0);   // if switch down, sense up
    return p1val;
}

// return change based on switch interrupt in port 2
char
switch_update_interrupt_sense_2()
{
    char p2val = P2IN;
    P2IES |= (p2val & SWITCHES);    // if switch up, sense down
    P2IES &= (p2val | ~SWITCHES);   // if switch down, sense up
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
    char p1val = switch_update_interrupt_sense_1();
    char p2val = switch_update_interrupt_sense_2();
    
    // if side button is pressed, transition to pregame state
    if (current_state == WAITING){
        if (!(p1val & SW0)) {
            updatePreGame();
        }
    }
    // set button value to 1 if pressed
    char button1 = (p2val & SW1) ? 0 : 1;
    char button2 = (p2val & SW2) ? 0 : 1;
    char button3 = (p2val & SW3) ? 0 : 1;
    char button4 = (p2val & SW4) ? 0 : 1;
    if (current_state == DURINGGAME){
        // if button is pressed, check if answer is correct
        // if answer does not match current output, exit the game
        if (button1) {
            if ((random_led) != 1)
                updateGameOver();
        } else if (button2) {
            if ((random_led) != 2)
                updateGameOver();
        } else if (button3) {
            if ((random_led) != 3)
                updateGameOver();
        } else if (button4) {
            if ((random_led) != 4)
                updateGameOver();
        }
    }
}


