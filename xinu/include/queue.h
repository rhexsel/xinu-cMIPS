/* queue.h - firstid, firstkey, isempty, lastkey, nonempty		*/

/* Queue structure declarations, constants, and inline functions	*/

/* Default # of queue entries: 1 per process plus 2 for ready list plus	*/
/*			2 for sleep list plus 2 per semaphore		*/
#ifndef NQENT
#define NQENT	(NPROC + 4 + NSEM + NSEM)
#endif

#define	EMPTY	(-1)		/* null value for qnext or qprev index	*/
#define	MAXKEY	0x7FFFFFFF	/* max key that can be stored in queue	*/
#define	MINKEY	0x80000000	/* min key that can be stored in queue	*/

struct	qentry	{		/* one per process plus two per list	*/
	int32	qkey;		/* key on which the queue is ordered	*/
	qid32	qnext;		/* index of next process or tail	*/
	qid32	qprev;		/* index of previous process or head	*/
};

extern	struct qentry	queuetab[];

/* Inline queue manipulation functions */

#define	queuehead(q)	(q)
#define	queuetail(q)	((q) + 1)
#define	firstid(q)	(queuetab[queuehead(q)].qnext)
#define	lastid(q)	(queuetab[queuetail(q)].qprev)
#define	isempty(q)	(firstid(q) >= NPROC)
#define	nonempty(q)	(firstid(q) <  NPROC)
#define	firstkey(q)	(queuetab[firstid(q)].qkey)
#define	lastkey(q)	(queuetab[ lastid(q)].qkey)

/* Inline to check queue id assumes interrupts are disabled */

#define	isbadqid(x)	(((int32)(x) < 0) || (int32)(x) >= NQENT-1)

/* Queue function prototypes */

pid32	getfirst(qid32);
pid32	getlast(qid32);
pid32	getitem(pid32);
pid32	enqueue(pid32, qid32);
pid32	dequeue(qid32);
status	insert(pid32, qid32, int);
status	insertd(pid32, qid32, int);
qid32	newqueue(void);
