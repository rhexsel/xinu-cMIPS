	.include "cMIPS.s"
	.text
	.align 2
	.globl _start
	.ent _start
_start: nop
	break 1
	break 2
	break 255
	break 1023
	break (256+5)
	break (512+5)
	break 100
	nop
	nop
	nop
	nop
	break
	.end _start
