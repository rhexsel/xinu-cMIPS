/* queue.c - enqueue, dequeue */

#include <xinu.h>

struct qentry	queuetab[NQENT];	/* table of process queues	*/

/*------------------------------------------------------------------------
 *  enqueue  -  Insert a process at the tail of a queue
 *------------------------------------------------------------------------
 */
pid32	enqueue(
	  pid32		pid,		/* ID of process to insert	*/
	  qid32		q		/* ID of queue to use		*/
	)
{
	int	tail, prev;		/* tail & previous node indexes	*/

	if (isbadqid(q) || isbadpid(pid)) {
		// kprintf("\n\t err enq(%x)->%x\n",q, pid);
		return SYSERR;
	}

	tail = queuetail(q);
	prev = queuetab[tail].qprev;

	queuetab[pid].qnext  = tail;	/* insert just before tail node	*/
	queuetab[pid].qprev  = prev;
	queuetab[prev].qnext = pid;
	queuetab[tail].qprev = pid;
	// kprintf("enq(%x)->%x t %x p %x \n",q, pid, tail, prev);
	//kprintf("enq(%x)->%x  %x %x %x %x\n",q, pid, 
	//	queuetab[pid].qnext,
	//	queuetab[pid].qprev,
	//	queuetab[prev].qnext,
	//	queuetab[tail].qprev);
	return pid;
}

/*------------------------------------------------------------------------
 *  dequeue  -  Remove and return the first process on a list
 *------------------------------------------------------------------------
 */
pid32	dequeue(
	  qid32		q		/* ID queue to use		*/
	)
{
	pid32	pid;			/* ID of process removed	*/

	if (isbadqid(q)) {
		return SYSERR;
		// kprintf("\nerr bad queue %x\n\n",q);
	} else if (isempty(q)) {
	  // kprintf("\nerr deq(%x) %x empty\n",q, EMPTY);
		return EMPTY;
	}

	pid = getfirst(q);
	// kprintf("deq(%x) %x\n",q, pid);
	queuetab[pid].qprev = EMPTY;
	queuetab[pid].qnext = EMPTY;
	return pid;
}
