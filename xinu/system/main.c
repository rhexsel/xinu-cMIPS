/*  main.c  - main */

#include <xinu.h>

int fibonacci(int n);

#if 0
int prA(void);
int prB(void);
int prod(sid32, sid32);
int cons(sid32, sid32);
int echo(void);
#endif

int fibo(void);
int tinp(int32);


#define BSZ   (1<<10) // 1K, MUST be a power of 2
#define EOT   0x04

volatile int  rxhd;
volatile int  rxtl;
volatile int  txhd;
volatile int  txtl;

char rxb[BSZ];
char txb[BSZ];


// convert small integer (i<16) to hexadecimal digit
static inline unsigned char i2c(int i) {
  return ( ((i) < 10) ? ((i)+'0') : (((i & 0x0f)+'a')-10) );
}

// convert hexadecimal digit to integer (i<16)
static inline unsigned int c2i(char c) {
  return ( ((c) <= '9') ? ((c)-'0') : (((c)-'a')+10) );
}


#include "fib_vet.h"

/************************************************************************/
/*									*/
/* main - main program that Xinu runs as the first user process		*/
/*									*/
/************************************************************************/

int main(void) {  // int argc, char **argv) {
  int i, j, fib, pid_fibo, pid_tinp;

  // remove echo-ing of input chars, remove \d from "\n\d"
  control( CONSOLE, TC_NOECHO, 0,0);
  control( CONSOLE, TC_MODER, 0,0);

  rxhd = rxtl = 0;
  txhd = txtl = 0;

  kprintf("\nmain\n");

#if 0
  putc( CONSOLE, '\t' );
  putc( CONSOLE, '\t' );
  putc( CONSOLE, 'm' );
  putc( CONSOLE, '\n' );
#endif

  // create(ender, espaco na pilha, prior, nome, num argumentos)
#if 1
  if ( (pid_fibo = create(fibo, 4096, 31, "fibo", 0)) == SYSERR )
    kprintf("err cre fibo\n");

  if ( (pid_tinp = create(tinp, 4096, 30, "tinp", 1, pid_fibo)) == SYSERR )
    kprintf("err cre tinp\n");

  // kprintf("pid fibo=%x tinp=%x\n", pid_fibo, pid_tinp);

  if ( resume(pid_tinp) == SYSERR ) kprintf("err res tinp\n");
  if ( resume(pid_fibo) == SYSERR ) kprintf("err res fibo\n");
#endif


#if 0
  while (TRUE) {
#else
  for (j = 0; j < 5; j++) {
#endif    
    for (i = 1; i < 46; i++) {
      fib = fibonacci(i);
      kprintf("."); // , fib);
      if (i == 45) {
	kprintf(" %x\n", fib);
      }

    }
  }
  return OK;
} //-------------------------------------------------------------------



//
// reads string from TTY, sends integer for conversion do Fibonacci number
//
int tinp(int32 pid_fibo) {
  char c, e;
  int num, terminus;
  volatile int last;

  kprintf("\ntinp\n");

  last = 0;
  terminus = FALSE;

  do {
    e = getc(CONSOLE);
    if (e != 0x0d) {
      // putc(CONSOLE, e);
      rxb[rxtl] = e;
      rxtl = (rxtl+1) & (BSZ-1);
    
      if (last <= rxtl) {
	c = rxb[last];
	last = (last+1) & (BSZ-1);
      
	if (c == EOT) {
	  terminus = TRUE;
	} else {  // convert str to int
	  if (c == '\n') {
	    num = 0;
	    while ( rxb[rxhd] != '\n' ) {  // string to int
	      num = num << 4;
	      num = c2i( rxb[rxhd] ) + num;
	      rxhd = (rxhd + 1) & (BSZ-1);
	    }
	    rxhd = (rxhd + 1) & (BSZ-1); // jump over \n

	    if (num >= D_SZ) {                            // end simulation
	      kprintf("\n\t\tWRONG INPUT %x >= %x\n\n",num, D_SZ);
	      terminus = TRUE;
	    }
	    // kprintf("\tsnd %x\n", num);
	    while ( send(pid_fibo, num) == SYSERR ) {
	      sleep(1);
	    }
	  }
	}
      }
    }
  } while ( terminus == FALSE );  // end of transmission?

  while ( send(pid_fibo, -1) == SYSERR ) {
    sleep(1);
  }

  kprintf("\n\ttinp E\n");

  return(OK);

} //----------------------------------------------------------------


//
// receives integer, converts to Fibonacci number, sends it through TTY
//
int fibo(void) {
  int32 f, fib, num, places;

  kprintf("\nfibo\n");

  do {
    num = receive();
    // kprintf("\tfibo %x\n", num);
    if (num != -1) {

      if (num >= D_SZ) {                            // end simulation
	kprintf("\n\t\tWRONG INPUT %x >= %x\n\n",num, D_SZ);
	return SYSERR;
      }

      fib = dat[num];               // int to Fibonacci

      // kprintf("\tf[%x]=%x\n", num, fib);

      places = 28;                  // Fibonacci to string
      while ( places > -1 ) {
	f = fib;
	f = (f>>places) & 0xf;
	txb[txtl] = (char)i2c(f);
	txtl = (txtl + 1) & (BSZ-1);
	places = places - 4;
      }
      txb[txtl] = (char)'\n';
      txtl = (txtl + 1) & (BSZ-1);

      if (txhd < txtl) {            // RX has less work to do than TX
	putc( CONSOLE, txb[txhd] );
	txhd = (txhd + 1) & (BSZ-1);
      }
    }
  } while (num != -1);

  txb[txtl] = (char)EOT;    // end of transmission
  txtl = (txtl + 1) & (BSZ-1);

  while ( (txhd < txtl) ) {
    putc( CONSOLE, txb[txhd] );
    txhd = (txhd + 1) & (BSZ-1);
  }

   delay_us(64);    // wait for last char to go out

  kprintf("\n\tfibo E\n");

  return(OK);
} //---------------------------------------------------------------



int fibonacci(int32 n) {
  int32 i;
  int32 f1 = 0;
  int32 f2 = 1;
  int32 fi = 0;;
  
  if (n == 0)
    return 0;
  if(n == 1)
    return 1;
  
  for(i = 2 ; i <= n ; i++ ) {
    fi = f1 + f2;
    f1 = f2;
    f2 = fi;
  }
  return fi;
} //-------------------------------------------------------------------


#if 0

#if 0
  if ( resume(create(echo, 4096, 35, "echo", 0)) == (pri16)SYSERR )
    kprintf("err echo\n");
#endif  

int echo() {
  char c;
  int  i;

  kprintf("%s\n", "echo");

  i = 0;
  do {
    c = getc(CONSOLE);
    putc(CONSOLE, c);
    i += 1;
  } while (c != EOT);

  kprintf("%x\n", i);

  return(i);
} //--------------------------------------------------------------------



#if 1
  if ( resume(create(prA, 4096, 30, "pr_A", 0)) == (pri16)SYSERR )
    kprintf("err pr_A\n");
  
  if ( resume(create(prB, 4096, 31, "pr_B", 0)) == (pri16)SYSERR )
    kprintf("err prB\n");
#endif



int prA(){
  int i = 0;
  while (i < 6){
    kprintf("\tpr_A\n");
    sleep(1);
    i += 1;
  }
  return(i);
}

int prB(){
  int i = 0;
  while (i < 6){
    kprintf("\tpr_B\n");
    sleep(3);
    i += 1;
  }
  return(i);
}





//consumidor
int cons(sid32 consumed, sid32 produced) {

  int32 i;
  kprintf("\tcons sta\n");
  for(i=0 ; i<=10 ; i++) {
    // if (wait(produced) != OK) kprintf("\nerr cons w(p)\n\n");
    wait(produced);
    kprintf("\tc %x\n", n);
    // if (signal(consumed) != OK) kprintf("\nerr cons s(c)\n\n");
    signal(consumed);
  }
  kprintf("\tcons end\n");
  return(i);
}

//produtor
int prod(sid32 consumed, sid32 produced) {
  int32 i;
  kprintf("\tprod sta\n");
  for(i=0 ; i<10 ; i++) {
    // if (wait(consumed) != OK) kprintf("\nerr prod w(c)\n\n");
    wait(consumed);
    n++;
    kprintf("\tp %x\n", n);
    signal(produced);
    // if (signal(produced) != OK) kprintf("\nerr prod s(p)\n\n");
  }
  kprintf("\tprod end\n");
  return(i);
}


#endif
