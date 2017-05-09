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

  /* Set output interrupts on the UART */

  uptr->ctl = UART_CTL_RTS | UART_CTL_intTX | UART_CTL_intRX | UART_SPEED;

  /*  if device is idle, generate an output interrupt    */
  ;
  if ( (uptr->stat & UART_STA_txEmpty) != 0) {
    uptr->interr = UART_INT_setTX;
  }

  return;
}
