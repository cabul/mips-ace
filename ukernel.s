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
str_exception:  .asciiz "[Exception] "
save_reg:       .word 0, 0 # .space 8 not working, right? imsad.png
save_print:     .word 0, 0

#.ktext
.text
    li $k0, 13
    li $k0, 0 # mfc0 $k0, $k0 # what the hell is going on dude
    bne $k0, $0, exception_handler
    
entry_point:
    li $sp, 0x300
    jal main
    sw $0, %IO_EXIT($0)

exception_handler:
	la $k0, save_reg
	sw $v0, 0($k0)          # Not re-entrant and we can't trust $sp
	sw $a0, 4($k0)          # But we need to use these registers
    la $a0, str_exception
    jal kernel_strprint
    sw $0, %IO_EXIT($0)     # I give up

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
