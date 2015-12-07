.data
N_ELEMENTOS = 128
T_ELEMENTO = 4
.align 2
vector_a: .space N_ELEMENTOS*T_ELEMENTO
vector_b: .space N_ELEMENTOS*T_ELEMENTO

.text
main: 	la $t0, vector_a
		li $t1, 0 #Counter
		li $t2, N_ELEMENTOS
		li $t3, 5

#Let's initialize a
loop:	beq $t1, $t2, done
		sw $t3, 0($t0)
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		b loop

done: 	la $t0, vector_a
		la $t1, vector_b
		li $t2, 0 #Counter
		li $t3, N_ELEMENTOS

#Let's initialize b
bloop:	beq $t2, $t3, out
		lw $t4, 0($t0)
		sw $t4, 0($t1)
		addi $t0, $t0, 4
		addi $t1, $t1, 4
		addi $t2, $t2, 1
		b bloop

out: 	li $v0, 10
		syscall
