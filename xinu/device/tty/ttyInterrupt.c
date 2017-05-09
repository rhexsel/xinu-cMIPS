/* ttyInterrupt.c - ttyInterrupt */

#include <xinu.h>

/*------------------------------------------------------------------------
 *  ttyInterrupt - handle an interrupt for a tty (serial) device
 *------------------------------------------------------------------------
 */
interrupt ttyInterrupt(void)
{
  struct	dentry	*devptr;	/* pointer to devtab entry	*/
  struct	ttycblk	*typtr;		/* pointer to ttytab entry	*/	
  struct	uart_csreg *uptr;	/* address of UART's CSRs	*/
  int    	iir;	                /* interrupt identification	*/

  /* For now, the CONSOLE is the only serial device */

  devptr = (struct dentry *)&devtab[CONSOLE];

  /* Obtain the CSR address for the UART */

  uptr = (struct uart_csreg *)devptr->dvcsr;

  /* Obtain a pointer to the tty control block */

  typtr = &ttytab[ devptr->dvminor ];

  /* Decode hardware interrupt request from UART device */

  /* Check interrupt identification register */

  iir = uptr->stat;

  /* Decode the interrupt cause based upon the value extracted	*/
  /* from the UART interrupt identification register.  Clear	*/
  /* the interrupt source and perform the appropriate handling	*/
  /* to coordinate with the upper half of the driver		*/

  // Receiver data available
  if ( (iir & UART_STA_rxFull) != 0 ) {
    uptr->interr = UART_INT_clrRX;    // clear interrupt request
    ttyInter_in(typtr, uptr);         // get new char
  }

  // Transmitter output FIFO is empty (i.e., ready for more)	*/
  if ( (iir & UART_STA_txEmpty) != 0 ) {
    uptr->interr = UART_INT_clrTX;    // clear interrupt request
    ttyInter_out(typtr, uptr);
  }

  return;

}
