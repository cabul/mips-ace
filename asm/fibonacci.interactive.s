# Fibonacci testbench

	.text
main:
	la $a0, quest
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	move $a0, $v0
	jal fibonacci
	move $t0, $v0
	la $a0, info
	li $v0, 4
	syscall
	move $a0, $t0
	li $v0, 1
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	li $v0, 10
	syscall

fibonacci:
	sw $t0, 0($sp)
	sw $ra, -4($sp)
	sw $a0, -8($sp)
	addi $sp, $sp, -12
	ori $t0, $zero, 2
	slt $t0, $a0, $t0
	bne $t0, $0, fibonacci_base
	addi $a0, $a0, -1
	jal fibonacci
	move $t0, $v0
	addi $a0, $a0, -1
	jal fibonacci
	add $v0, $v0, $t0

fibonacci_exit:
	addi $sp, $sp, 12
	lw $a0, -8($sp)
	lw $ra, -4($sp)
	lw $t0, 0($sp)
	jr $ra

fibonacci_base:
	ori $v0, $zero, 1
	j fibonacci_exit

	.data
quest: .asciiz "N: "
info: .asciiz "F: "
newline: .asciiz "\n"
