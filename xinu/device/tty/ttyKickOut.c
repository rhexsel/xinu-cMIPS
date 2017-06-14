/* ttyKickOut.c - ttyKickOut */

#include <xinu.h>

/*------------------------------------------------------------------------
 *  ttyKickOut - "kick" the hardware for a tty device, causing it to
 *		generate an output interrupt (interrupts disabled)
 *------------------------------------------------------------------------
 */
void	ttyKickOut(
	 struct	ttycblk	*typtr,		/* ptr to ttytab entry		*/
	 struct uart_csreg *uptr	/* address of UART's CSRs	*/
	)
{
  volatile struct uart_csreg *u;

  u = uptr;	                       /* address of UART's CSRs	*/

  /* Set output interrupts on the UART */

  u->interr.i = u->interr.i | UART_INT_progTX;

  /*  if device is idle, generate an output interrupt    */

  if ( (u->stat.i & UART_STA_txEmpty) != 0) {
    u->interr.i = u->interr.i | UART_INT_setTX;
  }

  return;
}
