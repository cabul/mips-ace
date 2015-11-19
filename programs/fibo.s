; .text

00000000: 

addi $s0, $zero, 0xFFFF   // print int & exit
addi $s1, $zero, 0xFFFE   // write character
addi $s2, $zero, 0x200    // string base address
addi $sp, $zero, 0x300    // SP
addi $a0, $0, 5           // fib(5)
jal fib                   // fib(5)
lw $t0, 0($s2)            // load 4 bytes
andi $t1, $t0, 0xFF       // get first character in word
sw $t1, 0($s1)            // print
srl $t0, $t0, 8           // shift char
andi $t1, $t0, 0xFF       // get second character in word
sw $t1, 0($s1)            // print
srl $t0, $t0, 16          // shift char
andi $t1, $t0, 0xFF       // get third character in word
sw $t1, 0($s1)            // print
sw $v0, 0($s0)            // print
lw $zero, 0($s0)          // exit
nop
nop
nop
nop
fibo: 
	sw $t0, 0($sp)
	sw $ra, 4($sp)
	sw $a0, 12($sp)
	addi $sp, $sp, 12
	addi $t0, $0, 2
	beq $a0, $t0, fibo_trivial
	addi $a0, $a0, -1
	jal fib
	; guardar v0
	 
fibo_trivial: 
	addi $v0, $0, 1
	addi $sp, $sp, -12
	sw $a0, 8($sp)
	sw $ra, 4($sp)
	sw $t0, 0($sp)
	jr $ra
          
          

; .data

00000200: 00203a46        ; "F: "
00000208: 00000000        ; F[n]
          00000001        ; F[n+1]

; .stack 0x00000300
