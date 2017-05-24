/* xdone.c - xdone */

#include <xinu.h>

/*------------------------------------------------------------------------
 *  xdone  -  Print system completion message as last thread exits
 *------------------------------------------------------------------------
 */
void	xdone(void)
{
	kprintf("\r\n\r\nAll user processes have completed.\r\n\r\n");

	// there are no leds in the simulator  :(
	// gpioLEDOff(GPIO_LED_CISCOWHT);/* turn off LED "run" light  RH */

	halt();				/* halt the processor		*/
}
