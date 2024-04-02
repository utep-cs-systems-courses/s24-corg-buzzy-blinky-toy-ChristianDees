# Blink 'n' Press

## Description
Blink 'n' Press is a program for the MSP430 that transforms the microcontroller into an engaging and interactive game designed to test the user's reaction speed.

## How to Play
To begin, press the side button. The red LED flashes three times and the green LED once, signaling the game's start. LEDs randomly toggle with a buzzer sound, gradually increasing in tempo. Players must react swiftly, pressing the corresponding button. An incorrect answer prompts a red LED flash, resetting the game for another attempt.

Button  | Answer
------- | -----------
1       | Only green LED is on
2       | Only red LED is on
3       | Both LEDs are on
4       | Both LEDs are off


## Compilation Instructions
The Makefile in the project directory builds the toy program and timer library using **make all**. To load the program onto the MSP430, use **make load** in the toy directory. Clean both directories with **make clean** in the project directory.

```bash
make all
cd toy/
make load
cd ..
make clean
```

## Easter Eggs
There are two easter eggs:
1. Double press the side button
2. Hold the side button for three seconds

## Compatibility
This program is built to be compatible with the MSP430Gxxx series chips, partnered with the Educational BoosterPack found [here](https://www.tindie.com/products/robg/educational-boosterpack-service/). As most of the program is written in assembly, board-specific features are required for this game to work.
