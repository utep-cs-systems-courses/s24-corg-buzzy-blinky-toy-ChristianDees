## Description
This directory contains a toy program for the MSP430 that demonstrates basic I/O using a timer, interrupts, and incorporates a buzzer and LEDs as outputs, along with one side button and four main buttons for input switches. This program also contains one file controlling the LED output and state transition for once the game is over, in assembly. 

## How to Play

The toy program is a game intended to entertain the player by testing their reaction speed. The game begins in a waiting state, during which there is a light show of the green LED starting dim and becoming brighter, while the red LED starts bright and gradually gets dimmer. To play the game, press the side button (P1.3). The game will then have a countdown, with the red LED flashing red along with synchronized buzzing until it plays a higher-pitched tone along with the green LED, indicating the game has begun. Once the game has started, randomly, the LEDs will either only be green, only be red, have both LEDs on, or have both LEDs off. As the LEDs change, a buzzer sound will occur, indicating the change in LEDs. The LEDs will progressively get faster, with six total levels, every three LED changes, to test the player's limit. The player must press the respective button to indicate which LEDs are on. If the player enters an incorrect answer or doesn't press any button, for example, pressing button 4 when only green is on, then the red LED will flash twice along with a buzzer sound, indicating the game is over, and it will return to the waiting state, ready to be played again.
Button  | Answer
------- | -----------
1       | Only green LED is on
2       | Only red LED is on
3       | Both LEDs are on
4       | Both LEDs are off


## Compilation Instructions

The Makefile in this direcory (the project directory) contains rules to run the Makefile in within the toy directory. Use **make all** in this directory to build the toy program and the timer library. Once the program is built, you can load the program onto the MSP430 by changing into the toy directory and using **make load**.

