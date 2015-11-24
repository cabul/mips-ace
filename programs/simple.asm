	.text
main:
	la $t0, value
	li $s0, 0xFFFF
loop:
	lw $t1, 0($t0)
	sw $t1, 0($s0)
	beq $t1, $zero, exit
	addi $t0, $t0, 4
	j loop
exit:
	lw $zero, 0($s0)

	.data
value: .word 3, 2, 1, 0
