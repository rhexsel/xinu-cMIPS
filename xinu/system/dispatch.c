/* dispatch.c */

#include <xinu.h>
#include <mips.h>
#include <ar9130.h>

/* Initialize list of interrupts */

char *interrupts[] = {
    "Sw irq 0",
    "Sw irq 1",
    "Hw irq 0, wmac",
    "Hw irq 1, usb",
    "Hw irq 2, eth0",
    "Hw irq 3, eth1",
    "Hw irq 4, uart",
    "Hw irq 5, timer",
    "Misc irq 0, timer",
    "Misc irq 1, error",
    "Misc irq 2, gpio",
    "Misc irq 3, uart",
    "Misc irq 4, watchdog",
    "Misc irq 5, perf",
    "Misc irq 6, reserved",
    "Misc irq 7, mbox",
};

/*------------------------------------------------------------------------
 * dispatch - high-level piece of interrupt dispatcher
 *------------------------------------------------------------------------
 */

//
// Xinu-cMIPS dispatches interrupts directly at start.S;
//   this code is not used

void	dispatch(
	  int32	cause,		/* identifies interrupt cause 		*/
	  int32	*frame		/* pointer to interrupt frame that	*/
				/*  contains saved status		*/
	)
{

#if 0

	intmask	mask;		/* saved interrupt status		*/
	int32	irqcode = 0;	/* code for interrupt			*/
	int32	irqnum = -1;	/* interrupt number			*/
	void	(*handler)(void);/* address of handler function to call	*/

	// caught an exception -- print its code and go into infinite loop
	if (cause & CAUSE_EXC) exception(cause, frame);

	/* Obtain the IRQ code */

	irqcode = (cause & CAUSE_IRQ) >> CAUSE_IRQ_SHIFT;

	/* Calculate the interrupt number */

	while (irqcode) {
		irqnum++;
		irqcode = irqcode >> 1;
	}

	kprintf("Xinu Interrupt %d caught, %s\r\n", 
			irqnum, interrupts[irqnum]);

	// this is the wifi-Ethernet device
	if (IRQ_ATH_MISC == irqnum) {
		uint32 *miscStat = (uint32 *)RST_MISC_INTERRUPT_STATUS;
		irqcode = *miscStat & RST_MISC_IRQ_MASK;
		irqnum = 7;
		while (irqcode) {
			irqnum++;
			irqcode = irqcode >> 1;
		}
	}

	/* Check for registered interrupt handler */

	if ((handler = interruptVector[irqnum]) == NULL) {
		kprintf("Xinu Interrupt %d uncaught, %s\r\n",
			irqnum, interrupts[irqnum]);
		while (1) {
			;	       /* forever */
		}
	}

	mask = disable();	/* Disable interrupts for duration */

	exlreset();		/* Reset system-wide exception bit */

	(*handler) ();		/* Invoke device-specific handler  */

	exlset();		/* Set system-wide exception bit   */

	restore(mask);

#endif

}

/*------------------------------------------------------------------------
 * enable_irq - enable a specific IRQ
 *------------------------------------------------------------------------
 */

void enable_irq(
	intmask irqnumber		/* specific IRQ to enable	*/
	)
{
	int32	enable_cpuirq(int);
	int irqmisc;
	uint32 *miscMask = (uint32 *)RST_MISC_INTERRUPT_MASK;
	if (irqnumber >= 8) {
		irqmisc = irqnumber - 8;
		enable_cpuirq(IRQ_ATH_MISC);
		*miscMask |= (1 << irqmisc);
	} else {
		enable_cpuirq(irqnumber);
	}
}
