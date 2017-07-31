/*  main.c  - main */

#include <xinu.h>
// #include <ramdisk.h>

// extern process shell(void);

int fibonacci(int n);

int prA(void);
int prB(void);
int echo(void);

int leTTY(void);
int escTTY(void);

int32 n; // shared variable
int32 pid_esc = -1;

// #define PROC_VOID FALSE

int prod(sid32, sid32);
int cons(sid32, sid32);

#define EOT 0x04

sid32 produced, consumed; // shared variable

/************************************************************************/
/*									*/
/* main - main program that Xinu runs as the first user process		*/
/*									*/
/************************************************************************/

int main(void) {  // int argc, char **argv) {

  int i, j, fibo;
  n = 0;

  // remove echo-ing of input chars, remove \d from "\n\d"
  control( CONSOLE, TC_NOECHO, 0,0);
  control( CONSOLE, TC_MODER, 0,0);

  consumed = semcreate(0);  //semaphore
  produced = semcreate(1);
  // kprintf("sem c=%x q(%x)  p=%x q(%x)\n", consumed, semtab[consumed].squeue,
  // 	  produced, semtab[produced].squeue);

  //create(ender, espaco na pilha, prior, nome, num argumentos)
#if 0
  int pid_prod, pid_cons;
  if ( (pid_prod = create(prod, 4096, 20, "prod", 2,consumed,produced))
       == SYSERR )
    kprintf("err cre prod\n");

  if ( (pid_cons = create(cons, 4096, 20, "cons", 2,consumed,produced))
       == SYSERR )
    kprintf("err cre cons\n");

  kprintf("pid cons=%x prod=%x\n", pid_cons, pid_prod);

  if ( resume(pid_cons) == SYSERR ) kprintf("err res cons\n");
  if ( resume(pid_prod) == SYSERR ) kprintf("err res prod\n");
#endif

#if 1
  int pid_le;
  if((pid_le = create(leTTY, 4096, 20, "le", 0)) == SYSERR) {
    kprintf("err leTTY\n");
  } else resume(pid_le);
  if((pid_esc = create(escTTY, 4096, 20, "esc", 0)) == SYSERR) {
    kprintf("err escTTY\n");
  } else resume(pid_esc);
#endif

#if 0
  if ( resume(create(prA, 4096, 30, "pr_A", 0)) == (pri16)SYSERR )
    kprintf("err pr_A\n");
  
  if ( resume(create(prB, 4096, 31, "pr_B", 0)) == (pri16)SYSERR )
    kprintf("err prB\n");
#endif

#if 0
  if ( resume(create(echo, 4096, 35, "echo", 0)) == (pri16)SYSERR )
    kprintf("err echo\n");
#endif  


#if 0
  putc( CONSOLE, '\t' );
  putc( CONSOLE, 'm' );
  putc( CONSOLE, 'a' );
  putc( CONSOLE, 'i' );
  putc( CONSOLE, 'n' );
  putc( CONSOLE, '\n' );
#else
  kprintf("%s\n", "main()");
#endif

#if 0
  while (TRUE) {
  }
#else
  for (j=0; j < 5; j++) {
#endif    
    for (i = 0; i < 45; i++) {
      fibo = fibonacci(i);
      //kprintf("%-6x\n", fibo);
    }
  }
  return OK;

} //------------------------------------------------------------------

int leTTY() {
  kprintf("\tleTTY start.\n");
  char entbuf = getc(CONSOLE);
  int32 curval = 0;

  while(entbuf != EOT) {
    if(entbuf != '\n') {
      curval *= 16;
      curval += (entbuf >= '0' && entbuf <= '9') ? entbuf - '0' : (entbuf - 'a') + 10 ;
    } else {
      while(pid_esc == -1) sleep(1);
      int hasSent;
      kprintf("\tle  %d\n", curval);
      do {
        hasSent = send(pid_esc, curval);
        if(hasSent == SYSERR) sleep(1);
      } while(hasSent == SYSERR);
      curval = 0;
    }
    entbuf = getc(CONSOLE);
  }
  send(pid_esc, -1);
  // umsg32 msg = 20;
  // while(pid_esc == -1) sleep(1);
  // send(pid_esc, msg);
  // kprintf("\tleTTY enviou.\n");
  return 1;
}

int escTTY() {
  kprintf("\tescTTY start.\n");
  
  int fibvet[45];
  fibvet[0] = 1;
  fibvet[1] = 1;
  for(int i = 2; i < 45; i++) {
    fibvet[i] = fibvet[i-1] + fibvet[i-2];
  }
  
  umsg32 msg = receive();
  while(msg != -1) {
    kprintf("\tesc %d\n", fibvet[msg]);
    msg = receive();
  }
  return 1;
}


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
} //----------------------------------------------------------------------


int prA(){
  int i = 0;
  while (i < 6){
    kprintf("\tpr_A\n");
    sleep(1);
    i += 1;
  }
  return(i);
} //----------------------------------------------------------------------

int prB(){
  int i = 0;
  while (i < 6){
    kprintf("\tpr_B\n");
    sleep(3);
    i += 1;
  }
  return(i);
} //----------------------------------------------------------------------

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
} //----------------------------------------------------------------------

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
} //----------------------------------------------------------------------


//int echo() {
//  char c;
//  int  i;
//
//  kprintf("%s\n", "echo()");
//
//  i = 0;
//  do {
//    c = getc(CONSOLE);
//    putc(CONSOLE, c);
//    i += 1;
//  } while (c != EOT);
//
//  kprintf("%x\n", i);
//
//  return(i);
//} //----------------------------------------------------------------------
