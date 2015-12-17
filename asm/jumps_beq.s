.text

main:
    li $s0, 100
    li $s1, 5
loop:
    addi $s0, $s0, -1
    slt $s2, $s0, $s1
    beq $s2, $0, loop       # do while $s0 >= 5
exit:
    jr $ra
