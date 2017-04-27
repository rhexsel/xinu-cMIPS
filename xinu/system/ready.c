/* ready.c - ready */

#include <xinu.h>

qid32	readylist;			/* index of ready list		*/

/*------------------------------------------------------------------------
 *  ready  -  Make a process eligible for CPU service
 *------------------------------------------------------------------------
 */
status	ready(
	  pid32		pid,		/* ID of process to make ready	*/
	  int32		resch		/* reschedule afterward?	*/
	)
{
	register struct procent *prptr;

	if (isbadpid(pid)) {
		return(SYSERR);
	}

	/* Set process state to indicate ready and add to ready list */

	prptr = &proctab[pid];
	prptr->prstate = PR_READY;
	insert(pid, readylist, prptr->prprio);

	if (resch == RESCHED_YES) {
		resched();
	}
	return OK;
}
