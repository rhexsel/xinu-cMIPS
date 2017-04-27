/* conf.c (GENERATED FILE; DO NOT EDIT) */

#include <xinu.h>


extern	devcall	ioerr(void);
extern	devcall	ionull(void);

/* Device independent I/O switch */

struct	dentry	devtab[NDEVS] =
{
/**
 * Format of entries is:
 * dev-number, minor-number, dev-name,
 * init, open, close,
 * read, write, seek,
 * getc, putc, control,
 * dev-csr-address, intr-handler, irq
 */

/* CONSOLE is tty */
	{ 0, 0, "CONSOLE",
	  (void *)ttyInit, (void *)ionull, (void *)ionull,
	  (void *)ttyRead, (void *)ttyWrite, (void *)ioerr,
	  (void *)ttyGetc, (void *)ttyPutc, (void *)ttyControl,
	  (void *)0x3c0000e0, (void *)ttyInterrupt, 11 },

/* NULLDEV is null */
	{ 1, 0, "NULLDEV",
	  (void *)ionull, (void *)ionull, (void *)ionull,
	  (void *)ionull, (void *)ionull, (void *)ioerr,
	  (void *)ionull, (void *)ionull, (void *)ioerr,
	  (void *)0x0, (void *)ioerr, 0 },

/* ETHER0 is null */
	{ 2, 1, "ETHER0",
	  (void *)ionull, (void *)ionull, (void *)ionull,
	  (void *)ionull, (void *)ionull, (void *)ioerr,
	  (void *)ionull, (void *)ionull, (void *)ioerr,
	  (void *)0x0, (void *)ioerr, 0 },

/* RFILESYS is null */
	{ 3, 2, "RFILESYS",
	  (void *)ionull, (void *)ionull, (void *)ionull,
	  (void *)ionull, (void *)ionull, (void *)ioerr,
	  (void *)ionull, (void *)ionull, (void *)ioerr,
	  (void *)0x0, (void *)ioerr, 0 },

/* RDISK is null */
	{ 4, 3, "RDISK",
	  (void *)ionull, (void *)ionull, (void *)ionull,
	  (void *)ionull, (void *)ionull, (void *)ioerr,
	  (void *)ionull, (void *)ionull, (void *)ioerr,
	  (void *)0x0, (void *)ioerr, 0 },

/* LFILESYS is lfs */
	{ 5, 0, "LFILESYS",
	  (void *)lfsInit, (void *)lfsOpen, (void *)ioerr,
	  (void *)ioerr, (void *)ioerr, (void *)ioerr,
	  (void *)ioerr, (void *)ioerr, (void *)ioerr,
	  (void *)0x0, (void *)ionull, 0 },

/* LFILE0 is lfl */
	{ 6, 0, "LFILE0",
	  (void *)lflInit, (void *)ioerr, (void *)lflClose,
	  (void *)lflRead, (void *)lflWrite, (void *)lflSeek,
	  (void *)lflGetc, (void *)lflPutc, (void *)lflControl,
	  (void *)0x0, (void *)ionull, 0 },

/* LFILE1 is lfl */
	{ 7, 1, "LFILE1",
	  (void *)lflInit, (void *)ioerr, (void *)lflClose,
	  (void *)lflRead, (void *)lflWrite, (void *)lflSeek,
	  (void *)lflGetc, (void *)lflPutc, (void *)lflControl,
	  (void *)0x0, (void *)ionull, 0 },

/* LFILE2 is lfl */
	{ 8, 2, "LFILE2",
	  (void *)lflInit, (void *)ioerr, (void *)lflClose,
	  (void *)lflRead, (void *)lflWrite, (void *)lflSeek,
	  (void *)lflGetc, (void *)lflPutc, (void *)lflControl,
	  (void *)0x0, (void *)ionull, 0 },

/* LFILE3 is lfl */
	{ 9, 3, "LFILE3",
	  (void *)lflInit, (void *)ioerr, (void *)lflClose,
	  (void *)lflRead, (void *)lflWrite, (void *)lflSeek,
	  (void *)lflGetc, (void *)lflPutc, (void *)lflControl,
	  (void *)0x0, (void *)ionull, 0 },

/* LFILE4 is lfl */
	{ 10, 4, "LFILE4",
	  (void *)lflInit, (void *)ioerr, (void *)lflClose,
	  (void *)lflRead, (void *)lflWrite, (void *)lflSeek,
	  (void *)lflGetc, (void *)lflPutc, (void *)lflControl,
	  (void *)0x0, (void *)ionull, 0 },

/* LFILE5 is lfl */
	{ 11, 5, "LFILE5",
	  (void *)lflInit, (void *)ioerr, (void *)lflClose,
	  (void *)lflRead, (void *)lflWrite, (void *)lflSeek,
	  (void *)lflGetc, (void *)lflPutc, (void *)lflControl,
	  (void *)0x0, (void *)ionull, 0 },

/* TESTDISK is ram */
	{ 12, 0, "TESTDISK",
	  (void *)ramInit, (void *)ramOpen, (void *)ramClose,
	  (void *)ramRead, (void *)ramWrite, (void *)ioerr,
	  (void *)ioerr, (void *)ioerr, (void *)ioerr,
	  (void *)0x0, (void *)ionull, 0 },

/* NAMESPACE is nam */
	{ 13, 0, "NAMESPACE",
	  (void *)namInit, (void *)namOpen, (void *)ioerr,
	  (void *)ioerr, (void *)ioerr, (void *)ioerr,
	  (void *)ioerr, (void *)ioerr, (void *)ioerr,
	  (void *)0x0, (void *)ioerr, 0 }
};
