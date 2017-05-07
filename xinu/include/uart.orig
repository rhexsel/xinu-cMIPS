/* uart.h - definintions for the NS16550 uart serial hardware */

#define UART_BAUD	115200	/* Default console baud rate.		*/
#define	UART_OUT_IDLE	0x0016	/* determine if transmit idle		*/
#define	UART_FIFO_SIZE	1	/* chars in UART onboard output FIFO	*/

typedef struct control { // control register fields (uses only ls byte)
  int ign   : 24,        // ignore uppermost bits
    rts     : 1,         // Request to Send output (bit 7)
    ign2    : 2,         // bits 6,5 ignored
    intTX   : 1,         // interrupt on TX buffer empty (bit 4)
    intRX   : 1,         // interrupt on RX buffer full (bit 3)
    speed   : 3;         // 4,8,16..256 tx-rx clock data rates  (bits 0..2)
} Tcontrol;

typedef struct status {  // status register fields (uses only ls byte)
  unsigned int ign : 24, // ignore uppermost 3 bytes
  cts     : 1,           // Clear To Send input=1 (bit 7)
  txEmpty : 1,           // TX register is empty (bit 6)
  rxFull  : 1,           // octet available from RX register (bit 5)
  int_TX_empt: 1,        // interrupt pending on TX empty (bit 4)
  int_RX_full: 1,        // interrupt pending on RX full (bit 3)
  ign1    : 1,           // ignored (bit 2)
  framing : 1,           // framing error (bit 1)
  overun  : 1;           // overun error (bit 0)
} Tstatus;

typedef union ctlStat { // control + status on same address
  Tcontrol  ctl;        // write-only
  Tstatus   stat;       // read-only
} TctlStat;

typedef union data {    // data registers on same address
  int tx;               // write-only
  int rx;               // read-only
} Tdata;

typedef struct serial {
  TctlStat cs;
  Tdata    d;
} Tserial;

#if 0
  ctrl.speed = SPEED;
  ctrl.intTX = 0;  // no interrupts
  ctrl.intRX = 0;
  ctrl.ign2  = 0;
  ctrl.ign   = 0;
  ctrl.rts   = 1;
  uart->cs.ctl = ctrl;
#endif

/*
 * Control and Status Register (CSR) definintions for the 16550 UART.
 * The code maps the structure structure directly onto the base address
 * CSR address for the device.
 */
struct	uart_csreg
{
	volatile uint32	buffer;	/* receive buffer (when read)		*/
				/*   OR transmit hold (when written)	*/
  	volatile uint32	ier;	/* interrupt enable			*/
	volatile uint32	iir;	 /* interrupt identification (when read)	*/
				/*   OR FIFO control (when written)	*/
	/*volatile uint32	lcr;	 line control register		*/
	/*volatile uint32	mcr;	 modem control register		*/
	/*volatile uint32	lsr;	 line status register			*/
	/*volatile uint32	msr;	 modem status register		*/
	/*volatile uint32	scr;	 scratch register			*/
};

/* Alternative names for control and status registers */
//rbr = rxdat
#define	rbr	buffer		/* receive buffer (when read)		*/
// thr = txdat 
#define	thr	buffer		/* transmit hold (when written)		*/
#define	fcr	iir		 /* FIFO control (when written)		*/
/*#define	dll	buffer		 divisor latch (low byte)		*/
/*#define	dlm	ier		 divisor latch (high byte)		*/

/* Definintion of individual bits in control and status registers	*/

/* Interrupt enable bits */

#define UART_IER_ERBFI	0x01	/* Received data interrupt mask		*/
#define UART_IER_ETBEI	0x02	/* Transmitter buffer empty interrupt	*/
//#define UART_IER_ELSI	0x04	/* Recv line status interrupt mask	*/
#define UART_IER_EMSI	0x08	/* Modem status interrupt mask		*/

/* Interrupt identification masks */

#define UART_IIR_IRQ	0x01	/* Interrupt pending bit		*/
#define UART_IIR_IDMASK 0x0E	/* 3-bit field for interrupt ID		*/
#define UART_IIR_MSC	0x00	/* Modem status change			*/
#define UART_IIR_THRE	0x02	/* Transmitter holding register empty	*/
#define UART_IIR_RDA	0x04	/* Receiver data available		*/
#define UART_IIR_RLSI	0x06	/* Receiver line status interrupt	*/
#define UART_IIR_RTO	0x0C	/* Receiver timed out			*/

/* FIFO control bits */

//#define UART_FCR_EFIFO	0x01	/* Enable in and out hardware FIFOs	*/
//#define UART_FCR_RRESET 0x02	/* Reset receiver FIFO			*/
//#define UART_FCR_TRESET 0x04	/* Reset transmit FIFO			*/
//#define UART_FCR_TRIG0	0x00	/* RCVR FIFO trigger level one char	*/
//#define UART_FCR_TRIG1	0x40	/* RCVR FIFO trigger level 1/4		*/
//#define UART_FCR_TRIG2	0x80	/* RCVR FIFO trigger level 2/4		*/
//#define UART_FCR_TRIG3	0xC0	/* RCVR FIFO trigger level 3/4		*/

/* Line control bits */

//#define UART_LCR_DLAB	0x80	/* Divisor latch access bit		*/
//#define UART_LCR_8N1	0x03	/* 8 bits, no parity, 1 stop		*/

/* Modem control bits */

#define UART_MCR_OUT2	0x08	/* User-defined OUT2			*/
#define UART_MCR_LOOP	0x10	/* Enable loopback test mode		*/

/* Line status bits */

#define UART_LSR_DR	0x01	/* Data ready				*/
#define UART_LSR_THRE	0x20	/* Transmit-hold-register empty		*/
#define UART_LSR_TEMT	0x40	/* Transmitter empty			*/

/* #define	UART_DLL	0x0B	value for low byte of divisor latch	*/
