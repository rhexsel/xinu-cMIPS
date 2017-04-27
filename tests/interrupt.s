# to test the interrupt generator, uncomment the do_interrupt component
# in the testbench, and change the irq signal to connect it to the counter

	# mips-as -O0 -EL -mips32 -o start.o start.s
	.include "cMIPS.s"
	.text
	.align 2
	.extern main
	.global _start
	.global _exit
	.global exit
	.ent _start
	
	.set stdout_addr,  x_IO_BASE_ADDR
	.set counter_addr, x_IO_BASE_ADDR + (0x0020*10)
	.set counter_value, (0x00000020+0xC0000000)
_start: nop
	li $sp,(x_DATA_BASE_ADDR+x_DATA_MEM_SZ-8)  # initialize SP: memTop-8

        la   $k0, counter_addr
        li   $k1, counter_value                  # start counter, interr en
        sw   $k1, 0($k0)
        li   $k0, 0x18000f01   # RESET, kernel mode, interrupt enabled
        mtc0 $k0, cop0_STATUS
	nop
	jal main
	nop
exit:	
_exit:	nop	     # flush pipeline
	nop
	nop
	nop
	nop
	wait  # then stop VHDL simulation
	nop
	nop
	.end _start

	
	.org x_EXCEPTION_0180,0 # exception vector_180 at 0x00000060
	.global _excp_180
	.global excp_180
	.global _excp_200
	.global excp_200
	.ent _excp_180
excp_180:
_excp_180:
excp_200:
_excp_200:
	la   $k0, counter_addr
        li   $k1, counter_value   # restart counter & clear interrupt
        sw   $k1, 0($k0)
        li   $k0, 0x18000f01
        mtc0 $k0, cop0_STATUS
	eret
	.end _excp_180

#	.org (end_excp_180 + 0x10),0
#	.ent _excp_200
#excp_200:	
#_excp_200:	
#	eret
#	nop
#	.end _excp_200


main:	la  $s0, counter_addr
	la  $s4, stdout_addr
	li  $t0, 10
	nop
loop:	lw  $s1, 0($s0)
	nop
	nop
	nop
	sw  $s1, 0($s4)
	nop
	nop
	nop
	beq $t0, $zero, end
	nop
	nop
	nop
	addiu $t0, $t0, -1
	nop
	nop
	nop
	j   loop
	nop
	nop
end:	j exit
	nop
	
	.globl memcpy
        .ent memcpy
	# void *memcpy(void *dest $a0, const void *src $a1, size_t n $a2)
memcpy:
	move  $v0, $a0		# return dest
	andi  $v1, $a2, 0x3	# size MOD 4 == 0 ?
	bne   $v1, $zero, m_notWd
m_doit:	blez  $a2, m_done
	lw    $v1, 0($a1)
	addiu $a2, $a2, -4
	addiu $a1, $a1, 4
	sw    $v1, 0($a0)
	addiu $a0, $a0, 4
	j m_doit

m_done:	jr $ra
m_notWd: nop
	nop
	wait
	nop
	nop
	.end memcpy
