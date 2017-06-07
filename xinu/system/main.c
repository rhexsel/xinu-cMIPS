/*  main.c  - main */
#include <xinu.h>
#include <ramdisk.h>
//#include <cMIPS.h>

extern process shell(void);

int fibonacci(int n);
void receive_fib(void);
void send_fib(void);

int32 n;
pid32 pid_dest;

char str1[256];
char str2[256];

#define EOT 0xfffffffe
#define END 0xffffffff

// convert small integer (i<16) to hexadecimal digit
static inline unsigned char i2c(int i) {
  return ( ((i) < 10) ? ((i)+'0') : (((i & 0x0f)+'a')-10) );
}

// convert hexadecimal digit to integer (i<16)
static inline unsigned int c2i(char c) {
  return ( ((c) <= '9') ? ((c)-'0') : (((c)-'a')+10) );
}

int to_int(volatile char *str){

    int number = 0;
    int i = 0;

    while ( str[i] != '\n' ) {
      number = number << 4;
      number += c2i(str[i++]);
    }

    return number;
}

int to_str(volatile char *str, unsigned int number){
	unsigned int i, j, k, l;

    i = 0;
    l = number;
    k = number;

    do {
        ++i;
        k = k >> 4;
    } while( k != 0);

    str[i] = '\n';

    for ( j = i; j > 0;){
        k = number & 15;
        number = number >> 4;
        str[--j] = i2c(k);
    }



    if (l == END){
      i = 0;
      str[i] = 0x04;
    }

	return i+1;
}

void receive_fib(){
  int j = 0;
  char c;

  do {
    c = getc(CONSOLE);

    if (c != EOT){
      str1[j++] = c;
    } else {
      while ( send(pid_dest, (umsg32)END) == SYSERR ) {
        sleep(1);
      }
    }

    if (c == '\n') {

      if (j != 1) {
        while ( send(pid_dest, (umsg32)to_int(str1)) == SYSERR ) {
          sleep(1);
        }
      }

      j = 0;
    }

  } while (c != EOT);

  kprintf("receive_fib() done\n");
  return;
}

void send_fib(){
    umsg32 msg;
    unsigned int i, j, k, fibo;

    do{
      msg = receive();
      i = (unsigned int)msg;

      if (i != END){
        fibo = fibonacci(i);
      } else {
        fibo = END;
      }

      k = to_str(str2,fibo);

      kprintf("-->  ");

      for (j = 0; j < k; ++j){
        putc(CONSOLE, str2[j]);
        kprintf("%c", str2[j]);
      }
    }while (i != END);

    kprintf("\n");

    i = 0;
    while(i < 100){sleep(1);}

    kprintf("send_fib() done\n");
    return;
}

int main(void){

  int i, fibo;
  n = 0;

  control( CONSOLE, TC_MODER, 0,0);
  

#if 1
  if ( resume(pid_dest = create(send_fib, 4096, 31, "pr_A", 0)) == (pri16)SYSERR )
    kprintf("err receive\n");

  if ( resume(create(receive_fib, 4096, 30, "pr_B", 0)) == (pri16)SYSERR )
    kprintf("err send\n");
#endif

  while (TRUE) {
    for (i = 1; i < 46; i++) {
      fibo = fibonacci(i);
      //kprintf("-- %x\n", fibo);
    }
  }
  return OK;
}

int fibonacci(int32 n) {
  int32 i;
  int32 f1 = 0;
  int32 f2 = 1;
  int32 fi = 0;

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
}
