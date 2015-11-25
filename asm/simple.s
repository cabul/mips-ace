	.text
main:
	la $t0, value
loop:
	lw $t1, 0($t0)
	sw $t1, 0xFFF0($0)
	beq $t1, $0, exit
	addi $t0, $t0, 4
	j loop
exit:
	sw $0, 0xFFFF($0)

	.data
value: .word 3, 2, 1, 0
