	.include "cMIPS.s"
	.text
	.align 2
	.globl _start
	.ent _start
_start: la  $15, x_IO_BASE_ADDR
	la  $16, x_IO_BASE_ADDR
	la  $14, x_DATA_BASE_ADDR
	addi  $3,$0,-16
	ori   $5,$0,2
	la   $29,(x_IO_BASE_ADDR+0x40)
	nop
	nop
snd:	add  $3,$5,$3
	sw   $3, 0($14)
	addi $14,$14,4
	lw   $3, -4($14)
	addi $15,$15,4
	sw   $3, ($16)
	slt  $30,$15,$29
	bne  $30,$0,snd
	nop
	wait
	nop
	.end _start
	

# fffffff2 fffffff4 fffffff6 fffffff8 fffffffa fffffffc fffffffe 00000000 00000002 00000004 00000006 00000008 0000000a 0000000c 0000000e 00000010

	