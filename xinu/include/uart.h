/* uart.h - definintions for the NS16550 uart serial hardware */

// #define UART_BAUD	115200	/* Default console baud rate.		*/
// #define	UART_OUT_IDLE	0x0016	/* determine if transmit idle	*/
#define	UART_FIFO_SIZE	1	/* chars in UART onboard output FIFO	*/

#define UART_SPEED 4

typedef struct control { // control register fields (uses only ls byte)
  unsigned int ign : 24, // ignore uppermost 3 bytes
    rts     : 1,         // Request to Send output (bit 7)
    ign2    : 2,         // bits 6,5 ignored
    intTX   : 1,         // interrupt on TX buffer empty (bit 4)
    intRX   : 1,         // interrupt on RX buffer full (bit 3)
    speed   : 3;         // 4,8,16... {tx,rx}clock data rates  (bits 2,1,0)
} Tcontrol;

typedef struct status {  // status register fields (uses only ls byte)
  unsigned int ign : 24, // ignore uppermost 3 bytes
    cts     : 1,         // Clear To Send input=1 (bit 7)
    txEmpty : 1,         // TX register is empty (bit 6)
    rxFull  : 1,         // octet available from RX register (bit 5)
    int_TX_empt: 1,      // interrupt pending on TX empty (bit 4)
    int_RX_full: 1,      // interrupt pending on RX full (bit 3)
    ign1    : 1,         // ignored (bit 2)
    framing : 1,         // framing error (bit 1)
    overun  : 1;         // overun error (bit 0)
} Tstatus;

typedef struct interr  { // interrupt clear bits (uses only ls byte)
  unsigned int ign : 24, // ignore uppermost 3 bytes
    ign1    : 1,         // bit 7 ignored
    setTX   : 1,         // set   IRQ on TX buffer empty (bit 6)
    setRX   : 1,         // set   IRQ on RX buffer full (bit 5)
    clrTX   : 1,         // clear IRQ on TX buffer empty (bit 4)
    clrRX   : 1,         // clear IRQ on RX buffer full (bit 3)
    ign3    : 3;         // bits 2,1,0 ignored
} Tinterr;


/*
 * Control and Status Register (CSR) definintions for the cMIPS UART.
 * The code maps the structure structure directly onto the base address
 * CSR address for the device.
 */
struct	uart_csreg
{
  volatile Tcontrol  ctl;        // w-o,  address is (int *)IO_UART_ADDR
  volatile Tstatus   stat;       // r-o,  address is (int *)(IO_UART_ADDR+1)
  volatile Tinterr   interr;     // r+w,  address is (int *)(IO_UART_ADDR+2)
  volatile uint32    data;       // r-w,  address is (int *)(IO_UART_ADDR+3)
};

struct  zz_uart_csreg
{
        volatile uint32 buffer; /* receive buffer (when read)           */
                                /*   OR transmit hold (when written)    */
        volatile uint32 ier;    /* interrupt enable                     */
        volatile uint32 iir;    /* interrupt identification (when read) */
                                /*   OR FIFO control (when written)     */
        volatile uint32 lcr;    /* line control register                */
        volatile uint32 mcr;    /* modem control register               */
        volatile uint32 lsr;    /* line status register                 */
        volatile uint32 msr;    /* modem status register                */
        volatile uint32 scr;    /* scratch register                     */
};


/* Alternative names for control and status registers */

//#define rbr     data            /* receive buffer (when read)           */
//#define thr     data            /* transmit hold (when written)         */
//#define ier     interr          /* interrupt register byte              */

// #define fcr     iir             /* FIFO control (when written)          */
// #define dll     buffer          /* divisor latch (low byte)             */
// #define dlm     ier             /* divisor latch (high byte)            */


/* Definintion of individual bits in control and status registers	*/

/* Interrupt enable bits */

#define UART_IER_ERBFI	0x08	/* Received data interrupt mask		*/
#define UART_IER_ETBEI	0x10	/* Transmitter buffer empty interrupt	*/
#define UART_IER_ELSI	0x00	/* Recv line status interrupt mask */
#define UART_IER_EMSI	0x00	/* Modem status interrupt mask	*/

/* Interrupt identification masks */

#define UART_IIR_IRQ	0x18	/* Interrupt pending bits		*/
#define UART_IIR_IDMASK 0x18	/* 2-bit field for interrupt ID		*/

// #define UART_IIR_MSC	0x00	/* Modem status change			*/
#define UART_IIR_THRE	0x40	/* Transmitter holding register empty	*/
#define UART_IIR_RDA	0x20	/* Receiver data available		*/

// #define UART_IIR_RLSI	0x06	/* Receiver line status interrupt*/
// #define UART_IIR_RTO	0x0C	/* Receiver timed out			*/


/* Line status bits */

// #define UART_LSR_DR	0x01	/* Data ready				*/
// #define UART_LSR_THRE	0x20	/* Transmit-hold-register empty	*/
// #define UART_LSR_TEMT	0x40	/* Transmitter empty		*/

