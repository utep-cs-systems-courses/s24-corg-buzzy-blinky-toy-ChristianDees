#include <msp430.h>
#include "libTimer.h"
#include <stdlib.h>     // required for srand

// initialize analog to digital converter
void adc_init() {
    // configure ADC input
    P1DIR &= ~BIT1; // clears bit one
    P1SEL |= BIT1;  // set bit to port 1 select register
                    // makes pin configured for a "special function"
    // ADC10CTL0 -> ADC + 10 bit converesions + control 0 register
    // ADC10SHT_0 set sample hold time to 4 ADC10CLK cycles
    // ADC10ON sets ADC module on
    // 4 clock cycles for it to quickly convert the voltage to a digital value
    // 4 clock cycles as accuracy doesn't matter for this case
    ADC10CTL0 = ADC10SHT_0 + ADC10ON;
    ADC10CTL1 = INCH_1; // specify analog input channel to A1/bit 1
}

int random_int_generator() {
    // ENC -> enable ADC conversion + set ADC10SC bit to start conversion
    ADC10CTL0 |= ENC + ADC10SC;

    // wait for conversion to finish
    // once finished, ADC10BUSY is cleared and end loop
    // ADC10BUSY = flag indicating if ADC is busy converting a signal
    while (ADC10CTL1 & ADC10BUSY);

    // use A1 as seed for a random number each boot
    // ADC10MEM = ADC memory register: holds result of ADC conversion
    // uses a different seed every time it boots as voltage is different
    srand(ADC10MEM);

    // generate random number between 1 and 4, inclusive
    return (rand()% 4) + 1;
}
