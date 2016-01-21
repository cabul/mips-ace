.text

main:
	li $t2, 25
	la $t4, value
	lw $t3, 0($t4)
	sw $t3, %IO_INT($0)
	sw $t2, 0($t4)
	lw $t3, 0($t4)
	sw $t3, %IO_INT($0)
	la $t4, other
	lw $t3, 0($t4)
	sw $t3, %IO_INT($0)

	sw $0, %IO_EXIT($0)

.data

value: .word 12
padding: .word 0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
other: .word 38
