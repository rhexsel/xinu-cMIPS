/* signal.c - signal */

#include <xinu.h>

/*------------------------------------------------------------------------
 *  signal  -  Signal a semaphore, releasing a process if one is waiting
 *------------------------------------------------------------------------
 */
syscall	signal(sid32 sem)		/* id of semaphore to signal	*/
{
        intmask mask;                   /* saved interrupt mask               */
        struct  sentry *semptr;         /* ptr to sempahore table entry       */
	pid32   pid;

        mask = disable();
        if (isbadsem(sem)) {
                restore(mask);
		// kprintf("\nerr isbadsem %x\n\n",sem);
                return SYSERR;
        }
        semptr= &semtab[sem];
        if (semptr->sstate == S_FREE) {
                restore(mask);
		// kprintf("\nerr not free %x\n\n",semptr->sstate);
                return SYSERR;
        }
        // kprintf("s(%x) a %x v %x\n", sem, semptr, semptr->scount);
        if ((semptr->scount++) < 0) {   /* release a waiting process */
	        //ready(dequeue(semptr->squeue), RESCHED_YES);
	  pid = dequeue(semptr->squeue);
	  if (pid == SYSERR)
                kprintf("\n\terr dequeue q(%x)=%x\n\n",semptr->squeue,pid);
	  ready(pid, RESCHED_YES);
        }
        restore(mask);

#if 0
  intmask mask;				/* saved interrupt mask		*/
  struct  sentry *semptr;		/* ptr to sempahore table entry	*/
  
  mask = disable();
  if (isbadsem(sem)) {
    restore(mask);
    return SYSERR;
  }
  semptr= &semtab[sem];
  if (semptr->sstate == S_FREE) {
    restore(mask);
    return SYSERR;
  }
  kprintf("s(%x) a %x v %x\n", sem, semptr, semptr->scount);
  if (semptr->scount < 0) {	/* release a waiting process */
    int pid;
    pid = dequeue(semptr->squeue);
    kprintf("s pid %x s->q %x= %x\n", currpid, semptr->squeue, pid);
    ready(pid, RESCHED_YES);
    //ready(dequeue(semptr->squeue), RESCHED_YES);
  }
  semptr->scount += 1;
  restore(mask);
#endif

  return OK;
}
