	.text
main:
	la $s0, quest
	li $s1, 0x0A
ask:
	lw $t0, 0($s0)
	andi $t1, $t0, 0xFF
	beq $t1, $0, read
	sw $t1, %IO_CHAR($0) # 0
	srl $t0, $t0, 8
	andi $t1, $t0, 0xFF
	beq $t1, $0, read
	sw $t1, %IO_CHAR($0) # 1
	srl $t0, $t0, 8
	andi $t1, $t0, 0xFF
	beq $t1, $0, read
	sw $t1, %IO_CHAR($0) # 2
	srl $t0, $t0, 8
	andi $t1, $t0, 0xFF
	beq $t1, $0, read
	sw $t1, %IO_CHAR($0) # 3
	addi $s0, $s0, 4
	j ask
read:
	lw $t2, %IO_INT($0)
print:
	sw $t2, %IO_INT($0)
	sw $s1, %IO_CHAR($0) # \n
exit:
	sw $0, %IO_EXIT($0)

	.data 
quest: .asciiz "Write a number: "

