	.text
main:
	la $t0, value
	li $s0, 0x0A
loop:
	lw $t1, 0($t0)
	addi $t2, $t1, 48
	sw $t2, %IO_CHAR($0)
	beq $t1, $zero, exit
	addi $t0, $t0, 4
	j loop
exit:
	sw $s0, %IO_CHAR($0)
	sw $0, %IO_EXIT($0)

	.data
value: .word 3, 2, 1, 0
