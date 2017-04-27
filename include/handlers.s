	# interrupt handlers
	.include "cMIPS.s"
	.text
	.set noreorder
        .align 2

	.set M_StatusIEn,0x0000ff09     # STATUS.intEn=1, user mode
	
	#----------------------------------------------------------------
	# interrupt handler for external counter attached to IP5=HW3
	# for extCounter address see vhdl/packageMemory.vhd

	.bss
	.align  2
	.set noreorder
	.global _counter_val             # accumulate number of interrupts
	.comm   _counter_val 4
	.comm   _counter_saves 8*4       # area to save up to 8 registers
	# _counter_saves[0]=$a0, [1]=$a1, [2]=$a2, ...
	
	.set HW_counter_value,0xc00000c8 # Count 200 clock pulses & interr

	.text
	.set    noreorder
	.global extCounter
	.ent    extCounter

extCounter:
	lui   $k0, %hi(HW_counter_addr)
	ori   $k0, $k0, %lo(HW_counter_addr)
	sw    $zero, 0($k0) 	# Reset counter, remove interrupt request

	#----------------------------------
	# save additional registers
	# lui $k1, %hi(_counter_saves)
	# ori $k1, $k1, %lo(_counter_saves)
	# sw  $a0, 0*4($k1)
	# sw  $a1, 1*4($k1)
	#----------------------------------
	
	lui   $k1, %hi(HW_counter_value)
	ori   $k1, $k1, %lo(HW_counter_value)
	sw    $k1, 0($k0)	      # Reload counter so it starts again

	lui   $k0, %hi(_counter_val)  # Increment interrupt event counter
	ori   $k0, $k0, %lo(_counter_val)
	lw    $k1,0($k0)
	nop
	addiu $k1,$k1,1
	sw    $k1,0($k0)

	#----------------------------------
	# and then restore those same registers
	# lui $k1, %hi(_counter_saves)
	# ori $k1, $k1, %lo(_counter_saves)
	# lw  $a0, 0*4($k1)
	# lw  $a1, 1*4($k1)
	#----------------------------------
	
	eret			    # Return from interrupt
	.end extCounter
	#----------------------------------------------------------------

	
	#----------------------------------------------------------------
	# interrupt handler for UART attached to IP6=HW4

	.bss 
        .align  2
	.set noreorder
	.global Ud

        .equ RXHD,0
        .equ RXTL,4
        .equ RX_Q,8
        .equ TXHD,24
        .equ TXTL,28
        .equ TXQ,32
        .equ NRX,48
        .equ NTX,52
	
Ud:
rx_hd:  .space 4        # reception queue head index
rx_tl:  .space 4        # tail index
rx_q:   .space 16       # reception queue
tx_hd:  .space 4        # transmission queue head index
tx_tl:  .space 4        # tail index
tx_q:   .space 16       # transmission queue
nrx:    .space 4        # characters in RX_queue
ntx:    .space 4        # spaces left in TX_queue

_uart_buff: .space 16*4 # up to 16 registers to be saved here
        # _uart_buff[0]=UARTstatus, [1]=UARTcontrol, [2]=$v0, [3]=$v1,
        #           [4]=$ra, [5]=$a0, [6]=$a1, [7]=$a2, [8]=$a3

        .set U_rx_irq,0x08
        .set U_tx_irq,0x10

        .equ UCTRL,0    # UART registers
        .equ USTAT,4
        .equ UINTER,8
        .equ UDATA,12

	.text
	.set    noreorder
	.global UARTinterr
	.ent    UARTinterr

UARTinterr:

        #----------------------------------------------------------------
        # While you are developing the complete handler, uncomment the
        #   line below
        #
        # .include "../tests/handlerUART.s"
        #
        # Your new handler should be self-contained and do the
        #   return-from-exception.  To do that, copy the lines below up
        #   to, but excluding, ".end UARTinterr", to yours handlerUART.s.
        #----------------------------------------------------------------

        lui   $k0, %hi(_uart_buff)  # get buffer's address
        ori   $k0, $k0, %lo(_uart_buff)

        sw    $a0, 5*4($k0)         # save registers $a0,$a1, others?
        sw    $a1, 6*4($k0)
        sw    $a2, 7*4($k0)

        lui   $a0, %hi(HW_uart_addr)# get device's address
        ori   $a0, $a0, %lo(HW_uart_addr)

        lw    $k1, USTAT($a0)       # Read status
        sw    $k1, 0*4($k0)         #  and save UART status to memory

        li    $a1, U_rx_irq         # remove interrupt request
        sw    $a1, UINTER($a0)

        and   $a1, $k1, $a1         # Is this reception?
        beq   $a1, $zero, UARTret   #   no, ignore it and return
        nop

        # handle reception
        lw    $a1, UDATA($a0)       # Read data from device

        lui   $a2, %hi(Ud)          # get address for data & flag
        ori   $a2, $a2, %lo(Ud)

        sw    $a1, 0*4($a2)         #   and return from interrupt
        addiu $a1, $zero, 1
        sw    $a1, 1*4($a2)         # set flag to signal new arrival 

UARTret:
        lw    $a2, 7*4($k0)
        lw    $a1, 6*4($k0)         # restore registers $a0,$a1, others?
        lw    $a0, 5*4($k0)

        eret                        # Return from interrupt
        .end UARTinterr
	#----------------------------------------------------------------

	
	#----------------------------------------------------------------
	# handler for COUNT-COMPARE registers -- IP7=HW5
	.text
	.set    noreorder
        .equ    num_cycles, 64
	.global countCompare
	.ent    countCompare
countCompare:	
        mfc0  $k1,c0_count       # read COUNT
        addiu $k1,$k1,num_cycles # set next interrupt in so many ticks
        mtc0  $k1,c0_compare     # write to COMPARE to clear IRQ

        eret                     # Return from interrupt
	.end countCompare
	#----------------------------------------------------------------

	
        #================================================================
        # startCount enables the COUNT register, returns new CAUSE
        #   CAUSE.dc <= 0 to enable counting
        #----------------------------------------------------------------
        .text
        .set    noreorder
        .global startCount
        .ent    startCount
startCount:
        mfc0 $v0, c0_cause
        lui  $v1, 0xf7ff
        ori  $v1, $v1, 0xffff
        and  $v0, $v0, $v1
        mtc0 $v0, c0_cause
        ehb
        jr   $ra
        nop
        .end    startCount
        #----------------------------------------------------------------


        #================================================================
        # stopCount disables the COUNT register, returns new CAUSE
        #   CAUSE.dc <= 1 to disable counting
        #----------------------------------------------------------------
        .text
        .set    noreorder
        .global stopCount
        .ent    stopCount
stopCount:
        mfc0 $v0, c0_cause
        lui  $v1, 0x0800
        or   $v0, $v0, $v1
        jr   $ra
        mtc0 $v0, c0_cause
        .end    stopCount
        #----------------------------------------------------------------


        #================================================================
        # readCount returns the value of the COUNT register
        #----------------------------------------------------------------
        .text
        .set    noreorder
        .global readCount
        .ent    readCount
readCount:
        mfc0 $v0, c0_count
        jr   $ra
        nop
        .end    readCount
        #----------------------------------------------------------------

	
	#----------------------------------------------------------------
	# functions to enable and disable interrupts, both return STATUS
	.text
	.set    noreorder
	.global enableInterr,disableInterr
	.ent    enableInterr
enableInterr:
	mfc0  $v0, c0_status	    # Read STATUS register
	ori   $v0, $v0, 1           #   and enable interrupts
	mtc0  $v0, c0_status
	ehb
	jr    $ra                   # return updated STATUS
	nop
	.end enableInterr

	.ent disableInterr
disableInterr:
	mfc0  $v0, c0_status	    # Read STATUS register
	addiu $v1, $zero, -2        #   and disable interrupts
	and   $v0, $v0, $v1         # -2 = 0xffff.fffe
	mtc0  $v0, c0_status
	ehb
	jr    $ra                   # return updated STATUS
	nop
	.end disableInterr
	#----------------------------------------------------------------


	#----------------------------------------------------------------	
	# delays processing by approx 4*$a0 processor cycles
	.text
	.set    noreorder
	.global cmips_delay, delay_cycle, delay_us, delay_ms
	.ent    cmips_delay
delay_cycle:
cmips_delay:
        beq   $a0, $zero, _d_cye
        nop
_d_cy:  addiu $a0, $a0, -1
        nop
        bne   $a0, $zero, _d_cy
        nop
_d_cye: jr    $ra
        nop
        .end    cmips_delay
	#----------------------------------------------------------------

        #================================================================
        # delays processing by $a0 times 1 microsecond
        #   loop takes 5 cycles = 100ns @ 50MHz
        #   1.000ns / 100 = 10
        .text
        .set    noreorder
        .ent    delay_us
delay_us:
        beq   $a0, $zero, _d_use
        nop
        li    $v0, 10
        mult  $v0, $a0
        nop
        mflo  $a0
        sra   $a0, $a0, 1
_d_us:  addiu $a0, $a0, -1
        nop
        nop
        bne   $a0, $zero, _d_us
        nop
_d_use: jr    $ra
        nop
        .end    delay_us
        #----------------------------------------------------------------


        #================================================================
        # delays processing by $a0 times 1 mili second
        #   loop takes 5 cycles = 100ns @ 50MHz
        #   1.000.000ns / 100 = 10.000
        .text
        .set    noreorder
        .ent    delay_ms
delay_ms:
        beq   $a0, $zero, _d_mse
        nop
        li    $v0, 10000
        mul   $a0, $v0, $a0
        nop
_d_ms:  addiu $a0, $a0, -1
        nop
        nop
        bne   $a0, $zero, _d_ms
        nop
_d_mse: jr    $ra
        nop
        .end    delay_ms
        #----------------------------------------------------------------


