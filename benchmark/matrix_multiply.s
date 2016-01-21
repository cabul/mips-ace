.data
#FILAS = 16
#COLUMNAS = 16
#T_ELEMENTO = 4

matrix_a: .space 1024
matrix_b: .space 1024
matrix_c: .space 1024 # 16 * 16 * 4

.text
main:	la $t0, matrix_a
		la $t1, matrix_b
		la $t2, matrix_c
		li $t3, 16 #FILAS
		li $t4, 16 #COLUMNAS

		li $t5, 0 # i = 0
		
loop_i:	
		li $t6, 0 # j = 0

loop_j:	
		li $t7, 0 # k = 0
		li $s0, 0 # c[i][j]

loop_k:	
        # Let's get a[i][k]
		mul $t8, $t5, $t4 # FILA * NCOLUMNAS
		add $t8, $t8, $t7 # (FILA * NCOLUMNAS)  +COLUMNA
		sll $t8, $t8, 2 # ((FILA * NCOLUMNAS)  +COLUMNA)* T_ELEMENTO
		add $t8, $t0, $t8 # @ + ((FILA * NCOLUMNAS) +COLUMNA)* T_ELEMENTO		
		lw $s1, 0($t8) # a[i][k]
        
		# Let's get b[k][j]
		mul $t8, $t7, $t4  # FILA * NCOLUMNAS  
		add $t8, $t8, $t6 # (FILA * NCOLUMNAS)  +COLUMNA
		sll $t8, $t8, 2 # ((FILA * NCOLUMNAS)  +COLUMNA)* T_ELEMENTO
		add $t8, $t1, $t8 # @ + ((FILA * NCOLUMNAS) +COLUMNA)* T_ELEMENTO		
		lw $s2, 0($t8) # b[k][j]
        
		mul $s1, $s1, $s2 # a[i][k] * b[k][j]
		add $s0, $s0, $s1 # c[i][j] = c[i][j] + a[i][k] * b[k][j]
        
		addi $t7, $t7, 1 # k++
		bne $t7, $t4, loop_k

done_k:	mul $t8, $t5, $t4 # FILA * NCOLUMNAS
		add $t8, $t8, $t6 # (FILA * NCOLUMNAS)  +COLUMNA
		sll $t8, $t8, 2 # ((FILA * NCOLUMNAS)  +COLUMNA)* T_ELEMENTO
		add $t8, $t2, $t8 # @ + ((FILA * NCOLUMNAS) +COLUMNA)* T_ELEMENTO

		sw $s0, 0($t8) # c[i][j] = c[i][j] + a[i][k] * b[k][j]
		
		addi $t6, $t6, 1 # j++
		beq $t6, $t4, loop_j

done_j:	addi $t5, $t5, 1 # i++
		bne $t5, $t3, loop_i

done_i: li $v0, 10
		syscall
