    .text
main:
    addi $t1, $0, 1
    addi $t2, $0, 2
    add $t3, $0, $t1   # 0 + 1
    add $t3, $t3, $t2  # 0 + 1 + 2
    add $t3, $t3, $t2  # 0 + 1 + 2 + 2
    
    # $t3 = 5

    nop                # So we have enough time to see in the waveform the result
    sw $0, %IO_EXIT($0)
