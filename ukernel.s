######################################################
#                                                    #
#                mipsACE micro-kernel                #
#                                                    #
#  Master in Innovation and Research in Informatics  #
#                Processor Architecture              #
#                    2015 / 2016                     #
#                                                    #
######################################################

#.kdata
.data
boot_logo0:             .asciiz "    __  ___________  _____    ___   ____________\n"
boot_logo1:             .asciiz "   /  |/  /  _/ __ \/ ___/   /   | / ____/ ____/          /\\_/\\\n"
boot_logo2:             .asciiz "  / /|_/ // // /_/ /\__ \   / /| |/ /   / __/        ____/ o o \\\n"
boot_logo3:             .asciiz " / /  / // // ____/___/ /  / ___ / /___/ /___      /~____  =ø= /\n"
boot_logo4:             .asciiz "/_/  /_/___/_/    /____/  /_/  |_\____/_____/     (______)__m_m)\n\n"
str_launching:          .asciiz "[ukernel]: Jumping to main...\n"
str_end:                .asciiz "[ukernel]: Execution finished. Bye bye!\n"
str_exception:          .asciiz "[ukernel]: Exception => "
str_unimplemented:      .asciiz "exception not implemented raised.\n"
str_load_exc:           .asciiz "address error (load or instruction fetch).\n"
str_st_exc:             .asciiz "address error (store).\n"
str_tlb_fetch:          .asciiz "TLB on instruction fetch.\n"
str_tlb_data:           .asciiz "TLB on load or store.\n"
str_overflow:           .asciiz "arithmetic overflow.\n"
str_syscall:            .asciiz "syscall.\n"
str_reserved:           .asciiz "reserved instruction.\n"
str_endline:            .asciiz "\n"
save_reg:               .space 8
exception_jumptable:	.word int, unimpl1, unimpl2, unimpl3, AdEL, AdES, IBE, DBE, Sys, Bp, RI, CpU, Ov, Tr, unimpl4, FPE

#.ktext
.text
    mfc0 $k0, $cause
    bne $k0, $0, exception_handler
    
entry_point:
    li $sp, 0x300               # Set stack-pointer
    mtc0 $0, $cause             # Set machine to user-mode
    jal boot_logo
    la $a0, str_launching
    jal kernel_strprint
    jal main
    la $a0, str_end
    jal kernel_strprint
    sw $0, %IO_EXIT($0)

exception_handler:
    la $k0, save_reg
    sw $v0, 0($k0)              # Not re-entrant and we can't trust $sp
    sw $a0, 4($k0)              # But we need to use these registers
    la $a0, str_exception
    jal kernel_strprint
    mfc0 $k0, $cause            # Cause register
    srl $a0, $k0, 2             # Extract ExcCode Field
    andi $a0, $a0, 0x1F
    sll $a0, $a0, 2
    la $v0, exception_jumptable
    add $v0, $v0, $a0
    lw $v0, 0($v0)
    jr $v0                      # Switch exception table (see table below)

    # 0  - Int Interrupt (hardware)
    # 4  - AdEL Address Error Exception (load or instruction fetch)
    # 5  - AdES Address Error Exception (store)
    # 6  - IBE Bus Error on Instruction Fetch
    # 7  - DBE Bus Error on Load or Store
    # 8  - Sys Syscall Exception
    # 9  - Bp Breakpoint Exception
    # 10 - RI Reserved Instruction Exception
    # 11 - CpU Coprocessor Unimplemented
    # 12 - Ov Arithmetic Overflow Exception
    # 13 - Tr Trap
    # 15 - FPE Floating Point Exception

CpU:
Bp:
FPE:
int:
Tr:
unimpl1:
unimpl2:
unimpl3:
unimpl4:
    la $a0, str_unimplemented
    jal kernel_strprint
    j epc
AdEL:
    la $a0, str_load_exc
    jal kernel_strprint
    j epc    
AdES:
    la $a0, str_st_exc
    jal kernel_strprint
    j epc
IBE:
    la $a0, str_tlb_fetch
    jal kernel_strprint
    j epc
DBE:
    la $a0, str_tlb_data
    jal kernel_strprint
    j epc
Ov:
    la $a0, str_overflow
    jal kernel_strprint
    j epc
RI:
    la $a0, str_reserved
    jal kernel_strprint
    j epc
Sys:
    la $a0, str_syscall
    jal kernel_strprint
    j epc

epc:
    mfc0 $a0, $epc
    andi $a0, $a0, 0x3          # Is EPC word-aligned?
    beq $a0, $0, ret_exception
    sw $0, %IO_EXIT($0)         # Exit
ret_exception:
    la $k0, save_reg
    lw $v0, 0($k0)              # Restore other registers
    lw $a0, 4($k0)
    mtc0 $0, $cause             # Clear Cause register
    eret                        # Return

# Note that kernel functions do not save registers

kernel_strprint:
    lw $k0, 0($a0)
    andi $k1, $k0, 0xFF
    beq $k1, $0, kernel_strprint_ret
    sw $k1, %IO_CHAR($0)
    srl $k0, $k0, 8
    andi $k1, $k0, 0xFF
    beq $k1, $0, kernel_strprint_ret
    sw $k1, %IO_CHAR($0)
    srl $k0, $k0, 8
    andi $k1, $k0, 0xFF
    beq $k1, $0, kernel_strprint_ret
    sw $k1, %IO_CHAR($0)
    srl $k0, $k0, 8
    andi $k1, $k0, 0xFF
    beq $k1, $0, kernel_strprint_ret
    sw $k1, %IO_CHAR($0)
    addi $a0, $a0, 4
    j kernel_strprint
kernel_strprint_ret:
    jr $ra

boot_logo:
    move $s0, $ra
    la $a0, boot_logo0
    jal kernel_strprint
    la $a0, boot_logo1
    jal kernel_strprint
    la $a0, boot_logo2
    jal kernel_strprint
    la $a0, boot_logo3
    jal kernel_strprint
    la $a0, boot_logo4
    jal kernel_strprint
    move $ra, $s0
    jr $ra

main:
    #
    # <program needed>
    #
    
    jr $ra
