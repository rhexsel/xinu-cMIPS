	##
	##== simulation version of startup code ==========================
	##

	.include "cMIPS.s"
	.text
	.set noreorder
	.align 2
	.extern main
	.global _start,_exit,exit
	.global _excp_0000, _excp_0100, _excp_0180, _excp_0200, _excp_BFC0
	
	.org x_INST_BASE_ADDR,0
	.ent _start

        ##
        ## reset leaves processor in kernel mode, all else disabled
        ##
_start:
	# get physical page number for 2 pages at the bottom of RAM, for .data
	#  needed so simulations without a page table will not break
	#  read TLB[4] and write it to TLB[2]
	li    $k0, 4
	mtc0  $k0, c0_index
	ehb
	tlbr
	li    $k1, 2
	mtc0  $k1, c0_index
	ehb
	tlbwi
	

	#  then set another mapping onto TLB[4], to avoid replicated entries
	li    $a0, ( (x_DATA_BASE_ADDR + 8*4096) >>12 )
	sll   $a2, $a0, 12	# tag for RAM[8,9] double-page
	mtc0  $a2, c0_entryhi

	li    $a0, ((x_DATA_BASE_ADDR + 8*4096) >>12 )
	sll   $a1, $a0, 6	# RAM[8] (even)
	ori   $a1, $a1, 0b00000000000000000000000000000111 # ccc=0, d,v,g1
	mtc0  $a1, c0_entrylo0

	li    $a0, ( (x_DATA_BASE_ADDR + 9*4096) >>12 )
	sll   $a1, $a0, 6	# RAM[9] (odd)
	ori   $a1, $a1, 0b00000000000000000000000000000111 # ccc=0, d,v,g1
	mtc0  $a1, c0_entrylo1

	# and write it to TLB[4]
	li    $k0, 4
	mtc0  $k0, c0_index
	tlbwi 

	
	# get physical page number for two pages at the top of RAM, for stack
	li    $a0, ( (x_DATA_BASE_ADDR+x_DATA_MEM_SZ - 2*4096) >>12 )
	sll   $a2, $a0, 12	# tag for top double-page
	mtc0  $a2, c0_entryhi

	li    $a0, ( (x_DATA_BASE_ADDR+x_DATA_MEM_SZ - 2*4096) >>12 )
	sll   $a1, $a0, 6	# top page - 2 (even)
	ori   $a1, $a1, 0b00000000000000000000000000000111 # ccc=0, d,v,g1
	mtc0  $a1, c0_entrylo0

	li    $a0, ( (x_DATA_BASE_ADDR+x_DATA_MEM_SZ - 1*4096) >>12 )
	sll   $a1, $a0, 6	# top page - 1 (odd)
	ori   $a1, $a1, 0b00000000000000000000000000000111 # ccc=0, d,v,g1
	mtc0  $a1, c0_entrylo1

	# and write it to TLB[3]
	li    $k0, 3
	mtc0  $k0, c0_index
	tlbwi 

	# pin down first four TLB entries: ROM[0], RAM[0], stack and I/O
	li   $k0, 4
	mtc0 $k0, c0_wired

	# initialize SP at top of RAM: ramTop - 8
	li   $sp, ((x_DATA_BASE_ADDR+x_DATA_MEM_SZ) - 8)
	
	# set STATUS, cop0, hw interrupt IRQ7,IRQ6,IRQ5 enabled, user mode
        li   $k0, 0x1000e011
        mtc0 $k0, c0_status

	jal  main # on returning from main(), MUST go into exit()
	nop       #   to stop the simulation.
exit:	
_exit:	nop	  # flush pipeline
	nop
	nop
	nop
	nop
	wait 0    # then stop VHDL simulation
	nop
	nop
	.end _start
	##----------------------------------------------------------------



	##
	##================================================================
	## exception vector_0000 TLBrefill, from See MIPS Run pg 145
	##
	.org x_EXCEPTION_0000,0
	.ent _excp_0000
_excp_0000:
	.set noreorder
	.set noat

	mfc0 $k1, c0_context
	lw   $k0, 0($k1)           # k0 <- TP[Context.lo]
	lw   $k1, 8($k1)           # k1 <- TP[Context.hi]
	mtc0 $k0, c0_entrylo0    # EntryLo0 <- k0 = even element
	mtc0 $k1, c0_entrylo1    # EntryLo1 <- k1 = odd element
	ehb
	tlbwr	                   # update TLB
	eret	
	.end _excp_0000

	
	##
	##================================================================
	## exception vector_0100 Cache Error (hw not implemented)
	##   print CAUSE and stop simulation
	##
	.org x_EXCEPTION_0100,0
	.ent _excp_0100
_excp_0100:
	.set noreorder
	.set noat

	la   $k0, x_IO_BASE_ADDR
	mfc0 $k1, c0_cause
	sw   $k1, 0($k0)	# print CAUSE, flush pipe and stop simulation
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
	## area to save up to 16 registers
        .bss
        .align  2
        .comm   _excp_saves 16*4
        # _excp_saves[0]=CAUSE, [1]=STATUS, [2]=ASID,
	#            [8]=$ra, [9]=$a0, [10]=$a1, [11]=$a2, [12]=$a3
	#            [13]=$sp [14]=$fp [15]=$at 
        .text
        .set noreorder
	.set noat
	.org x_EXCEPTION_0180,0  # exception vector_180
	.ent _excp_0180
_excp_0180:
	mfc0 $k0, c0_status
	lui  $k1, %hi(_excp_saves)
	ori  $k1, $k1, %lo(_excp_saves)
	sw   $k0, 1*4($k1)
        mfc0 $k0, c0_cause
	sw   $k0, 0*4($k1)
	
	andi $k0, $k0, 0x3f    # keep only the first 16 ExceptionCodes & b"00"
	sll  $k0, $k0, 1       # displacement in vector is 8 bytes
	lui  $k1, %hi(excp_tbl)
        ori  $k1, $k1, %lo(excp_tbl)
	add  $k1, $k1, $k0
	jr   $k1
	nop

excp_tbl: # see Table 8-25, pg 95,96
	wait 0x02  # interrupt, should never arrive here, abort simulation
	nop

	j h_Mod  # 1
	nop

	j h_TLBL # 2
	nop

	j h_TLBS # 3
	nop

	wait 0x04  # 4 AdEL addr error     -- abort simulation
	nop
	wait 0x05  # 5 AdES addr error     -- abort simulation
	nop
	wait 0x06  # 6 IBE addr error      -- abort simulation
	nop
	wait 0x07  # 7 DBE addr error      -- abort simulation
	nop

	j h_syscall # 8
	nop

	j h_breakpoint # 9
	nop

	j h_RI    # 10 reserved instruction
	nop

	j h_CpU   # 11 coprocessor unusable
	nop

	j h_Ov    # 12 overflow
	nop

	wait 0x0d # 13 trap                             -- abort simulation
	nop
	
	wait 0x0e # reserved, should never get here     -- abort simulation
	nop
	
	wait 0x0f # FP exception, should never get here -- abort simulation
	nop

	
h_Mod:
h_TLBL:
h_TLBS:	
h_syscall:
h_breakpoint:
h_RI:
h_CpU:
h_Ov:
	
excp_0180ret:
	lui  $k1, %hi(_excp_saves) # Read previous contents of STATUS
	ori  $k1, $k1, %lo(_excp_saves)
	lw   $k0, 1*4($k1)
	# mfc0 $k0, c0_status
	
	lui  $k1, 0xffff           #  and do not modify its contents
	ori  $k1, $k1, 0xfff1      #  except for re-enabling interrupts
	ori  $k0, $k0, M_StatusIEn #  and keeping user/kernel mode
	and  $k0, $k1, $k0         #  as it was on exception entry 
	mtc0 $k0, c0_status	
	eret			   # Return from exception

	.end _excp_0180
	#----------------------------------------------------------------

	##
	##===============================================================
	## interrupt handlers at exception vector 0200
	##
	# declare all handlers here, these must be in file handlers.s
	.extern countCompare  # IRQ7 = hwIRQ5, Cop0 counter
	.extern UARTinterr    # IRQ6 - hwIRQ4, see vhdl/tb_cMIPS.vhd
	.extern extCounter    # IRQ5 - hwIRQ3, see vhdl/tb_cMIPS.vhd

	.set M_CauseIM,0x0000ff00   # keep bits 15..8 -> IM = IP
	.set M_StatusIEn,0x0000ff01 # user mode, enable all interrupts

	.set noreorder
	
	.org x_EXCEPTION_0200,0     # exception vector_200, interrupt handlers
	.ent _excp_0200
excp_0200:
_excp_0200:
	mfc0 $k0, c0_cause
	andi $k0, $k0, M_CauseIM   # Keep only IP bits from Cause
	mfc0 $k1, c0_status
	and  $k0, $k0, $k1         # and mask with IM bits 

	srl  $k0, $k0, 10	   # keep only 3 MS bits of IP (irq7..5)
	lui  $k1, %hi(handlers_tbl) # plus displacement in j-table of 8 bytes
	ori  $k1, $k1, %lo(handlers_tbl)
	add  $k1, $k1, $k0
	jr   $k1
	nop

handlers_tbl:
	j Dismiss		   # no request: 000
	nop

	j extCounter		   # lowest priority, IRQ5: 001
	nop	

	j UARTinterr		   # mid priority, IRQ6: 01x
	nop
	j UARTinterr
	nop

	j countCompare             # highest priority, IRQ7: 1xx
	nop
	j countCompare
	nop
	j countCompare
	nop
	j countCompare
	nop


Dismiss: # No pending request, must have been noise
	 #  do nothing and return

excp_0200ret:
	#mfc0 $k0, c0_status	   # Read STATUS register
	#addi $k1, $zero, -15       #  and do not modify its contents -15=fff1
	#ori  $k0, $k0, M_StatusIEn #  except for re-enabling interrupts
	#and  $k0, $k1, $k0         #  and keeping user/kernel mode
	#mtc0 $k0, c0_status      #  as it was on interrupt entry 	
	eret			   # Return from interrupt
	nop

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

	la   $k0, x_IO_BASE_ADDR
	mfc0 $k1, c0_cause
	sw   $k1, 0($k0)	# print CAUSE, flush pipe and stop simulation
	nop
	nop
	nop
	wait 0xff		# signal exception and abort simulation
	nop
	.end _excp_BFC0
	##---------------------------------------------------------------

	
	##
	##===============================================================
	## main(), normal code starts below -- do not edit next line
	.org x_ENTRY_POINT,0


	##
	##===============================================================
	## reserve first two pages for the Page Table
	##

#	.section .TP,"aw",@progbits
#_TP:	.skip (2*4096), 0
#_endTP:
	



