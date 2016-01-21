# for (int i = 0; i < 100; i++)
#     c[i] = a[i] + b[i]
    
    .text
main:
    la $s0, a
    la $s1, b
    la $s2, c
    li $s3, 100
    li $s4, 1
loop:
    lw $t0, 0($s0) 
    lw $t1, 0($s1)
    addi $s0, $s0, 4
    addi $s1, $s1, 4
    add $t0, $t1, $0
    addi $s4, $s4, 1
    sw $t0, 0($s2)
    addi $s2, $s2, 4
    bne $s4, $s3, loop

    sw $0, %IO_EXIT($0)

	.data
a: .space 400 
b: .space 400 
c: .space 400 
