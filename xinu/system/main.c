/*  main.c  - main */

#include <xinu.h>
#include <ramdisk.h>
#include "fib_vet.h"
extern process shell(void);


int transmissor();
int receptor();
int echo();
char * to_str(int num, char * buffer);
int to_int(char * buffer, int len);
int32 n; // shared variable
int pid_transmissor, pid_receptor;

// #define PROC_VOID FALSE


#define EOT 0x04


/************************************************************************/
/*									*/
/* main - main program that Xinu runs as the first user process		*/
/*									*/
/************************************************************************/

int main(void) {  // int argc, char **argv) {

        int i, j, fibo;	// kprintf("sem c=%x q(%x)  p=%x q(%x)\n", consumed, semtab[consumed].squeue,
        // 	  produced, semtab[produced].squeue);
#if 1	
        control( CONSOLE, TC_NOECHO, 0,0);
        control( CONSOLE, TC_MODER, 0,0);
#endif
        //create(ender, espaco na pilha, prior, nome, num argumentos)
#if 1 
        if ( (pid_transmissor = create(transmissor, 4096, 20, "transmissor",0))
                        == SYSERR )
                kprintf("err create tranmissor\n");

        if ( (pid_receptor = create(receptor, 4096, 20, "receptor",0))
                        == SYSERR )
                kprintf("err create receptor\n");

        kprintf("pid Recv=%x Send=%x\n", pid_receptor, pid_transmissor);

        if ( resume(pid_transmissor) == SYSERR) kprintf("err res trans\n");
        if ( resume(pid_receptor) == SYSERR) kprintf("err res recv\n");
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


        kprintf("%s\n", "main()");

#if 1
        while (TRUE) {
#else
                for (j=0; j < 2; j++) {
#endif   
                        for (i = 0; i < 45; i++) {
                                fibo = fibonacci(i);
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
                        //kprintf("%s\n","FIBO()");
                        f2 = fi;
                }
                return fi;
        } //----------------------------------------------------------------------


        //-------------Receiver---------------------
        int receptor(){
                char c,buf[9];
                int i,numero;
                kprintf("%s\n","receptor()");
                i=0;
                numero=0;
                do{
                        c=getc(CONSOLE);
                        buf[i]=c;
                        i++;

                        if(c=='\n'){
                                numero = to_int(buf,i-1);

                                i=0;
#if 0

                                kprintf("-> %s","teste");
                                send(pid_transmissor,numero);
#else 			
                                while(send(pid_transmissor,numero) == SYSERR ) {
                                        sleep(1);
                                }
#endif		


                        }

                        if (c == EOT) {
                            
                                while(send(pid_transmissor,c) == SYSERR ) {
                                        sleep(1);
                                }
                        }

                }while(c != EOT);
                return i;
        }

        //-------------Sender-----------------------

        int transmissor(){
                kprintf("%s\n","transmissor()");
                int size,msg,num,i;
                char buffer[1024];
                char * ptr;
                size=9;
                msg=i=0;
#if 1		
                while (1) {
                        msg=receive();

                        if (msg == EOT) {
                            break;
                        }

                        num = dat[msg];
                        ptr = to_str(num,buffer);

                        do {
                          putc(CONSOLE,*ptr);
                        } while (*(ptr++) != '\n');
                        
                }

#endif
                return size;
        }
        //-----------------------int to char ----------------------
        // Acertar para converter em char para o envio...
        char * to_str(int num,char * buffer) {

                char * ptr, * buf;

                buf = buffer+32;

                *buf = '\n';
                buf--;

                for (int i = 0; i < 8; i++) {

                        char c;
                        int aux = (num & 0xF);

                        if (aux < 0xA)
                                c = aux + '0';
                        else
                                c = aux - 10 + 'A';

                        *(--buf) = c;

                        if (c != '0')
                                ptr = buf;

                        num >>= 4;

                }

                return ptr;
        }
        //-----------------------char to int ----------------------
        int to_int(char * buffer, int len) {
                int pos = len-1;
                int num = 0;
                int pow = 0;

                while (pos >= 0) {

                        char c;
                        int val;

                        c = buffer[pos];

                        if (c < 'A') {
                                val = c-'0';
                        } else {
                                val = c-'A'+10;
                        }


                        num += val << pow;
                        pos -= 1;
                        pow += 4;
                }

                return num;
        }

        //----------------------echo-----------------------
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
