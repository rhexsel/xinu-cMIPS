#########################################################################
#									#
#	Make the Xinu version of the C run-time support library		#
#									#
#									#
# IMPORTANT NOTE: this Makefile is not designed to stand alone.		#
#		it is invoked from the main Makefile (and inherits	#
#		all the compiler and loader path variables). Thus,	#
#		simply typing 'make' will fail.				#
#									#
#########################################################################

INCLUDE	= -I../../include
LIBDIR	= ..

LIBNAME = libxc

# Make sure the library is optimized for size, if
# we want any optimization

CFLAGS := ${CFLAGS:-O%=-O2}

# Update the include flag
CFLAGS := ${CFLAGS:-I%=${INCLUDE}}

.s.o:
		${AS} -EL -o $@ ${AFLAGS} $<

.c.o:
		${CC} -EL ${CFLAGS} $<

CFILES	=	abs.c atoi.c atol.c bzero.c ctype_.c doprnt.c doscan.c	\
		fdoprnt.c fgetc.c fgets.c fprintf.c fputc.c fputs.c	\
		fscanf.c getchar.c labs.c memchr.c memcmp.c memcpy.c	\
		memset.c printf.c putchar.c qsort.c rand.c sprintf.c	\
		sscanf.c strchr.c strncat.c strncmp.c strncpy.c		\
		strnlen.c strrchr.c strstr.c

OFILE2 = ${CFILES:%.c=%.o}
OFILES = ${OFILE2:%.s=%.o}

all:		${LIBNAME}.a

${LIBNAME}.a:	${OFILES}
		@rm -f ${LIBNAME}.a
		@${AR} cr ${LIBNAME}.a ${OFILES}

install:	${LIBNAME}.a
		@cp ${LIBNAME}.a ${LIBDIR}/${LIBNAME}.a

clean:
		rm -f ${OFILES} ${LIBNAME}.a ${LIBDIR}/${LIBNAME}.a
