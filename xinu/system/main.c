/*  main.c  - main */

#include <xinu.h>
#include <ramdisk.h>

extern process shell(void);

int fibonacci(int n);

int prA(void);
int prB(void);
int echo(void);

int32 n; // shared variable

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

  int i, j, fibo, pid_cons, pid_prod;
  n = 0;

  consumed = semcreate(0);  //semaphore
  produced = semcreate(1);
  // kprintf("sem c=%x q(%x)  p=%x q(%x)\n", consumed, semtab[consumed].squeue,
  // 	  produced, semtab[produced].squeue);

  //create(ender, espaco na pilha, prior, nome, num argumentos)
#if 0
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
  if ( resume(create(prA, 4096, 30, "pr_A", 0)) == (pri16)SYSERR )
    kprintf("err pr_A\n");
  
  if ( resume(create(prB, 4096, 31, "pr_B", 0)) == (pri16)SYSERR )
    kprintf("err prB\n");
#endif

#if 1
  if ( resume(create(echo, 4096, 35, "echo", 0)) == (pri16)SYSERR )
    kprintf("err echo\n");
#endif  


  kprintf("%s\n", "main()");

#if 0
  while (TRUE) {
#else
  for (j=0; j < 5; j++) {
#endif    
    for (i = 0; i < 45; i++) {
      fibo = fibonacci(i);
      kprintf("%-6x\n", fibo);
    }
  }
  return OK;

} //------------------------------------------------------------------


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


int echo() {
  char c;
  int  i;

  kprintf("%s\n", "echo()");

  i = 0;
  do {
    c = getc(CONSOLE);
    putc(CONSOLE, c);
    i += 1;
  } while (c != EOT);

  kprintf("%x\n", i);

  return(i);
} //----------------------------------------------------------------------
