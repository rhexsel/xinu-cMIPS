/* initialize.c - nulluser, sysinit */

/* Handle system initialization and become the null process */

#include <xinu.h>
#include <string.h>

extern	void	_start(void);	/* start of Xinu code */
extern	void	*_end;		/* top of Xinu memory */
extern	void	*_edata;	/* end of Xinu data   */
extern	void	*_etext;	/* end of Xinu code   */

/* Function prototypes */

extern	void main(void);	/* main is the first process created	*/
extern	void xdone(void);	/* system "shutdown" procedure		*/
static	void sysinit(void);	/* initializes system structures	*/

/* Declarations of major kernel variables */

struct	procent	proctab[NPROC];	/* Process table			*/
struct	sentry	semtab[NSEM];	/* Semaphore table			*/
struct	memblk	memlist;	/* List of free memory blocks		*/

/* Active system status */

int	prcount;		/* Total number of live processes	*/
pid32	currpid;		/* ID of currently executing process	*/
extern  pid32 nextpid;	        /* position in table to try or	        */
			        /*  one beyond end of table             */
                                /*   changed to global RH */


/* Memory bounds set by start.S */

void	*minheap;		/* start of heap			*/
void	*maxheap;		/* highest valid memory address		*/

extern sid32 nextsem;           /* next semaphore to use, changed RH    */

extern qid32 nextqid;           /* next list in queuetab to use, changed RH*/


/*------------------------------------------------------------------------
 * nulluser - initialize the system and become the null process
 *
 * Note: execution begins here after the C run-time environment has been
 * established.  Interrupts are initially DISABLED, and must eventually
 * be enabled explicitly.  The code turns itself into the null process
 * after initialization.  Because it must always remain ready to execute,
 * the null process cannot execute code that might cause it to be
 * suspended, wait for a semaphore, put to sleep, or exit.  In
 * particular, the code must not perform I/O except for polled versions
 * such as kprintf.
 *------------------------------------------------------------------------
 */

void	nulluser(void) {
        kprintf("\n%s\n\n", VERSION);

	sysinit();
	

	/* Output Xinu memory layout */

#if 0
	kprintf("%10d bytes physical memory.\r\n",
		// (uint32)maxheap - (uint32)addressp2k(x_DATA_BASE_ADDR));
		(uint32)maxheap - (uint32)x_DATA_BASE_ADDR);
	kprintf("           [0x%08X to 0x%08X]\r\n",
		// (uint32)addressp2k(x_DATA_BASE_ADDR), (uint32)maxheap - 1);
		(uint32)x_DATA_BASE_ADDR, (uint32)maxheap - 1);

	kprintf("%10d bytes reserved system area.\r\n",
		// (uint32)_start - (uint32)addressp2k(0));
		(uint32)_start - (uint32)(0));
	kprintf("           [0x%08X to 0x%08X]\r\n",
		// (uint32)addressp2k(0), (uint32)_start - 1);
		(uint32)(0), (uint32)_start - 1);

	kprintf("%10d bytes Xinu code.\r\n",
		(uint32)&_etext - (uint32)_start);
	kprintf("           [0x%08X to 0x%08X]\r\n",
		(uint32)_start, (uint32)&_etext - 1);

	kprintf("%10d bytes stack space.\r\n",
		(uint32)minheap - (uint32)&_end);
	kprintf("           [0x%08X to 0x%08X]\r\n",
		(uint32)&_end, (uint32)minheap - 1);

	kprintf("%10d bytes heap space.\r\n",
		(uint32)maxheap - (uint32)minheap);
	kprintf("           [0x%08X to 0x%08X]\r\n\r\n",
		(uint32)minheap, (uint32)maxheap - 1);

#endif

	/* Enable interrupts */

	enable();

	//TESTE $$$$$$$$$$$$$$$$$$$$$$$
	// kprintf("Total number of live processes: %d\n\r\n",prcount);

	/* Create a process to execute function main() */

	resume(create
          ((void *)main, INITSTK, INITPRIO, "main", 0, NULL));

	/* Become the Null process (i.e., guarantee that the CPU has	*/
	/*  something to run when no other process is ready to execute)	*/

	while (TRUE) {
		;		/* do nothing */
	}
}

/*------------------------------------------------------------------------
 *
 * sysinit - intialize all Xinu data structures and devices
 *
 *------------------------------------------------------------------------
 */

static	void	sysinit(void)
{
	int32	i;
	struct	procent	*prptr;		/* ptr to process table entry	*/
	struct	sentry	*semptr;	/* prr to semaphore table entry	*/
	struct	memblk	*memptr;	/* ptr to memory block		*/

	/* Initialize system variables */

	/* Count the Null process as the first process in the system */

	prcount = 1;

	/* Scheduling is not currently blocked */

	Defer.ndefers = 0;

	/* Initialize the free memory list */

	// maxheap = (void *)addressp2k(MAXADDR);
	maxheap = (void *)(MAXADDR);

	memlist.mnext = (struct memblk *)minheap;

	/* Overlay memblk structure on free memory and set fields */

	memptr = (struct memblk *)minheap;
	memptr->mnext = NULL;
	memptr->mlength = memlist.mlength = (uint32)(maxheap - minheap);


#if 1
	for (i = 0; i < NQENT; i+=1) {
	  queuetab[i].qnext = EMPTY;
	  queuetab[i].qprev = EMPTY;
	  queuetab[i].qkey  = MINKEY;
	  // kprintf("q %x[%x] %x %x\n", &(queuetab[i]), i, queuetab[i].qnext, queuetab[i].qprev );
	}
#endif

	/* Initialize process table entries free */

	for (i = 0; i < NPROC; i++) {
		prptr = &proctab[i];
		prptr->prstate = PR_FREE;
		prptr->prname[0] = NULLCH;
		prptr->prstkbase = NULL;
		prptr->prprio = 0;
	}

	/* Initialize the Null process entry */

	prptr = &proctab[NULLPROC];
	prptr->prstate = PR_CURR;
	prptr->prprio = 0;
	strncpy(prptr->prname, "prnull", 7);
	prptr->prstkbase = minheap;
	prptr->prstklen = NULLSTK;
	prptr->prstkptr = 0;
	currpid = NULLPROC;

	nextpid = 1;                    // changed to global variable RH

	/* Initialize semaphores */
	nextqid = NPROC;                // changed to global variable RH
	nextsem = 0;                    // changed to global variable RH

	for (i = 0; i < NSEM; i++) {
		semptr = &semtab[i];
		semptr->sstate = S_FREE;
		semptr->scount = 0;
		semptr->squeue = newqueue();
		// kprintf("s[%x].q %x\n",i,semptr->squeue);
	}

	/* Initialize buffer pools */

	bufinit();

	/* Create a ready list for processes */

        readylist = newqueue();
	// kprintf("rdyq %x\n",readylist);

	/* Initialize real time clock */

	clkinit();

	/* Initialize non-volative RAM storage */

	// nvramInit(); // CHANGE

	/* Initialize devices */

	for (i = 0; i < NDEVS; i++) {
	  init(i);
	}

	return;

}
