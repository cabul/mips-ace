	.text
main:
	la $a0, quest
	li $v0, %PRINT_STR
	syscall
	li $v0, %READ_INT
	syscall
	move $t0, $v0
	la $a0, answer
	li $v0, %PRINT_STR
	syscall
	move $a0, $t0
	li $v0, %PRINT_INT
	syscall
	li $a0, 0x0A
	li $v0, %PRINT_CHAR
	syscall
	li $v0, %EXIT
	syscall

	.data 
quest: .asciiz "Write a number: "
answer: .asciiz "You wrote: "

