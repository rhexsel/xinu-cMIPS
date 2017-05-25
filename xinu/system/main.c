#define EOT 0x04
#define QUEUE_SIZE 16
#define i2c(n) (((n) < 10)   ? ((n)+'0') : (((n)+'a')-10))
#define c2i(a) (((a) <= '9') ? ((a)-'0') : (((a)-'a')+10))

#include <xinu.h>
#include <ramdisk.h>

extern process shell(void);

pid32 ID_print_fib;

int fibonacci(int32 input)
{
  int32 i,
        fi = 0,
        f1 = 0,
        f2 = 1;

  if (!input)
    return 0;

  if (input == 1)
    return 1;

  for (i = 2 ; i <= input ; ++i)
  {
    fi = f1 + f2;
    f1 = f2;
    f2 = fi;
  }

  return fi;
}

int parse_hex(char *source)
{
  char current;
  int parsed_hex = 0;

  for (int i = 0; source[i] != '\0'; ++i)
  {
   current = source[i];
   parsed_hex *= 16;
   parsed_hex += c2i(current);
  }
  return parsed_hex;
}

void parse_str(unsigned int source, char *destination)
{
  int length = 0;
  do
  {
    destination[length++] = i2c(source & 0xf);
    source >>= 4;
  }while (source != 0);

  for (int i = 0; i < length / 2; ++i)
  {
    destination[i] ^= destination[length - i - 1];
    destination[length - i - 1] ^= destination[i];
    destination[i] ^= destination[length - i - 1];
  }

  destination[length] = '\0';
}

#define EOT 0x04

int PID_f;

void read_tty(void)
{
  char received_char,
       request_str[9];
  int request_length;
  umsg32 msg;

  do
  {
    request_length = 0;
    while ((received_char = getc(CONSOLE)) != '\n')
      if (received_char != EOT)
        request_str[request_length++] = received_char;
    request_str[request_length] = '\0';

    if (request_length)
      msg = parse_hex(request_str);
    else
      msg = -1;
    send(PID_f, msg);

  }while (received_char != EOT);  // request_length);
}

void print_fib(void)
{
  char result_str[9];
  int request_num;

  do
  {
    request_num = (int)receive();

    if (request_num > -1)
    {
      parse_str(fibonacci(request_num), result_str);

      for (int i = 0; result_str[i] != '\0'; ++i)
        putc(CONSOLE, result_str[i]);
      putc(CONSOLE, '\n');
    }
  }while (request_num > -1);
}


int main(void)
{
  int pid_r; // , pid_f;

  PID_f = create(print_fib, 4096, 32, "print_fib", 0);

  pid_r = create(read_tty, 4096, 31, "read_tty", 0); // 1, pid_f);

  kprintf("fib %x read %x\n", PID_f, pid_r);

  if (resume(PID_f) == (pri16)SYSERR)
    kprintf("err print_fib\n");

  if ( resume(pid_r) == (pri16)SYSERR )
    kprintf("err read_tty\n");


  return 0;
}
