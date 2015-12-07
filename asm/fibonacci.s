# Fibonacci testbench

	.text

main:
	la $s0, info
	li $sp, 0x300
	li $a0, 6 
	jal fibonacci
	lw $t1, 0($s0)
	andi $t0, $t1, 0xFF
	sw $t0, %IO_CHAR($0) # 0
	srl $t1, $t1, 8
	andi $t0, $t1, 0xFF
	sw $t0, %IO_CHAR($0) # 1
	srl $t1, $t1, 8
	andi $t0, $t1, 0xFF
	sw $t0, %IO_CHAR($0) # 2
	srl $t1, $t1, 8
	andi $t0, $t1, 0xFF
	sw $v0, %IO_INT($0)
	sw $t0, %IO_CHAR($0) # 3
	sw $0, %IO_EXIT($0)

fibonacci:
	sw $t0, 0($sp)
	sw $ra, 4($sp)
	sw $a0, 8($sp)
	addi $sp, $sp, 12
	ori $t0, $zero, 2
	slt $t0, $a0, $t0
	bne $t0, $0, fibonacci_base
	addi $a0, $a0, -1
	jal fibonacci
	move $t0, $v0
	addi $a0, $a0, -1
	jal fibonacci
	add $v0, $v0, $t0

fibonacci_exit:
	addi $sp, $sp, -12
	lw $a0, 8($sp)
	lw $ra, 4($sp)
	lw $t0, 0($sp)
	jr $ra

fibonacci_base:
	ori $v0, $zero, 1
	j fibonacci_exit

	.data
info: .ascii "F: \n"
