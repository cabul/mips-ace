.data
#N_ELEMENTOS = 128
#T_ELEMENTO = 4
#.align 2
vector_a: .space 512 #N_ELEMENTOS*T_ELEMENTO
vector_b: .space 512 #N_ELEMENTOS*T_ELEMENTO

.text
main: 	la $t0, vector_a
		li $t1, 0 #Counter
		li $t2, 128 #N_ELEMENTOS
		li $t3, 5

#Let's initialize a
loop:	
		sw $t3, 0($t0)
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		bne $t1, $t2, loop

        la $t0, vector_a
		la $t1, vector_b
		li $t2, 0 #Counter
		li $t3, 128 #N_ELEMENTOS

#Let's initialize b
bloop:	
		lw $t4, 0($t0)
		sw $t4, 0($t1)
		addi $t0, $t0, 4
		addi $t1, $t1, 4
		addi $t2, $t2, 1
		bne $t2, $t3, bloop

        li $v0, 10
		syscall
