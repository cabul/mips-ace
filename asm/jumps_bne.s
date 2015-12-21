.text

main:
    li $s0, 100
loop:
    addi $s0, $s0, -1
    bne $s0, $0, loop       # do while $s0 > 0
exit:
    li $v0, 1
    add $a0, $s0, $0
    syscall
    li $v0, 11
    li $a0, 10
    syscall
    jr $ra
