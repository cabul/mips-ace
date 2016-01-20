	.text
main:
	la $s1, value
	li $s2, 0x0A
loop:
	lb $t0, 0($s1)
	lb $t1, 1($s1)
	lb $t2, 2($s1)
	lb $t3, 3($s1)
	lb $t4, 4($s1)
	sw $t0, %IO_CHAR($0)
	sw $t1, %IO_CHAR($0)
	sw $t2, %IO_CHAR($0)
	sw $t3, %IO_CHAR($0)
	sw $t4, %IO_CHAR($0)
	beq $t4, $zero, exit
	addi $s1, $s1, 5
	sw $s2, %IO_CHAR($0)
	j loop
exit:
	sw $0, %IO_EXIT($0)

	.data
value: .asciiz "abcdefghijklmnopqrstuvwxy"
