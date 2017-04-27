	.file	1 "cMIPSio.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.text
	.align	2
	.globl	from_stdin
	.set	nomips16
	.set	nomicromips
	.ent	from_stdin
	.type	from_stdin, @function
from_stdin:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,1006632960			# 0x3c000000
	lw	$2,64($2)
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	from_stdin
	.size	from_stdin, .-from_stdin
	.align	2
	.globl	to_stdout
	.set	nomips16
	.set	nomicromips
	.ent	to_stdout
	.type	to_stdout, @function
to_stdout:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	andi	$4,$4,0x00ff
	li	$2,1006632960			# 0x3c000000
	jr	$31
	sw	$4,32($2)

	.set	macro
	.set	reorder
	.end	to_stdout
	.size	to_stdout, .-to_stdout
	.align	2
	.globl	print
	.set	nomips16
	.set	nomicromips
	.ent	print
	.type	print, @function
print:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,1006632960			# 0x3c000000
	jr	$31
	sw	$4,0($2)

	.set	macro
	.set	reorder
	.end	print
	.size	print, .-print
	.align	2
	.globl	readInt
	.set	nomips16
	.set	nomicromips
	.ent	readInt
	.type	readInt, @function
readInt:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,1006632960			# 0x3c000000
	lw	$2,100($2)
	nop
	bne	$2,$0,$L6
	li	$3,1006632960			# 0x3c000000

	lw	$3,96($3)
	nop
	sw	$3,0($4)
$L6:
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	readInt
	.size	readInt, .-readInt
	.align	2
	.globl	writeInt
	.set	nomips16
	.set	nomicromips
	.ent	writeInt
	.type	writeInt, @function
writeInt:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,1006632960			# 0x3c000000
	jr	$31
	sw	$4,128($2)

	.set	macro
	.set	reorder
	.end	writeInt
	.size	writeInt, .-writeInt
	.align	2
	.globl	writeClose
	.set	nomips16
	.set	nomicromips
	.ent	writeClose
	.type	writeClose, @function
writeClose:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$3,1			# 0x1
	li	$2,1006632960			# 0x3c000000
	jr	$31
	sw	$3,132($2)

	.set	macro
	.set	reorder
	.end	writeClose
	.size	writeClose, .-writeClose
	.align	2
	.globl	dumpRAM
	.set	nomips16
	.set	nomicromips
	.ent	dumpRAM
	.type	dumpRAM, @function
dumpRAM:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$3,1			# 0x1
	li	$2,1006632960			# 0x3c000000
	jr	$31
	sb	$3,135($2)

	.set	macro
	.set	reorder
	.end	dumpRAM
	.size	dumpRAM, .-dumpRAM
	.align	2
	.globl	readStats
	.set	nomips16
	.set	nomicromips
	.ent	readStats
	.type	readStats, @function
readStats:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	readStats
	.size	readStats, .-readStats
	.align	2
	.globl	memcpy
	.set	nomips16
	.set	nomicromips
	.ent	memcpy
	.type	memcpy, @function
memcpy:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$7,-2147483648			# 0xffffffff80000000
	addiu	$7,$7,3
	and	$7,$5,$7
	bltz	$7,$L30
	move	$2,$4

$L12:
	blez	$7,$L24
	move	$3,$2

	blez	$6,$L14
	addu	$7,$2,$7

	move	$3,$2
$L15:
	lb	$8,0($5)
	nop
	sb	$8,0($3)
	addiu	$6,$6,-1
	addiu	$3,$3,1
	beq	$3,$7,$L13
	addiu	$5,$5,1

	bne	$6,$0,$L15
	nop

$L33:
	jr	$31
	nop

$L30:
	addiu	$7,$7,-1
	li	$3,-4			# 0xfffffffffffffffc
	or	$7,$7,$3
	b	$L12
	addiu	$7,$7,1

$L24:
$L13:
	slt	$4,$6,4
	beq	$4,$0,$L31
	andi	$7,$3,0x3

$L17:
	blez	$6,$L33
	addu	$6,$3,$6

$L22:
	lb	$7,0($5)
	nop
	sb	$7,0($3)
	addiu	$3,$3,1
	bne	$6,$3,$L22
	addiu	$5,$5,1

	jr	$31
	nop

$L18:
	bne	$7,$0,$L20
	nop

	lh	$7,0($5)
	nop
	sh	$7,0($3)
	lh	$7,2($5)
	nop
	sh	$7,2($3)
$L19:
	addiu	$6,$6,-4
	addiu	$5,$5,4
	slt	$7,$6,4
	bne	$7,$0,$L17
	addiu	$3,$3,4

$L21:
	andi	$7,$3,0x3
$L31:
	bne	$7,$0,$L18
	andi	$7,$3,0x1

	lw	$7,0($5)
	b	$L19
	sw	$7,0($3)

$L20:
	lb	$7,0($5)
	nop
	sb	$7,0($3)
	lh	$7,1($5)
	nop
	sh	$7,1($3)
	lb	$7,3($5)
	b	$L19
	sb	$7,3($3)

$L14:
	slt	$4,$6,4
	beq	$4,$0,$L21
	move	$3,$2

	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	memcpy
	.size	memcpy, .-memcpy
	.align	2
	.globl	memset
	.set	nomips16
	.set	nomicromips
	.ent	memset
	.type	memset, @function
memset:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$7,-2147483648			# 0xffffffff80000000
	addiu	$7,$7,3
	and	$7,$4,$7
	bltz	$7,$L50
	move	$2,$4

$L35:
	blez	$7,$L44
	move	$3,$2

	blez	$6,$L37
	addu	$7,$2,$7

	move	$3,$2
$L38:
	sb	$5,0($3)
	addiu	$3,$3,1
	beq	$3,$7,$L36
	addiu	$6,$6,-1

	bne	$6,$0,$L38
	nop

$L52:
	jr	$31
	nop

$L50:
	addiu	$7,$7,-1
	li	$3,-4			# 0xfffffffffffffffc
	or	$7,$7,$3
	b	$L35
	addiu	$7,$7,1

$L44:
$L36:
	sll	$8,$5,8
	sll	$4,$5,16
	or	$8,$8,$4
	or	$8,$8,$5
	sll	$4,$5,24
	or	$8,$8,$4
	slt	$4,$6,4
	bne	$4,$0,$L40
	nop

$L41:
	sw	$8,0($3)
	addiu	$6,$6,-4
	slt	$7,$6,4
	beq	$7,$0,$L41
	addiu	$3,$3,4

$L40:
	blez	$6,$L52
	addu	$6,$3,$6

$L42:
	sb	$5,0($3)
	addiu	$3,$3,1
	bne	$6,$3,$L42
	nop

	jr	$31
	nop

$L37:
	sll	$8,$5,16
	sll	$3,$5,8
	or	$8,$8,$3
	or	$8,$8,$5
	sll	$3,$5,24
	or	$8,$8,$3
	slt	$4,$6,4
	beq	$4,$0,$L41
	move	$3,$2

	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	memset
	.size	memset, .-memset
	.align	2
	.globl	startCounter
	.set	nomips16
	.set	nomicromips
	.ent	startCounter
	.type	startCounter, @function
startCounter:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	beq	$5,$0,$L55
	li	$2,1073676288			# 0x3fff0000

	li	$5,-2147483648			# 0xffffffff80000000
$L55:
	ori	$2,$2,0xffff
	and	$4,$4,$2
	li	$2,1073741824			# 0x40000000
	or	$4,$4,$2
	or	$5,$4,$5
	li	$2,1006632960			# 0x3c000000
	jr	$31
	sw	$5,160($2)

	.set	macro
	.set	reorder
	.end	startCounter
	.size	startCounter, .-startCounter
	.align	2
	.globl	stopCounter
	.set	nomips16
	.set	nomicromips
	.ent	stopCounter
	.type	stopCounter, @function
stopCounter:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$4,1006632960			# 0x3c000000
	lw	$2,160($4)
	li	$3,-1073807360			# 0xffffffffbfff0000
	ori	$3,$3,0xffff
	and	$2,$2,$3
	jr	$31
	sw	$2,160($4)

	.set	macro
	.set	reorder
	.end	stopCounter
	.size	stopCounter, .-stopCounter
	.align	2
	.globl	readCounter
	.set	nomips16
	.set	nomicromips
	.ent	readCounter
	.type	readCounter, @function
readCounter:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,1006632960			# 0x3c000000
	lw	$2,160($2)
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	readCounter
	.size	readCounter, .-readCounter
	.ident	"GCC: (GNU) 6.3.0"
