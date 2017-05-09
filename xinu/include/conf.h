/* conf.h (GENERATED FILE; DO NOT EDIT) */

/* Device switch table declarations */

/* Device table entry */
struct	dentry	{
	int32   dvnum;
	int32   dvminor;
	char    *dvname;
	devcall (*dvinit) (struct dentry *);
	devcall (*dvopen) (struct dentry *, char *, char *);
	devcall (*dvclose)(struct dentry *);
	devcall (*dvread) (struct dentry *, void *, uint32);
	devcall (*dvwrite)(struct dentry *, void *, uint32);
	devcall (*dvseek) (struct dentry *, int32);
	devcall (*dvgetc) (struct dentry *);
	devcall (*dvputc) (struct dentry *, char);
	devcall (*dvcntl) (struct dentry *, int32, int32, int32);
	void    *dvcsr;
	void    (*dvintr)(void);
	byte    dvirq;
};

extern	struct	dentry	devtab[]; /* one entry per device */

/* Device name definitions */

#define CONSOLE     0       /* type tty      */
#define NULLDEV     1       /* type null     */
#define ETHER0      2       /* type null     */
#define RFILESYS    3       /* type null     */
#define RDISK       4       /* type null     */
#define LFILESYS    5       /* type null     */
#define TESTDISK    6       /* type null     */
#define NAMESPACE   7       /* type null     */

/* Control block sizes */

#define	Nnull	7
#define	Ntty	1

#define DEVMAXNAME 24
#define NDEVS 8


/* Configuration and Size Constants */

// these come from include/cMIPS.h
// #define x_IO_BASE_ADDR   0x3c000000
// #define x_IO_ADDR_RANGE  0x00000020
// #define IO_UART_ADDR    (x_IO_BASE_ADDR + 7 * x_IO_ADDR_RANGE);

#define Neth 0	     /* eth = null */
// #define Neth 1	     /* eth = null */


#define	NPROC	     16	  	/* number of user processes		*/
#define	NSEM	     32		/* number of semaphores			*/
#define	IRQ_TIMER    IRQ_HW5	/* timer IRQ is wired to hardware 5	*/
#define	IRQ_ATH_MISC IRQ_HW3	/* Misc. IRQ is wired to hardware 3(4)	*/
#define MAXADDR      0x00080000	/* 256 KB of RAM			*/
#define CLKFREQ      50000000	/* 50 MHz clock				*/
#define FLASH_BASE   0xBD000000	/* Flash ROM device			*/

#define	LF_DISK_DEV	TESTDISK
