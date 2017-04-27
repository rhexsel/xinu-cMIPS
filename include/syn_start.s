	##
	##== synthesis version of startup code ===========================
	##
	##   simple startup code for synthesis

	.include "cMIPS.s"
	.text
	.set noreorder
	.align 2
	.extern main
	.global _start,_exit,exit
	.global _excp_0000, _excp_0100, _excp_0180, _excp_0200, _excp_BFC0

        .set MMU_WIRED,    2  ### do not change mapping for base of ROM, I/O
	
	.org x_INST_BASE_ADDR,0
	.ent _start

        ##
        ## reset leaves processor in kernel mode, all else disabled
        ##
_start:	nop
	li   $k0, 0x10000000
        mtc0 $k0, cop0_STATUS

        li   $k0, MMU_WIRED
        mtc0 $k0, cop0_Wired

        j main
        nop

exit:	
_exit:	j exit	  # wait forever
	nop
	.end _start
	

        .org x_EXCEPTION_0000,0
_excp_0000:
	la   $k0, HW_dsp7seg_addr  	# 7 segment display
	li   $k1, 0x0399		# display .9.9
	sw   $k1, 0($k0)		# write to 7 segment display
h0000:	j    h0000			# wait forever
	nop
	
        .org x_EXCEPTION_0100,0
_excp_0100:
	la   $k0, HW_dsp7seg_addr  	# 7 segment display
	li   $k1, 0x0388		# display .8.8
	sw   $k1, 0($k0)		# write to 7 segment display
h0100:	j    h0100			# wait forever
	nop
	
        .org x_EXCEPTION_0180,0
_excp_0180:
	la   $k0, HW_dsp7seg_addr  	# 7 segment display
	li   $k1, 0x0377		# display .7.7
	sw   $k1, 0($k0)		# write to 7 segment display
h0180:	j    h0180			# wait forever
	nop
	
        .org x_EXCEPTION_0200,0
_excp_0200:
	la   $k0, HW_dsp7seg_addr  	# 7 segment display
	li   $k1, 0x0366		# display .6.6
	sw   $k1, 0($k0)		# write to 7 segment display
h0200:	j    h0200			# wait forever
	nop
	
        .org x_EXCEPTION_BFC0,0
_excp_BFC0:
	la   $k0, HW_dsp7seg_addr  	# 7 segment display
	li   $k1, 0x0355		# display .5.5
	sw   $k1, 0($k0)		# write to 7 segment display
hBFC0:	j    hBFC0			# wait forever
	nop

	##================================================================

	##
	##===============================================================
	## main(), normal code starts below -- do not edit next line
	.org x_ENTRY_POINT,0

