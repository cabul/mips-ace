.text
main:
	addi $s0, $zero, 0xFFF   
	addi $s1, $zero, 0xFFE   
	la $s2, mystr
loop:
	lw $t0, 0($s2)   
	beq $t0, $0, exit         
	addi $s2, $s2, 4          
	andi $t1, $t0, 0xFF       
	srl $t0, $t0, 8           
	andi $t1, $t0, 0xFF       
	srl $t0, $t0, 8           
	andi $t1, $t0, 0xFF       
	srl $t0, $t0, 8           
	andi $t1, $t0, 0xFF       
	j loop 
exit:
	li $v0, 10
	syscall

.data

mystr: .asciiz "ACE Kernel 0.1\n"
