######################################################
#                                                    #
#            mipsACE minimal micro-kernel            #
#                                                    #
#  Master in Innovation and Research in Informatics  #
#                Processor Architecture              #
#                    2015 / 2016                     #
#                                                    #
######################################################

.kdata
__save_reg:                 .space 12
__exception_jumptable:      .word __int, __unimpl1, __unimpl2, __unimpl3, __AdEL, __AdES, __IBE, __DBE, __Sys, __Bp, __RI, __CpU, __Ov, __Tr, __unimpl4, __FPE

.ktext
	mfc0 $k0, $cause
	bne $k0, $0, __exception_handler
	
__entry_point:
	li $sp, %STACK_INIT             # Set stack-pointer
	mtc0 $0, $status                # Set machine to user-mode
	jal main
	sw $0, %IO_EXIT($0)

__exception_handler:
	la $k0, __save_reg
	sw $v0, 0($k0)                  # Not re-entrant and we can't trust $sp
	sw $a0, 4($k0)
	sw $ra, 8($k0)                  # But we need to use these registers
	mfc0 $k0, $cause                # Cause register
	srl $a0, $k0, 2                 # Extract ExcCode Field
	andi $a0, $a0, 0x1F
	sll $a0, $a0, 2
	la $v0, __exception_jumptable
	add $v0, $v0, $a0
	lw $v0, 0($v0)
	jr $v0                          # Switch exception table (see table below)

__CpU:
__Bp:
__FPE:
__int:
__Tr:
__unimpl1:
__unimpl2:
__unimpl3:
__unimpl4:
__AdEL:   
__AdES:
__IBE:
__DBE:
__Ov:
__RI:
__Sys:
__epc:
	mfc0 $a0, $epc
	andi $a0, $a0, 0x3              # Is EPC word-aligned?
	beq $a0, $0, __ret_exception
	sw $0, %IO_EXIT($0)             # Exit
__ret_exception:
	la $k0, __save_reg
	lw $v0, 0($k0)                  # Restore registers
	lw $a0, 4($k0)
	lw $ra, 8($k0)
    mtc0 $0, $cause                 # Clear cause
	mtc0 $0, $status                # Set machine to user-mode
	eret                            # Return

# Insert <main> here
