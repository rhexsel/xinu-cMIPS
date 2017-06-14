/* clkinit.c */

#include <xinu.h>
#include <interrupt.h>
#include <clock.h>

uint32	clkticks = 0;		/* ticks per second 			*/
uint32	clktime = 0;		/* current time in seconds		*/
qid32	sleepq;			/* queue of sleeping processes		*/
uint32	preempt;		/* preemption counter			*/

/*------------------------------------------------------------------------
 * clkinit - initialize the clock and sleep queue at startup
 *------------------------------------------------------------------------
 */
void clkinit(void) {
	preempt = QUANTUM+1;	/* set time slice for process	        */
	
	sleepq = newqueue();	/* allocate a queue to hold the delta	*/
				/* list of sleeping processes		*/

	clkticks = 0;		/* start counting one second		*/

	clktime  = 0;           // current time is zero

	/* Add clock interrupt handler to interrupt vector array */

	// interruptVector[IRQ_TIMER] = &clkhandler;

	/* Enable clock interrupts */

	enable_irq(IRQ_TIMER);

	/* Start interval timer */

	clkupdate(CLKCYCS_PER_TICK);
}
