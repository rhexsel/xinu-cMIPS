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
	j	$31
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
	j	$31
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
	j	$31
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
	j	$31
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
	j	$31
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
	j	$31
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
	j	$31
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
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	readStats
	.size	readStats, .-readStats
	.align	2
	.globl	my_memcpy
	.set	nomips16
	.set	nomicromips
	.ent	my_memcpy
	.type	my_memcpy, @function
my_memcpy:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$3,-2147483648			# 0xffffffff80000000
	addiu	$3,$3,3
	and	$3,$5,$3
	bgez	$3,$L12
	move	$2,$4

	addiu	$3,$3,-1
	li	$4,-4			# 0xfffffffffffffffc
	or	$3,$3,$4
	addiu	$3,$3,1
$L12:
	blez	$3,$L25
	slt	$4,$6,4

	blez	$6,$L33
	move	$7,$2

	addu	$3,$2,$3
$L18:
	lb	$8,0($5)
	nop
	sb	$8,0($7)
	addiu	$6,$6,-1
	addiu	$7,$7,1
	bne	$7,$3,$L15
	addiu	$5,$5,1

	b	$L31
	slt	$4,$6,4

$L25:
	move	$3,$2
$L31:
	beq	$4,$0,$L32
	andi	$7,$3,0x3

	b	$L17
	nop

$L15:
	bne	$6,$0,$L18
	nop

$L35:
	j	$31
	nop

$L23:
	andi	$7,$3,0x3
$L32:
	bne	$7,$0,$L20
	andi	$7,$3,0x1

	lw	$7,0($5)
	b	$L21
	sw	$7,0($3)

$L20:
	bne	$7,$0,$L22
	nop

	lh	$7,0($5)
	nop
	sh	$7,0($3)
	lh	$7,2($5)
	b	$L21
	sh	$7,2($3)

$L22:
	lb	$7,0($5)
	nop
	sb	$7,0($3)
	lh	$7,1($5)
	nop
	sh	$7,1($3)
	lb	$7,3($5)
	nop
	sb	$7,3($3)
$L21:
	addiu	$6,$6,-4
	addiu	$5,$5,4
	slt	$7,$6,4
	beq	$7,$0,$L23
	addiu	$3,$3,4

$L17:
	blez	$6,$L35
	addu	$6,$3,$6

$L24:
	lb	$7,0($5)
	nop
	sb	$7,0($3)
	addiu	$3,$3,1
	bne	$6,$3,$L24
	addiu	$5,$5,1

	j	$31
	nop

$L33:
	beq	$4,$0,$L23
	move	$3,$2

	j	$31
	nop

	.set	macro
	.set	reorder
	.end	my_memcpy
	.size	my_memcpy, .-my_memcpy
	.align	2
	.globl	my_memset
	.set	nomips16
	.set	nomicromips
	.ent	my_memset
	.type	my_memset, @function
my_memset:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$3,-2147483648			# 0xffffffff80000000
	addiu	$3,$3,3
	and	$3,$4,$3
	bgez	$3,$L37
	move	$2,$4

	addiu	$3,$3,-1
	li	$4,-4			# 0xfffffffffffffffc
	or	$3,$3,$4
	addiu	$3,$3,1
$L37:
	blez	$3,$L46
	nop

	blez	$6,$L39
	move	$7,$2

	addu	$3,$2,$3
$L40:
	sb	$5,0($7)
	addiu	$7,$7,1
	beq	$7,$3,$L38
	addiu	$6,$6,-1

	bne	$6,$0,$L40
	nop

$L53:
	j	$31
	nop

$L46:
	move	$3,$2
$L38:
	sll	$7,$5,8
	sll	$8,$5,16
	or	$8,$7,$8
	or	$7,$8,$5
	sll	$8,$5,24
	slt	$4,$6,4
	bne	$4,$0,$L42
	or	$8,$7,$8

$L43:
	sw	$8,0($3)
	addiu	$6,$6,-4
	slt	$7,$6,4
	beq	$7,$0,$L43
	addiu	$3,$3,4

$L42:
	blez	$6,$L53
	addu	$6,$3,$6

$L44:
	sb	$5,0($3)
	addiu	$3,$3,1
	bne	$6,$3,$L44
	nop

	j	$31
	nop

$L39:
	sll	$3,$5,16
	sll	$4,$5,8
	or	$3,$3,$4
	or	$3,$3,$5
	sll	$8,$5,24
	or	$8,$3,$8
	slt	$4,$6,4
	beq	$4,$0,$L43
	move	$3,$2

	j	$31
	nop

	.set	macro
	.set	reorder
	.end	my_memset
	.size	my_memset, .-my_memset
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
	bne	$5,$0,$L55
	li	$3,-2147483648			# 0xffffffff80000000

	move	$3,$0
$L55:
	li	$2,1073676288			# 0x3fff0000
	ori	$2,$2,0xffff
	and	$4,$4,$2
	li	$2,1073741824			# 0x40000000
	or	$4,$4,$2
	or	$4,$4,$3
	li	$2,1006632960			# 0x3c000000
	j	$31
	sw	$4,160($2)

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
	lw	$3,160($4)
	li	$2,-1073807360			# 0xffffffffbfff0000
	ori	$2,$2,0xffff
	and	$2,$3,$2
	j	$31
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
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	readCounter
	.size	readCounter, .-readCounter
	.ident	"GCC: (GNU) 5.1.0"
