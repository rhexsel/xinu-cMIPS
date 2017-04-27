/* wait.c - wait */

#include <xinu.h>

/*------------------------------------------------------------------------
 *  wait  -  Cause current process to wait on a semaphore
 *------------------------------------------------------------------------
 */
syscall	wait(sid32 sem)			/* semaphore on which to wait  */
{
	intmask mask;			/* saved interrupt mask		*/
	struct	procent *prptr;		/* ptr to process' table entry	*/
	struct	sentry *semptr;		/* ptr to sempahore table entry	*/

	mask = disable();
	if (isbadsem(sem)) {
		restore(mask);
                // kprintf("\terr wait isbadsem %x\n",sem);
		return SYSERR;
	}

	semptr = &semtab[sem];
	if (semptr->sstate == S_FREE) {
		restore(mask);
                // kprintf("\terr wait sem free %x\n",semptr->sstate);
		return SYSERR;
	}

	// kprintf("w(%d) a %x v %x\n", sem, semptr, (semptr->scount-1));
	semptr->scount -= 1;
	if (semptr->scount < 0) {	        /* if caller must block	*/
		prptr = &proctab[currpid];
		prptr->prstate = PR_WAIT;	/* set state to waiting	*/
		prptr->prsem = sem;		/* record semaphore ID	*/
		// kprintf("w(%x) pid %x s->q(%x)\n",sem,currpid,semptr->squeue);
		enqueue(currpid,semptr->squeue);/* enqueue on semaphore	*/
		// kprintf("\tw(%x) s->(%x).n %x q.p %x\n",sem,semptr->squeue, queuetab[semptr->squeue].qnext,queuetab[semptr->squeue].qprev);
		resched();			/*   and reschedule	*/
	}

	restore(mask);
	return OK;
}
