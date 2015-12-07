.data
FILAS = 128
COLUMNAS = 128
T_ELEMENTO = 4

.align 2
vector_a:	.space FILAS*COLUMNAS*T_ELEMENTO
vector_b:	.space FILAS*COLUMNAS*T_ELEMENTO
vector_c:	.space FILAS*COLUMNAS*T_ELEMENTO

.text
main:	la $t0, vector_a
		la $t1, vector_b
		la $t2, vector_c
		li $t3, FILAS
		li $t4, COLUMNAS


		li $t5, 0 # i = 0
		
loop_i:	beq $t5, $t3, done_i
		li $t6, 0 # j = 0

loop_j:	beq $t6, $t4, done_j

		li $t7, 0 # k = 0
		li $s0, 0 # c[i][j]

loop_k:	beq $t7, $t4, done_k

        # Let's get a[i][k]
		mult $t5, $t4
		mflo $t8  # FILA * NCOLUMNAS
		add $t8, $t8, $t7 # (FILA * NCOLUMNAS)  +COLUMNA
		sll $t8, $t8, 2 # ((FILA * NCOLUMNAS)  +COLUMNA)* T_ELEMENTO
		add $t8, $t0, $t8 # @ + ((FILA * NCOLUMNAS) +COLUMNA)* T_ELEMENTO		
		lw $s1, 0($t8) # a[i][k]

		# Let's get b[k][j]
		mult $t7, $t4
		mflo $t8  # FILA * NCOLUMNAS
		add $t8, $t8, $t6 # (FILA * NCOLUMNAS)  +COLUMNA
		sll $t8, $t8, 2 # ((FILA * NCOLUMNAS)  +COLUMNA)* T_ELEMENTO
		add $t8, $t1, $t8 # @ + ((FILA * NCOLUMNAS) +COLUMNA)* T_ELEMENTO		
		lw $s2, 0($t8) # b[k][j]

		mult $s1, $s2 # a[i][k] * b[k][j]
		mflo $s1
		add $s0, $s0, $s1 # c[i][j] = c[i][j] + a[i][k] * b[k][j]

		addi $t7, $t7, 1 # k++
		b loop_k

done_k:	mult $t5, $t4
		mflo $t8  # FILA * NCOLUMNAS
		add $t8, $t8, $t6 # (FILA * NCOLUMNAS)  +COLUMNA
		sll $t8, $t8, 2 # ((FILA * NCOLUMNAS)  +COLUMNA)* T_ELEMENTO
		add $t8, $t2, $t8 # @ + ((FILA * NCOLUMNAS) +COLUMNA)* T_ELEMENTO

		sw $s0, 0($t8) # c[i][j] = c[i][j] + a[i][k] * b[k][j]
		
		addi $t6, $t6, 1 # j++
		b loop_j

done_j:	addi $t5, $t5, 1 # i++
		b loop_i

done_i: li $v0, 10
		syscall
