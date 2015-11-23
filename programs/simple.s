	.text
main:
	li $s0, 0xFFFF
	la $t0, value
loop:
	lw $t1, 0($t0)
	sw $t1, 0($s0)
	beq $t0, $zero, exit
	addi $t0, $t0, 4
exit:
	lw $zero, 0($s0)

	.data
value: .word 3, 2, 1, 0
