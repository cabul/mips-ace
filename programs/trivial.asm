.text
main:	li $t0, 0
		li $t1, 10
		li $t2, 0
		li $t3, 1		
		li $t4, 0
		li $t5, 0

loop:	beq $t0, $t1, out
		add $t2, $t2, $t3
		add $t4, $t3, $t2
		add $t3, $t2, $t4
		xor $t5, $t5, $t4
		addi $t0, $t0, 1

out:	li $v0, 10
		syscall

.data
