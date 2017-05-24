/* uart.h - definintions for the cMIPS's uart serial hardware */

#define	UART_FIFO_SIZE	1	/* chars in UART onboard output FIFO	*/

#define UART_SPEED 4

// cannot get GCC to generate good code with bitfields
//  thus, lots of defines

#define UART_CTL_RTS   0x80
#define UART_CTL_intTX 0x10
#define UART_CTL_intRX 0x08

typedef struct control { // control register fields (uses only ls byte)
  unsigned int ign : 24, // ignore uppermost 3 bytes
    rts     : 1,         // Request to Send output (bit 7)
    ign2    : 2,         // bits 6,5 ignored
    intTX   : 1,         // interrupt on TX buffer empty (bit 4)
    intRX   : 1,         // interrupt on RX buffer full (bit 3)
    speed   : 3;         // 4,8,16... {tx,rx}clock data rates  (bits 2,1,0)
} Tctl;

typedef union ctrl {
  Tctl         s;        // structure bits
  unsigned int i;        // integer
} Tcontrol;

#define UART_STA_CTS       0x80
#define UART_STA_txEmpty   0x40
#define UART_STA_rxFull    0x20
#define UART_STA_intTXempt 0x10
#define UART_STA_intRXfull 0x08
#define UART_STA_framing   0x02
#define UART_STA_overun    0x01

typedef struct stat {    // status register fields (uses only ls byte)
  unsigned int ign : 24, // ignore uppermost 3 bytes
    cts     : 1,         // Clear To Send input=1 (bit 7)
    txEmpty : 1,         // TX register is empty (bit 6)
    rxFull  : 1,         // octet available from RX register (bit 5)
    int_TX_empt: 1,      // interrupt pending on TX empty (bit 4)
    int_RX_full: 1,      // interrupt pending on RX full (bit 3)
    ign1    : 1,         // ignored (bit 2)
    framing : 1,         // framing error (bit 1)
    overun  : 1;         // overun error (bit 0)
} Tstat;

typedef union status {
  Tstat        s;        // structure bits
  unsigned int i;        // integer
} Tstatus;


#define UART_INT_setTX  0x40
#define UART_INT_setRX  0x20
#define UART_INT_clrTX  0x10
#define UART_INT_clrRX  0x08

typedef struct inter {   // interrupt clear bits (uses only ls byte)
  unsigned int ign : 24, // ignore uppermost 3 bytes
    ign1    : 1,         // bit 7 ignored
    setTX   : 1,         // set   IRQ on TX buffer empty (bit 6)
    setRX   : 1,         // set   IRQ on RX buffer full (bit 5)
    clrTX   : 1,         // clear IRQ on TX buffer empty (bit 4)
    clrRX   : 1,         // clear IRQ on RX buffer full (bit 3)
    ign3    : 3;         // bits 2,1,0 ignored
} Tinter;

typedef union interr {
  Tinter       s;        // structure bits
  unsigned int i;        // integer
} Tinterr;


/*
 * Control and Status Register (CSR) definintions for the cMIPS UART.
 * The code maps the structure structure directly onto the base address
 * CSR address for the device.
 */
struct	uart_csreg
{
  volatile       Tcontrol ctl;  // RD+WR, addr (int *)IO_UART_ADDR
  const volatile Tstatus  stat; // RD,    addr (int *)(IO_UART_ADDR+1)
  Tinterr               interr; // WR,    addr (int *)(IO_UART_ADDR+2)
  volatile int            data; // RD+WR, addr (int *)(IO_UART_ADDR+3)
};

