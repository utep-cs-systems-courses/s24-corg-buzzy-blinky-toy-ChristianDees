#include "libTimer.h"
#include "led.h"
#include "switches.h"

void main(void)
{
  configureClocks();
  enableWDTInterrupts();
  switch_init();
  led_init();
  or_sr(0x18);  // CPU off, GIE on
}
