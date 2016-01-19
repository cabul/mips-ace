.data

vector: .space 512      # Elements*4

.text

main:
	la $t0, vector
	li $t1, 0           # Counter
	li $t2, 128         # Elements

# Let's initialize
loop:
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	bne $t1, $t2, loop
    la $t0, vector
	li $t1, 0           # Counter
	li $a0, 0           # Sum

#Summatory
sum:
	lw $t3, 0($t0)
	add $a0, $a0, $t3
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	bne $t1, $t2, sum
	li $v0, 1           # Show result and finish
    syscall
    li $v0, 11
    li $a0, 10
    syscall
	li $v0, 10
	syscall
