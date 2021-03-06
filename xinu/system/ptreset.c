/* ptreset.c - ptreset */

#include <xinu.h>

/*------------------------------------------------------------------------
 *  ptreset  --  reset a port, freeing waiting processes and messages and
			leaving the port ready for further use
 *------------------------------------------------------------------------
 */
syscall	ptreset(
	  int32		portid,		/* ID of port to reset		*/
	  int32		(*dispose)(int32)/* function to call to dispose	*/
	)				/*   of waiting messages	*/
{
	intmask	mask;			/* saved interrupt mask		*/
	struct	ptentry	*ptptr;		/* pointer to port table entry	*/

	mask = disable();
	if ( isbadport(portid) ||
	     (ptptr= &porttab[portid])->ptstate != PT_ALLOC ) {
		restore(mask);
		return SYSERR;
	}
	_ptclear(ptptr, PT_ALLOC, dispose);
	restore(mask);
	return OK;
}
