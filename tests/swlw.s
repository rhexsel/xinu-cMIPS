	.include "cMIPS.s"
	.text
	.align 2
	.set noat
	.globl _start
	.ent _start
_start: la    $15, (x_DATA_BASE_ADDR+0x10)
	la    $16, x_IO_BASE_ADDR
	addi  $3,$0,10
	ori   $5,$0,2
        addi  $29,$0,800
	sw    $5, -4($15)
	nop
snd:	add  $3,$5,$3
	sw   $3, 4($15)
	lw   $4, -4($15)
	lw   $9, 4($15)
	add  $5,$5,$5   #  2, 4, 8,16,32,64,128,256,512,1024
	sw   $9, 0($16) # 10,12,16,24,40,72,136,264,520,1032
        slt  $28,$9,$29
        bne  $28,$0,snd
	nop
	nop
	nop
	wait
	nop	
	.end _start

# 0000000c 00000010 00000018 00000028 00000048 00000088 00000108 00000208 00000408
