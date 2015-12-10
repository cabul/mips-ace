#################################   Data Segment    ######################################### 
.data
square:   .byte      1, 2, 3, 4, 5, 6, 7, 8, 9  
tic:      .asciiz   " \n\n Tic Tac Toe\n"
POp:     .asciiz   " Player 1 (X)  -  Player 2 (0) \n\n"
b1:       .asciiz   "     |     |     \n"
b2:       .asciiz   "  "
b3:       .asciiz   "  |  "
b4:       .asciiz   "_____|_____|_____\n"
b5:       .asciiz   "  \n"
P1:       .asciiz   "Player 1, enter a number : "
P2:       .asciiz   "Player 2, enter a number : "
Invalid:  .asciiz   "\nInvalid move. Try again : "
PW1:      .asciiz   "Player 1 wins."
PW2:      .asciiz   "Player 2 wins."
d:        .asciiz   "The game is a draw."

################################    Text Segment   ##########################################
.text
main:
     la $k0, square              # Loading array named square
     addi $s0, $zero, 1
     addi $s3, $zero, 88
     addi $s4, $zero, 79
start:
      jal Board                  # Calling function to print board
      lb $t0, 0($k0)
      lb $t1, 1($k0)
      lb $t2, 2($k0)
      lb $t3, 3($k0)
      lb $t4, 4($k0)
      lb $t5, 5($k0)
      lb $t6, 6($k0)
      lb $t7, 7($k0)
      lb $t8, 8($k0)
      beq $s0, 2, Player2
Player1:                         # If its player 1 turn
       addi $s0, $zero, 2
       la $a0, P1
       addi $v0, $zero, 4
       syscall
       
       addi $s6, $zero, 88 
       j condition
Player2:                        # If its Player 2 turn
       addi $s0, $zero, 1
       la $a0, P2
       addi $v0, $zero, 4
       syscall
       
       addi $s6, $zero, 79
condition:                      
         addi $v0, $zero, 12
         syscall
               
         addi $a3, $v0, 0
         beq $a3, $s3, m9
         beq $a3, $s4, m9
         bne $a3, $t0, m1
         sb  $s6, 0($k0)
         j m10
m1:
         bne $a3, $t1, m2
         beq $a3, $s6, m9
         beq $a3, $s4, m9
         sb  $s6, 1($k0)
         j m10
m2:
         bne $a3, $t2, m3
         beq $a3, $s6, m9
         sb  $s6, 2($k0)
         j m10
m3:
         bne $a3, $t3, m4
         beq $a3, $s6, m9
         beq $a3, $s4, m9
         sb  $s6, 3($k0)
         j m10
m4:
         bne $a3, $t4, m5
         beq $a3, $s6, m9
         beq $a3, $s4, m9
         sb  $s6, 4($k0)
         j m10
m5:
         bne $a3, $t5, m6
         beq $a3, $s6, m9
         beq $a3, $s4, m9
         sb  $s6, 5($k0)
         j m10
m6:
         bne $a3, $t6, m7
         beq $a3, $s6, m9
         beq $a3, $s4, m9
         sb  $s6, 6($k0)
         j m10
m7:
         bne $a3, $t7, m8
         beq $a3, $s6, m9
         beq $a3, $s4, m9
         sb  $s6, 7($k0)
         j m10
m8:
         bne $a3, $t8, m9
         beq $a3, $s6, m9
         beq $a3, $s4, m9
         sb  $s6, 8($k0)
         j m10
m9:
         la  $a0, Invalid
         addi $v0, $zero, 4
         syscall
       
         j condition
m10:
         jal CheckWin                     # Funtion Call to check the status of the game
         addi $k1, $v0, 0
         beq $k1, -1, start
         jal Board
         beq $k1, 0, draw
         beq $s0, 1, WP2
WP1:                                     # To display that player 1 won the game
         la  $a0, PW1
         addi $v0, $zero, 4
         syscall
         j exit
WP2:                                    # To display that player 2 won the game
         la  $a0, PW2
         addi $v0, $zero, 4
         syscall
         j exit
draw:                                   # TO display the game is a draw
         la $a0, d
         addi $v0, $zero, 4
         syscall
exit:                                  #To exit the program safely
         li $v0, 10
         syscall      

CheckWin:                                  #This function will return
        lb $t0, 0($k0)                     # 1 if the game ends with result
        lb $t1, 1($k0)                     # -1 if the game is in progress
        lb $t2, 2($k0)                     # 0 if the game is a draw
        lb $t3, 3($k0)
        lb $t4, 4($k0)
        lb $t5, 5($k0)
        lb $t6, 6($k0)
        lb $t7, 7($k0)
        lb $t8, 8($k0)
        bne $t0, $t1, C2
        bne $t1, $t2, C2
        addi $v0, $zero, 1
        jr $ra
C2:
        bne $t3, $t4, C3
        bne $t4, $t5, C3
        addi $v0, $zero, 1
        jr $ra
C3:
        bne $t6, $t7, C4
        bne $t7, $t8, C4
        addi $v0, $zero, 1
        jr $ra
C4:
        bne $t0, $t3, C5
        bne $t3, $t6, C5
        addi $v0, $zero, 1
        jr $ra
C5:
        bne $t1, $t4, C6
        bne $t4, $t7, C6
        addi $v0, $zero, 1
        jr $ra
C6:
        bne $t2, $t5, C7
        bne $t5, $t8, C7
        addi $v0, $zero, 1
        jr $ra
C7:
        bne $t0, $t4, C8
        bne $t4, $t8, C8
        addi $v0, $zero, 1
        jr $ra
C8:
        bne $t2, $t4, C9
        bne $t4, $t6, C9
        addi $v0, $zero, 1
        jr $ra
C9:
        beq $t0, '1', C10
        beq $t1, '2', C10
        beq $t2, '3', C10
        beq $t3, '4', C10
        beq $t4, '5', C10
        beq $t5, '6', C10
        beq $t6, '7', C10
        beq $t7, '8', C10
        beq $t8, '9', C10
        addi $v0, $zero, 0
        jr $ra
C10:
        addi $v0, $zero, -1
        jr $ra

Board:                                #This function will display the board
     lb $t0, 0($k0)
     lb $t1, 1($k0)
     lb $t2, 2($k0)
     lb $t3, 3($k0)
     lb $t4, 4($k0)
     lb $t5, 5($k0)
     lb $t6, 6($k0)
     lb $t7, 7($k0)
     lb $t8, 8($k0)
     
     la $a0, tic
     addi $v0, $zero, 4
     syscall
     
     la $a0, POp
     syscall
     
     la $a0, b1
     syscall
     
     la $a0, b2
     syscall
     
B1:  
     addi $a0, $t0, 0
     addi $v0, $zero, 11
     syscall
    
     la $a0, b3
     addi $v0, $zero, 4
     syscall
     
B2:  
     addi $a0, $t1, 0
     addi $v0, $zero, 11
     syscall
     
     la $a0, b3
     addi $v0, $zero, 4
     syscall

B3:  
     addi $a0, $t2, 0
     addi $v0, $zero, 11
     syscall
     
     la $a0, b5
     addi $v0, $zero, 4
     syscall
     
     la $a0, b4
     syscall
     
     la $a0, b1
     syscall
     
     la $a0, b2
     syscall

B4:
     addi $a0, $t3, 0
     addi $v0, $zero, 11
     syscall
     
     la $a0, b3
     addi $v0, $zero, 4
     syscall

B5: 
     addi $a0, $t4, 0
     addi $v0, $zero, 11
     syscall
     
     la $a0, b3
     addi $v0, $zero, 4
     syscall

B6:
     addi $a0, $t5, 0
     addi $v0, $zero, 11
     syscall
     
     la $a0, b5
     addi $v0, $zero, 4
     syscall
     
     la $a0, b4
     syscall
     
     la $a0, b1
     syscall
     
     la $a0, b2
     syscall

B7:
     addi $a0, $t6, 0
     addi $v0, $zero, 11
     syscall
   
     la $a0, b3
     addi $v0, $zero, 4
     syscall

B8:
     addi $a0, $t7, 0
     addi $v0, $zero, 11
     syscall
     
     la $a0, b3
     addi $v0, $zero, 4
     syscall

B9:
     addi $a0, $t8, 0
     addi $v0, $zero, 11
     syscall
     
     la $a0, b5
     addi $v0, $zero, 4
     syscall
     
     la $a0, b1
     syscall
     
     jr $ra
