.data
N_ELEMENTOS = 128
T_ELEMENTO = 4
.align 2
Vector: .space N_ELEMENTOS*T_ELEMENTO

.text
main:
	la $t0, Vector
	li $t1, 0 #Counter
	li $t2, N_ELEMENTOS

#Let's initialize
loop:	beq $t1, $t2, done
		sw $t1, 0($t0)
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		b loop

done:	la $t0, Vector
		li $t1, 0 #Counter
		li $t2, N_ELEMENTOS
		li $a0, 0 #Sum

#Summatory
sum:	beq $t1, $t2, out
		lw $t3, 0($t0)
		add $a0, $a0, $t3
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		b sum

#Show result and finish
out:	li $v0, 1
		syscall

		li $v0, 10
		syscall
