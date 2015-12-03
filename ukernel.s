######################################################
#                                                    #
#                mipsACE micro-kernel                #
#                                                    #
#  Master in Innovation and Research in Informatics  #
#                Processor Architecture              #
#                    2015 / 2016                     #
#                                                    #
######################################################

#.kdata
.data
str_exception:          .asciiz "Exception: "
str_unimplemented:      .asciiz "exception not implemented raised.\n"
save_reg:               .space 8
exception_jumptable:	.word int, unimpl1, unimpl2, unimpl3, AdEL, AdES, IBE, DBE, Sys, Bp, RI, CpU, Ov, Tr, unimpl4, FPE

#.ktext
.text
    li $s0, 9
    mtc0 $s0, $cause
    mfc0 $s1, $cause
    sw $0, %IO_EXIT($0)
    
    mfc0 $k0, $cause
    bne $k0, $0, exception_handler
    
entry_point:
    li $sp, 0x300               # Set stack-pointer
    li $k0, 12
    mtc0 $status, $0            # Set machine to user-mode
    jal main
    sw $0, %IO_EXIT($0)

exception_handler:
	la $k0, save_reg
	sw $v0, 0($k0)              # Not re-entrant and we can't trust $sp
	sw $a0, 4($k0)              # But we need to use these registers
    la $a0, str_exception
    jal kernel_strprint
    mfc0 $k0, $cause            # Cause register
    srl $a0, $k0, 2             # Extract ExcCode Field
    andi $a0, $a0, 0x1F
    sll $a0, $a0, 2
    la $v0, exception_jumptable
    add $v0, $v0, $a0
    lw $v0, 0($v0)
    jr $v0                      # Switch exception table (see table below)

	# 0  - Int Interrupt (hardware)
	# 4  - AdEL Address Error Exception (load or instruction fetch)
	# 5  - AdES Address Error Exception (store)
	# 6  - IBE Bus Error on Instruction Fetch
	# 7  - DBE Bus Error on Load or Store
	# 8  - Sys Syscall Exception
	# 9  - Bp Breakpoint Exception
	# 10 - RI Reserved Instruction Exception
	# 11 - CpU Coprocessor Unimplemented
	# 12 - Ov Arithmetic Overflow Exception
	# 13 - Tr Trap
	# 15 - FPE Floating Point Exception

CpU:
Bp:
FPE:
int:
Tr:
unimpl1:
unimpl2:
unimpl3:
unimpl4:
#
AdEL:
AdES:
IBE:
DBE:
Sys:
RI:
Ov:
#
    la $a0, str_unimplemented
    jal kernel_strprint
    j epc

epc:
    mfc0 $a0, $epc
    andi $a0, $a0, 0x3          # Is EPC word-aligned?
    beq $a0, $0, ret_exception
    sw $0, %IO_EXIT($0)         # Exit
ret_exception:
	la $k0, save_reg
	lw $v0, 0($k0)		        # Restore other registers
	lw $a0, 4($k0)
	mtc0 $0, $cause		        # Clear Cause register
	eret                        # Return

# Note that kernel functions do not save registers

kernel_strprint:
	lw $k0, 0($a0)
	andi $k1, $k0, 0xFF
	beq $k1, $0, kernel_strprint_ret
	sw $k1, %IO_CHAR($0)
	srl $k0, $k0, 8
	andi $k1, $k0, 0xFF
	beq $k1, $0, kernel_strprint_ret
	sw $k1, %IO_CHAR($0)
    srl $k0, $k0, 8
	andi $k1, $k0, 0xFF
	beq $k1, $0, kernel_strprint_ret
	sw $k1, %IO_CHAR($0)
    srl $k0, $k0, 8
	andi $k1, $k0, 0xFF
	beq $k1, $0, kernel_strprint_ret
	sw $k1, %IO_CHAR($0)
    addi $a0, $a0, 4
    j kernel_strprint
kernel_strprint_ret:
    jr $ra

main:
    #
    # <program needed>
    #
    
    jr $ra
