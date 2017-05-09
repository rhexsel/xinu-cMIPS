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
  Tcontrol c;
  Tstatus  s;
  Tinterr  i;

  /* Set output interrupts on the UART */
  
  c.rts   = 1;
  c.intTX = 1;
  c.intRX = 1;
  c.speed = UART_SPEED;

  uptr->ctl = c;

  /*  if device is idle, generate an output interrupt    */
  s = uptr->stat;
  if (s.txEmpty == 1) {
    i.setTX = 1;
    uptr->interr = i;  
  }

  return;
}
