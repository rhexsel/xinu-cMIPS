/* clock.h */

// #define CLKTICKS_PER_SEC  1000	/* clock timer resolution	*/
#define CLKTICKS_PER_SEC  4	/* only for testing		        */
// #define CLKCYCS_PER_TICK 50000 // 50MHz 200000
#define CLKCYCS_PER_TICK  5000 // 2500 // only for testing

extern	uint32	clkticks;	/* counts clock interrupts		*/
extern	uint32	clktime;	/* current time in secs since boot	*/

extern	qid32	sleepq;		/* queue for sleeping processes		*/
extern	uint32	preempt;	/* preemption counter			*/

extern	void	clkupdate(uint32);
