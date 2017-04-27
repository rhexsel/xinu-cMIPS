/* newqueue.c - newqueue */

#include <xinu.h>

qid32 nextqid;   /* next list in queuetab to use, changed to global RH*/

/*------------------------------------------------------------------------
 *  newqueue  -  Allocate and initialize a queue in the global queue table
 *------------------------------------------------------------------------
 */
qid32	newqueue(void)
{
	qid32		q;		/* ID of allocated queue 	*/

	q = nextqid;
	if (q > NQENT) {		/* check for table overflow	*/
		return SYSERR;
	}

	nextqid += 2;			/* increment index for next call*/

	/* initialize head and tail nodes to form an empty queue */

	queuetab[queuehead(q)].qnext = queuetail(q);
	queuetab[queuehead(q)].qprev = EMPTY;
	queuetab[queuehead(q)].qkey  = MAXKEY;
	queuetab[queuetail(q)].qnext = EMPTY;
	queuetab[queuetail(q)].qprev = queuehead(q);
	queuetab[queuetail(q)].qkey  = MINKEY;
	return q;
}
