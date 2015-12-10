.text

main:
	mfc0 $t0, $status
    la $a0, msg
    li $v0, 4
    syscall
	jr $ra
    
.data
msg: .asciiz "Puta vida tete\n"
