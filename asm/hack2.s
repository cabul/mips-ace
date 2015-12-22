	.text
main:
	la $a0, mystring
	li $v0, %PRINT_STRING
	syscall
	li $v0, %EXIT
	syscall

	.data
mystring: .asciiz "\033[33mHello\033[0m\n"
