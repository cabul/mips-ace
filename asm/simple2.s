	.text
main:
	la $s0, newval
	la $s1, value
	li $s2, 0x0A
loop:
	lb $t0, 0($s0)
	sb $t0, 0($s1)
	lb $t1, 0($s1)
	sw $t1, %IO_CHAR($0)
	beq $t1, $zero, exit
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	j loop
exit:
	sw $s2, %IO_CHAR($0)
	sw $0, %IO_EXIT($0)

	.data
newval: .asciiz "xyz"
value: .asciiz "abc"
