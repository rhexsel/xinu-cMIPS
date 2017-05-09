/* kprintf.c -  kputc, kgetc, kprintf */

#include <xinu.h>
#include <stdarg.h>

/*------------------------------------------------------------------------
 * kputc - use polled I/O to write a character to the console serial line
 *------------------------------------------------------------------------
 */
syscall kputc(byte c)
{

#if 0 

    int status, irmask;
    volatile struct uart_csreg *regptr;
    struct dentry *devptr;

    devptr = (struct dentry *) &devtab[CONSOLE];
    regptr = (struct uart_csreg *)devptr->dvcsr;

    irmask = regptr->ier;       /* Save UART interrupt state.   */
    regptr->ier = 0;            /* Disable UART interrupts.     */

    do                          /* Wait for transmitter         */
    {
        status = regptr->lsr;
    }
    while ((status & UART_LSR_TEMT) != UART_LSR_TEMT);

    /* Send character. */
    regptr->thr = c;

    regptr->ier = irmask;       /* Restore UART interrupts.     */

#endif

#if 0
  int *IO = (int *)IO_STDOUT_ADDR;
   // prints line only after receiving a '\0' or a '\n' (line-feed, 0x0a)
  *IO = (unsigned int)c;
#else
  // ### esta versao provoca estrago na pilha; nao sei o por que!  RH
  to_stdout(c); // write to simulator's standard output DEBUG
#endif

    return c;
}

/*------------------------------------------------------------------------
 * kgetc - use polled I/O to read a character from the console serial line
 *------------------------------------------------------------------------
 */
syscall kgetc(void)
{
  volatile struct uart_csreg *regptr;
  byte   c;
  struct dentry	*devptr;
  int    irmask, off;

  devptr = (struct dentry *) &devtab[CONSOLE];
  regptr = (struct uart_csreg *)devptr->dvcsr;

  irmask = regptr->ctl;         /* Save UART interrupt state.   */
  off = irmask & ~UART_CTL_intTX & UART_CTL_intRX;
  regptr->ctl = off;            /* Disable UART interrupts.     */

  while ( 0 == (regptr->stat & UART_STA_rxFull) ) {
    // Do Nothing
  }

  /* read character from data register */
  c = regptr->data;
  regptr->ctl = irmask;        /* Restore UART interrupts.     */
  return c;
}

extern	void	_doprnt(char *, int (*)(int), ...);

/*------------------------------------------------------------------------
 *  kprintf - kernel printf using unbuffered, polled output to CONSOLE
 *------------------------------------------------------------------------
 */
syscall kprintf(char *fmt, ...)
{
  va_list ap;

  va_start(ap, fmt);
  _doprnt(fmt, ap, (int (*)(int))kputc, (int)&devtab[CONSOLE]); 
  va_end(ap);
  return OK;
}
