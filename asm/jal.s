; .text

addi $s0, $zero, 0xFFFF   // print int & exit
addi $s1, $zero, 0xFFFE   // write character
addi $s2, $zero, 0x200    // string base address
addi $a0, $0, 0x69        // print(0x69)
jal print                 // print(0x69)
lw $zero, 0($s0)          // exit
nop
nop
nop
nop
print: 
	lw $t0, 0($s2)            // load 4 bytes
	andi $t1, $t0, 0xFF       // get first character in word
	sw $t1, 0($s1)            // print
	srl $t0, $t0, 8           // shift char
	andi $t1, $t0, 0xFF       // get second character in word
	sw $t1, 0($s1)            // print
	srl $t0, $t0, 8           // shift char
	andi $t1, $t0, 0xFF       // get third character in word
	sw $t1, 0($s1)            // print
	srl $t0, $t0, 8           // shift char
	andi $t1, $t0, 0xFF       // get fourth character in word
	sw $t1, 0($s1)            // print
	sw $a0, 0($s0)            // print
	jr $ra
          
; .data

00000200: 0a216b4f        ; "Ok!\n"

; .stack 0x00000300
