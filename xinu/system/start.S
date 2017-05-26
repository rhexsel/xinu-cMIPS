/*  start.S  _start, memzero */

/************************************************************************/
/*									*/
/*   External symbol start (_start in assembly language) gives the	*/
/* location where execution begins after the bootstrap loader has	*/
/* placed a Xinu image in memory and is ready to execute the image.	*/
/*									*/
/*   After initializing the hardware and establishing a run-time	*/
/* environment suitable for C (including a valid stack pointer), the	*/
/* code jumps to the C function nulluser.				*/
/*									*/
/************************************************************************/


#include <interrupt.h>
#include <mips.h>

#include "cMIPS.s"


#define NULLSTK      8192       /* Safe size for NULLSTK */

.extern	flash_size

.text
	.align	4
	.globl	_minheap
	.globl	_start

/*------------------------------------------------------------------------
 *
 * _start   - set up interrupts, initialize the stack pointer, clear the
 *            null process stack, zero the BSS (uninitialized data)
 *            segment, and invoke nulluser
 *
 *------------------------------------------------------------------------
 */
	.ent _start
_start:

	/* Pick up flash size from a3 (where the boot loader leaves it)	*/

	# sw	a3, flash_size
	sw	zero, flash_size(zero)

	/* Clear Xinu-defined trap and interrupt vectors */

	# la	a0, IRQ_ADDR      ## invalid addresses for cMIPS
	# la	a1, IRQVEC_END
	# jal	memzero
	# la	a0, TRAPVEC_ADDR
	# la	a1, IRQVEC_END
	# jal	memzero

	
	/* Copy low-level interrupt dispatcher to reserved location.	*/

	# la	a0, IRQ_ADDR		/* Reserved vector location	*/
	# la	a1, intdispatch		/* Start of dispatch code	*/
	# lw	v0, 0(a1)
	# sw	v0, 0(a0)		/* Store jump opcode		*/

	/* Clear interrupt related registers in the coprocessor */

        # STATUS: cop0, no interrupts enabled, kern mode
        li      k0, 0x1000e000
	mtc0	k0, CP0_STATUS		/* Clear interrupt masks	*/

	# COUNTER disabled, separate interr vector
	li      k0, 0x08800000
	mtc0	k0, CP0_CAUSE		/* Clear interrupt cause reg.	*/

	/* Clear and invalidate the L1 instruction and data caches */

	# jal	flushcache
		
	/* Set up Stack segment (see function summary) */

	li	s0, NULLSTK		/* Stack is NULLSTK bytes	*/
	la	a0, _end
	addu	s0, s0, a0		/* Top of stack = _end+NULLSTK	*/

	/* Word align the top of the stack */

	subu	s1, s0, 1
	srl	s1, 4
	sll	s1, 4
	
	/* Initialize the stack and frame pointers */

	move	sp, s1
	move	fp, s1
	
	/* Zero NULLSTK space below new stack pointer */

	la	a0, _end
	move	a1, s0
	# jal	memzero

	/* Clear the BSS segment */

	la	a0, _bss
	la	a1, _end
	# jal	memzero

	/* Store bottom of the heap */

	la	t0, minheap
	sw	s0, 0(t0)


        # STATUS: cop0, hw interrupt IRQ7,IRQ6,IRQ5 enabled, user mode
        li      k0, 0x1000e011
	mtc0	k0, c0_status		/* Clear interrupt masks	*/

	# enable COUNTER, separate interr vector
	li      k0, 0x00800000
	mtc0	k0, c0_cause		/* Clear interrupt cause reg.	*/
	
	j	nulluser	/* jump to the null process code */
	.end	_start

/*------------------------------------------------------------------------
 * memzero - clear a specified area of memory
 *
 * 	args are: starting address and ending address
 *------------------------------------------------------------------------
 */
	.ent	memzero
memzero:
	sw	zero, 0(a0)
	addiu	a0, a0, 4
	blt	a0, a1, memzero
	jr	ra
	.end	memzero


	## code from cMIPS/include/start.s
        ##
        ##================================================================
        ## exception vector_0000 TLBrefill, from See MIPS Run pg 145
        ##
        .org x_EXCEPTION_0000,0
        .ent _excp_0000
_excp_0000:
        .set noreorder
        .set noat

	nop
	nop
	nop
	wait 0xfe		# no TLB on Xinu, yet
	nop			# stop simulation
	
        mfc0 k1, c0_context
        lw   k0, 0(k1)          # k0 <- TP[Context.lo]
        lw   k1, 8(k1)          # k1 <- TP[Context.hi]
        mtc0 k0, c0_entrylo0  # EntryLo0 <- k0 = even element
        mtc0 k1, c0_entrylo1  # EntryLo1 <- k1 = odd element
        ehb
        tlbwr                   # update TLB
	nop
	nop
	nop
	wait 0x3e		# STOP SIMULATION IF IT GETS HERE ZZZZZZZZ
        #eret
        .end _excp_0000


        ##
        ##================================================================
        ## exception vector_0100 Cache Error (hw not implemented)
        ##
        .org x_EXCEPTION_0100,0
        .ent _excp_0100
_excp_0100:
        .set noreorder
        .set noat

        la   k0, x_IO_BASE_ADDR
        mfc0 k1, c0_cause
        sw   k1, 0(k0)        # print CAUSE, flush pipe and stop simulation
        nop
        nop
        nop
        wait 0x01
        nop
        .end _excp_0100


        ##
        ##================================================================
        ## handler for all exceptions except interrupts and TLBrefill
        ##
	.extern intdispatch
        .set noreorder
        .set noat
        .org x_EXCEPTION_0180,0  # exception vector_180
        .ent _excp_0180
_excp_0180:

        mfc0 k0, c0_cause

        andi k0, k0, 0x3c    # keep only the first 16 ExceptionCodes & b"00"
        sll  k0, k0, 1       # displacement in vector is 8 bytes
        lui  k1, %hi(excp_tbl)
        ori  k1, k1, %lo(excp_tbl)
        add  k1, k1, k0
        jr   k1
        nop

excp_tbl: # see Table 8-25, pg 95,96
        wait 0x02  # interrupt, should never arrive here, abort simulation
        nop
        wait 0x03  # Mod
        nop
        wait 0x04  # TLBL
        nop
        wait 0x05  # TLBS
        nop
        wait 0x06  # AdEL addr error     -- abort simulation
        nop
        wait 0x07  # AdES addr error     -- abort simulation
        nop
        wait 0x08  # IBE addr error      -- abort simulation
        nop
        wait 0x09  # DBE addr error      -- abort simulation
        nop
	wait 0x0a  # syscall
        nop
	wait 0x0b  # breakpoint
        nop
	wait 0x0c  # RI reserved instruction
        nop
	wait 0x0d  # CpU coprocessor unusable
        nop
	wait 0x0e  # Ov overflow
        nop
        wait 0x0f  # trap
        nop
        wait 0x10  # reserved instruction, should never get here
        nop
        wait 0x11  # FP exception, should never get here
        nop

	## should never get to this point
	# jump to interrupt_dispatch and do nothing else
	# j intdispatch
	nop

	nop		# should NEVER get to this instruction
	nop
	nop
	wait 0x20
	nop
        .end _excp_0180
        #----------------------------------------------------------------



	##
        ##===============================================================
        ## interrupt handlers at exception vector 0200
        ##
        # declare all handlers here, these must be in file handlers.s
        .extern countCompare  # IRQ7 = hwIRQ5, Cop0 counter
        .extern ttyInterrupt  # IRQ6 - hwIRQ4, see vhdl/tb_cMIPS.vhd
        .extern extCounter    # IRQ5 - hwIRQ3, see vhdl/tb_cMIPS.vhd

	.extern clkhandler
	
        .set M_CauseIM,0x0000ff00   # keep bits 15..8 -> IM = IP
        .set M_StatusIEn,0x0000e311 # user mode, enable irq7,irq6,irq1,irq0

        .set noreorder

        .org x_EXCEPTION_0200,0     # exception vector_200, interrupt handlers
        .ent _excp_0200
excp_0200:
_excp_0200:

save:	addiu   sp, sp, -IRQREC_SIZE    /* Allocate space on stack      */
        mfc0    k1, CP0_EPC             /* Save interrupted PC value    */
        sw      AT, IRQREC_AT(sp)       /* Save assembler temp reg first*/
	sw      k1, IRQREC_EPC(sp)
        .set at
        .set reorder
        sw      v0, IRQREC_V0(sp)       /* Save all general purpose regs*/
        sw      v1, IRQREC_V1(sp)
        sw      a0, IRQREC_A0(sp)
        sw      a1, IRQREC_A1(sp)
        sw      a2, IRQREC_A2(sp)
        sw      a3, IRQREC_A3(sp)
	sw      t0, IRQREC_T0(sp)
        sw      t1, IRQREC_T1(sp)
        sw      t2, IRQREC_T2(sp)
        sw      t3, IRQREC_T3(sp)
        sw      t4, IRQREC_T4(sp)
        sw      t5, IRQREC_T5(sp)
        sw      t6, IRQREC_T6(sp)
        sw      t7, IRQREC_T7(sp)
        sw      s0, IRQREC_S0(sp)
        sw      s1, IRQREC_S1(sp)
        sw      s2, IRQREC_S2(sp)
        sw      s3, IRQREC_S3(sp)
        sw      s4, IRQREC_S4(sp)
        sw      s5, IRQREC_S5(sp)
        sw      s6, IRQREC_S6(sp)
        sw      s7, IRQREC_S7(sp)
        sw      t8, IRQREC_T8(sp)
        sw      t9, IRQREC_T9(sp)
        sw      k0, IRQREC_K0(sp)
        sw      k1, IRQREC_K1(sp)
        sw      gp, IRQREC_S8(sp)
        sw      sp, IRQREC_SP(sp)
        sw      fp, IRQREC_S9(sp)
        sw      ra, IRQREC_RA(sp)
        # sw      zero, IRQREC_ZER(sp)
        mfhi    t0                      /* Save hi and lo               */
        mflo    t1
        sw      t0, IRQREC_HI(sp)
        sw      t1, IRQREC_LO(sp)

	mfc0    k0, c0_cause		/* save CAUSE and STATUS	*/
        mfc0    k1, c0_status
	sw      k0, IRQREC_CAUSE(sp)
        sw      k1, IRQREC_STATUS(sp)

	.set noreorder
dispatch:
	andi k0, k0, M_CauseIM   # Keep only IP bits from Cause
        and  k0, k0, k1          # and mask with STATUS's IM bits 
        srl  k0, k0, 10          # keep only 3 MS bits of IP (irq7..5)
        lui  k1, %hi(handlers_tbl) # plus displacement in j-table of 8 bytes
        ori  k1, k1, %lo(handlers_tbl)
        add  k1, k1, k0
	nop
        jr   k1
	nop
	
handlers_tbl:
        wait 0x18                 # no request: 000
	nop
	
        wait 0x19 # j extCounter  # lowest priority, IRQ5: 001
        nop

        j uart                    # mid priority, IRQ6: 01x
        nop
        j uart
        nop

        j clk			  # high priority, IRQ7: 1xx
	nop
        j clk
	nop
        j clk
	nop
        j clk
	nop


	##
	## code replicated from system/dispatch.c
	##
	# mask = disable();	/* Disable interrupts for duration */
uart:	addiu   sp, sp, -8	# make room in stack
        mfc0    v0, CP0_STATUS
        li      a0, ~STATUS_IE
        and     a1, v0, a0
	sw      v0, 4(sp)	# and save STATUS there
	
	# exlreset();		/* Reset system-wide exception bit */
	li      a2, ~STATUS_EXL
        and     v0, a1, a2
	mtc0    v0, CP0_STATUS
	
	# (*handler) ();	/* Invoke device-specific handler  */
	jal ttyInterrupt
	nop
	
	# exlset();		/* Set system-wide exception bit   */
	# restore(mask);
	lw      v0, 4(sp)	# recover saved STATUS
	addiu   sp, sp, 8
        li      a2, STATUS_EXL
        or      v0, v0, a2
        mtc0    v0, CP0_STATUS
	
	j   restore
	nop
	
clk:	jal clkhandler		  # clk handler MUST return to this address
	nop

restore:
        lw      t0, IRQREC_HI(sp)       /*  restore all state           */
        lw      t1, IRQREC_LO(sp)
        mthi    t0
        mtlo    t1
        lw      ra, IRQREC_RA(sp)       /* Restore general purpose regs */
        lw      fp, IRQREC_S9(sp)
        lw      gp, IRQREC_S8(sp)
        lw      t9, IRQREC_T9(sp)
        lw      t8, IRQREC_T8(sp)
        lw      s7, IRQREC_S7(sp)
        lw      s6, IRQREC_S6(sp)
        lw      s5, IRQREC_S5(sp)
        lw      s4, IRQREC_S4(sp)
        lw      s3, IRQREC_S3(sp)
        lw      s2, IRQREC_S2(sp)
        lw      s1, IRQREC_S1(sp)
        lw      s0, IRQREC_S0(sp)
        lw      t7, IRQREC_T7(sp)
        lw      t6, IRQREC_T6(sp)
        lw      t5, IRQREC_T5(sp)
        lw      t4, IRQREC_T4(sp)
        lw      t3, IRQREC_T3(sp)
        lw      t2, IRQREC_T2(sp)
        lw      t1, IRQREC_T1(sp)
        lw      t0, IRQREC_T0(sp)
        lw      a3, IRQREC_A3(sp)
        lw      a2, IRQREC_A2(sp)
        lw      a1, IRQREC_A1(sp)
        lw      a0, IRQREC_A0(sp)
        lw      v1, IRQREC_V1(sp)
        lw      v0, IRQREC_V0(sp)

        .set noreorder
        .set noat
        lw    k0, IRQREC_EPC(sp)        /* Restore interrupted PC value */
        lw    AT, IRQREC_AT(sp)         /* Restore assembler temp reg   */
        mtc0  k0, CP0_EPC

dismiss:
	lw    k0, IRQREC_STATUS(sp)     /* Restore global status reg    */
        addiu sp, sp, IRQREC_SIZE       /* Restore stack pointer        */
        ori   k0, k0, M_StatusIEn 
	mtc0  k0, CP0_STATUS
        eret                            /* Return from interrupt        */
	
	nop         # one needs to separate the WAIT from the ERET
	nop         #  WAIT is decoded and stops simulation before ERET
	nop         #  had time to execute and return to interrupted instrn.
	nop
	wait 0x1c   # Should never get to this point.  Abort simulation.
        .end _excp_0200
        #----------------------------------------------------------------


        .org x_EXCEPTION_BFC0,0
        .ent _excp_BFC0
_excp_BFC0:
        ##
        ##================================================================
        ## exception vector_BFC0 NMI or soft-reset
        ##
        .set noreorder
        .set noat

        la   k0, x_IO_BASE_ADDR
        mfc0 k1, CP0_CAUSE
        sw   k1, 0(k0)        # print CAUSE, flush pipe and stop simulation
        nop
        nop
        nop
        wait 0x1f             # signal exception and abort simulation
        nop
        .end _excp_BFC0
        ##---------------------------------------------------------------



        #----------------------------------------------------------------
        # delays processing by approx 4*a0 processor cycles
        .text
        .set    noreorder
        .global cmips_delay, delay_cycle, delay_us, delay_ms
        .ent    cmips_delay
delay_cycle:
cmips_delay:
        beq   a0, zero, _d_cye
        nop
_d_cy:  addiu a0, a0, -1
        nop
        bne   a0, zero, _d_cy
        nop
_d_cye: jr    ra
        nop
        .end    cmips_delay
        #----------------------------------------------------------------

        #================================================================
        # delays processing by a0 times 1 microsecond
        #   loop takes 5 cycles = 100ns @ 50MHz
        #   1.000ns / 100 = 10
        .text
        .set    noreorder
        .ent    delay_us
delay_us:
        beq   a0, zero, _d_use
        nop
        li    v0, 10
        mult  v0, a0
        nop
        mflo  a0
        sra   a0, a0, 1
_d_us:  addiu a0, a0, -1
        nop
        nop
        bne   a0, zero, _d_us
        nop
_d_use: jr    ra
        nop
        .end    delay_us
        #----------------------------------------------------------------

        #================================================================
        # delays processing by a0 times 1 mili second
        #   loop takes 5 cycles = 100ns @ 50MHz
        #   1.000.000ns / 100 = 10.000
        .text
        .set    noreorder
        .ent    delay_ms
delay_ms:
        beq   a0, zero, _d_mse
        nop
        li    v0, 10000
        mul   a0, v0, a0
        nop
_d_ms:  addiu a0, a0, -1
        nop
        nop
        bne   a0, zero, _d_ms
        nop
_d_mse: jr    ra
        nop
        .end    delay_ms
        #----------------------------------------------------------------


        ##
        ##================================================================
        ## put the interrupt and trap vectors here, at start of RAM
	##   see compile/ld.script for memory map
        ##
        ##===============================================================
        ## reserve first 1024 bytes for the exception/interrupt Vectors
        ##
	.global _EXCP_VEC, _endEXCP_VEC
	.global exceptionVector
	.global interruptVector
        .section .excp,"aw",@progbits

_EXCP_VEC:	
TRAPVEC_ADDR:
exceptionVector: .skip 0x0080,0

interruptVector: .skip 0x0040,0
IRQVEC_END:
_endEXCP_VEC:

