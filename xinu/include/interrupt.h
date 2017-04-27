/* interrupt.h */

// #define z_DATA_BASE_ADDR 0x00040000

/* Address of interrupt request handler.                          */
// #define IRQ_ADDR      0x80000180  # CHANGE
// see vhdl/packageMemory.vhd for addresses
#define IRQ_ADDR      0x00000400

// these are defined in system/start.S

/* Address of Xinu-defined trap (exception) vector.               */
// #define TRAPVEC_ADDR  0x80001000
// #define TRAPVEC_ADDR  (z_DATA_BASE_ADDR + 0x0000)

/* Address of Xinu-defined interrupt request vector.              */
//#define	IRQVEC_ADDR	0x80001080
// #define	IRQVEC_ADDR  (z_DATA_BASE_ADDR + 0x0080)

/* Address of end of Xinu-defined interrupt tables.               */
// #define IRQVEC_END    0x800010C0
// #define IRQVEC_END  (z_DATA_BASE_ADDR + 0x0080 + 0x0040)


#ifndef __ASSEMBLER__

/**
 * Definitions to allow C array manipulation of vectors.
 * The cast below makes the following a pointer to a table of
 * pointers to functions which take no parameters (void) and return
 * nothing (void).
 */
// #define exceptionVector ((void (**)(void))TRAPVEC_ADDR)
// #define interruptVector ((void (**)(void))IRQVEC_ADDR)

extern void *exceptionVector[0x0080];
extern void *interruptVector[0x0040];

/* Interrupt enabling function prototypes */
extern	void enable_irq(intmask);
extern	void exlreset(void);
extern	void exlset(void);

#endif                          /* __ASSEMBLER__ */

/* Indices for interrupt request vector.                           */
#define IRQ_SW0       0
#define IRQ_SW1       1
#define IRQ_HW0       2
#define IRQ_HW1       3
#define IRQ_HW2       4
#define IRQ_HW3       5
#define IRQ_HW4       6
#define IRQ_HW5       7

/* Offsets for the MIPS interrupt context record.                  */
#define IRQREC_ZER    16
#define IRQREC_AT     20
#define IRQREC_V0     24
#define IRQREC_V1     28
#define IRQREC_A0     32
#define IRQREC_A1     36
#define IRQREC_A2     40
#define IRQREC_A3     44
#define IRQREC_T0     48
#define IRQREC_T1     52
#define IRQREC_T2     56
#define IRQREC_T3     60
#define IRQREC_T4     64
#define IRQREC_T5     68
#define IRQREC_T6     72
#define IRQREC_T7     76
#define IRQREC_S0     80
#define IRQREC_S1     84
#define IRQREC_S2     88
#define IRQREC_S3     92
#define IRQREC_S4     96
#define IRQREC_S5     100
#define IRQREC_S6     104
#define IRQREC_S7     108
#define IRQREC_T8     112
#define IRQREC_T9     116
#define IRQREC_K0     120
#define IRQREC_K1     124
#define IRQREC_S8     128
#define IRQREC_SP     132
#define IRQREC_S9     136
#define IRQREC_RA     140
#define IRQREC_LO     144
#define IRQREC_HI     148
#define IRQREC_CAUSE  152
#define IRQREC_STATUS 156
#define IRQREC_EPC    164
#define IRQREC_SIZE   168
