/* doprnt.c -  _doprnt, _prtl2, _prtl8, _prtl10, _prtX16, _prtl16 */

#include <stdarg.h>

#define	MAXSTR	80
#define NULL    0

static void _prtl10(long num, char *str);
static void _prtl8(long num, char *str);
static void _prtX16(long num, char *str);
static void _prtl16(long num, char *str);
static void _prtl2(long num, char *str);

extern void print(int);

/**
 * Format and write output using 'func' to write characters. (Patched 
 * for Sun3 by Shawn Ostermann.)  All arguments passed as 4 bytes, long==int.
 * args are:
 *		*fmt format string
 * 		list of values
 * 		*func character output function
 * 		farg argument for character output function
 */
void _doprnt(char *fmt, va_list ap, int (*func) (int), int farg) {
  char c;
  int i;
  char f;                     /* The format character (comes after %) */
  char *str;                  /* Running pointer in string            */
  char string[32];            /* The string str points to this output */

  char *ptr;

  /*  from number conversion */
  int length;                 /* Length of string "str"               */
  char fill;                  /* Fill character (' ' or '0')          */
  int leftjust;               /* 0 = right-justified, else left-just  */
  int fmax, fmin;             /* Field specifications % MIN . MAX s   */
  int leading;                /* No. of leading/trailing fill chars   */
  char sign;                  /* Set to '-' for negative decimals     */
  char digit1;                /* Offset to add to first numeric digit */
  long larg;

  ptr = fmt;

  while (1 == 1) {
    /* Echo characters until '%' or end of fmt string */
    c = *ptr;
    while (c != '%') {
      if (c == '\0') {
	return;
      }
      (*func) (c);
      ptr += 1;
      c = *ptr;
    }
    ptr += 1;            // jump over 1st %
    f = *(ptr);
    if (f == '%') {      /* Echo "...%%..." as '%' */
      (*func) (f);
      ptr += 1;          // jump over 2nd %
      continue;
    }
    /* Check for "%-..." == Left-justified output */
    f = *ptr;
    if ((leftjust = ((f == '-')) ? 1 : 0)) {
      ptr += 1;
      f = *ptr;
    }
    /* Allow for zero-filled numeric outputs ("%0...") */
    if (f == '0') {
      fill = '0';
      ptr += 1;
    } else {
      fill = ' ';
    }
    /* Allow for minimum field width specifier for %d,u,x,o,c,s */
    /* Also allow %* for variable width (%0* as well)       */
    fmin = 0;
    f = *ptr;
    if (f == '*') {
      fmin = va_arg(ap, int);
      ptr += 1;
    } else {
      while ('0' <= f && f <= '9') {
	fmin = fmin * 10 + f - '0';
	ptr += 1;
	f = *ptr;
      }
    }

#if 0
    // this breaks the printing; cannot figure out why. RH
    /* Allow for maximum string width for %s */
    fmax = 0;
    // f = *ptr;
    if (f == '.') {
      if (*(ptr+1) == '*') {
	fmax = va_arg(ap, int);
	ptr += 1;
      } else {
	ptr += 1;
	f = *ptr;
	while ('0' <= f && f <= '9') {
	  fmax = fmax * 10 + f - '0';
	  ptr += 1;
	  f = *ptr;
	}
      }
    }
#endif

    str = string;
    f = *ptr;
    ptr += 1;
    if (f == '\0') {
      ptr += 1;
      (*func) ('%');
      print(-8);
      return;
    }
    sign = '\0';            /* sign == '-' for negative decimal */

    switch (f) {

    case 'b':
      larg = va_arg(ap, long);
      
      _prtl2(larg, str);
      fmax = 0;
      break;
      
    case 'c':
      string[0] = va_arg(ap, int);
      string[1] = '\0';
      fmax = 0;
      fill = ' ';
      break;
      
    case 'd':
      larg = va_arg(ap, long);
      
      if (larg < 0) {
	sign = '-';
      }
      _prtl10(larg, str);
      break;
      
    case 'o':
      larg = va_arg(ap, long);
      
      _prtl8(larg, str);
      fmax = 0;
      break;
      
    case 's':
      str = va_arg(ap, char *);
      // print(-16);      
      if (NULL == str) {
	str = "(null)";
      }
      fill = ' ';
      break;
      
    case 'u':
      digit1 = '\0';
      /* "negative" longs in unsigned format  */
      /* can't be computed with long division */
      /* convert *args to "positive", digit1  */
      /* = how much to add back afterwards    */
      larg = va_arg(ap, long);
      
      while (larg < 0) {
	larg -= 1000000000L;
	digit1 += 1;
      }
      _prtl10(larg, str);
      str[0] += digit1;
      fmax = 0;
      break;
      
    case 'X':
      larg = va_arg(ap, long);
      
      _prtX16(larg, str);
      fmax = 0;
      break;
      
    case 'x':
      larg = va_arg(ap, long);
      
      _prtl16(larg, str);
      fmax = 0;
      break;
      
    default:
      print(-4096);
      (*func) (f);
      break;
    }

    for (length = 0; str[length] != '\0'; length++)
      { ; }
    if (fmin > MAXSTR || fmin < 0) {
      fmin = 0;
    }
    if (fmax > MAXSTR || fmax < 0) {
      fmax = 0;
    }
    leading = 0;
    if (fmax != 0 || fmin != 0) {
      if (fmax != 0) {
	if (length > fmax) {
	  length = fmax;
	}
      }
      if (fmin != 0) {
	leading = fmin - length;
      }
      if (sign == '-') {
	--leading;
      }
    }
    if (sign == '-' && fill == '0') {
      (*func) (sign);
    }
    if (leftjust == 0) {
      for (i = 0; i < leading; i++) {
	(*func) (fill);
      }
    }
    if (sign == '-' && fill == ' ') {
      (*func) (sign);
    }
    for (i = 0; i < length; i++) {
      (*func) (str[i]);
    }
    if (leftjust != 0) {
      for (i = 0; i < leading; i++)
	(*func) (fill);
    }
  }
  
}

/************************************************************************/
/*									*/
/* _prtl10 - format a long signed value in decimal			*/
/*									*/
/************************************************************************/

static void _prtl10(long num, char *str)
{
    int i;
    char temp[11];

    temp[0] = '\0';
    temp[1] = ((num<0) ? -(num%10) : (num%10)) + '0';
    num /= (num<0) ? -10 : 10;
    for (i = 2; i <= 10; i++) {
        temp[i] = num % 10 + '0';
	num /= 10;
    }
    for (i = 10; temp[i] == '0'; i--);
    if (i == 0)
        i++;
    while (i >= 0)
        *str++ = temp[i--];
}

/************************************************************************/
/*									*/
/* _prtl8 - format a long unsigned value in octal			*/
/*									*/
/************************************************************************/
static void _prtl8(long num, char *str)
{
    int i;
    char temp[12];

    temp[0] = '\0';
    for (i = 1; i <= 11; i++)
    {
        temp[i] = (num & 07) + '0';
        num = num >> 3;
    }
    temp[11] &= '3';
    for (i = 11; temp[i] == '0'; i--);
    if (i == 0)
        i++;
    while (i >= 0)
        *str++ = temp[i--];
}

/************************************************************************/
/*									*/
/* _prtl16 - format a long in hex					*/
/*									*/
/************************************************************************/
static void _prtl16(long num, char *str)
{
    int i;
    char temp[9];

    temp[0] = '\0';
    for (i = 1; i <= 8; i++)
    {
        temp[i] = "0123456789abcdef"[num & 0x0F];
        num = num >> 4;
    }
    for (i = 8; temp[i] == '0'; i--);
    if (i == 0)
        i++;
    while (i >= 0)
        *str++ = temp[i--];
}

/************************************************************************/
/*									*/
/* _prtX16 format an int in hex						*/
/*									*/
/************************************************************************/
static void _prtX16(long num, char *str)
{
    int i;
    char temp[9];

    temp[0] = '\0';
    for (i = 1; i <= 8; i++)
    {
        temp[i] = "0123456789ABCDEF"[num & 0x0F];
        num = num >> 4;
    }
    for (i = 8; temp[i] == '0'; i--);
    if (i == 0)
        i++;
    while (i >= 0)
        *str++ = temp[i--];
}

/************************************************************************/
/*									*/
/* _prtl2 - format a long in binary					*/
/*									*/
/************************************************************************/
static void _prtl2(long num, char *str)
{
    int i;
    char temp[35];

    temp[0] = '\0';
    for (i = 1; i <= 32; i++)
    {
        temp[i] = ((num % 2) == 0) ? '0' : '1';
        num = num >> 1;
    }
    for (i = 32; temp[i] == '0'; i--);
    if (i == 0)
        i++;
    while (i >= 0)
        *str++ = temp[i--];
}
