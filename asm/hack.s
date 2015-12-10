	.text
main:
	la $s0, escape
	lw $s0, 0($s0)
	sw $s0, %IO_CHAR($0)
	la $a0, tored
	jal print_str
	la $a0, mystring
	jal print_str
	sw $s0, %IO_CHAR($0)
	la $a0, tonorm
	jal print_str
	sw $s0, %IO_CHAR($0)
	la $a0, clear
	jal print_str
	sw $s0, %IO_CHAR($0)
	la $a0, tohome
	jal print_str
	sw $0, %IO_EXIT($0)

print_str:
	lw $k0, 0($a0)
	andi $k1, $k0, 0xFF
	beq $k1, $0, print_str_ret
	sw $k1, %IO_CHAR($0)
	srl $k0, $k0, 8
	andi $k1, $k0, 0xFF
	beq $k1, $0, print_str_ret
	sw $k1, %IO_CHAR($0)
	srl $k0, $k0, 8
	andi $k1, $k0, 0xFF
	beq $k1, $0, print_str_ret
	sw $k1, %IO_CHAR($0)
	srl $k0, $k0, 8
	andi $k1, $k0, 0xFF
	beq $k1, $0, print_str_ret
	sw $k1, %IO_CHAR($0)
	addi $a0, $a0, 4
	j print_str
print_str_ret:
	jr $ra
	
	.data
escape: .byte 0x1B
tored: .asciiz "[31m"
tonorm: .asciiz "[0m"
mystring: .asciiz "Hello\n"
tohome: .asciiz "[H"
clear: .asciiz "[2J"
