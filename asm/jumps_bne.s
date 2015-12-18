.text

main:
    li $s0, 6
loop:
    addi $s0, $s0, -1
    bne $s0, $0, loop       # do while $s0 > 0
exit:
    jr $ra
