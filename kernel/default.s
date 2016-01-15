######################################################
#                                                    #
#                mipsACE micro-kernel                #
#                                                    #
#  Master in Innovation and Research in Informatics  #
#                Processor Architecture              #
#                    2015 / 2016                     #
#                                                    #
######################################################

.kdata
__str_exception:            .asciiz "[ukernel]: Exception detected: "
__str_syscall_uns:          .asciiz "[ukernel]: Unsupported syscall ("
__str_syscall_uns2:         .asciiz ").\n"
__str_unimplemented:        .asciiz "exception not implemented raised.\n"
__str_ld_exc:               .asciiz "address error (load).\n"
__str_st_exc:               .asciiz "address error (store).\n"
__str_tlb_load:             .asciiz "TLB miss on load or fetch.\n"
__str_tlb_store:            .asciiz "TLB miss on store.\n"
__str_overflow:             .asciiz "arithmetic overflow.\n"
__str_syscall:              .asciiz "syscall.\n"
__str_reserved:             .asciiz "reserved instruction.\n"
__str_trap:                 .asciiz "it's a trap.\n"
__str_endline:              .asciiz "\n"
__save_reg:                 .space 12
__exception_jumptable:      .word __int, __unimpl1, __TLBL, __TLBS, __AdEL, __AdES, __IBE, __DBE, __Sys, __Bp, __RI, __CpU, __Ov, __Tr, __unimpl4, __FPE
__syscall_jumptable:        .word __pint_hex, __pint, __pfloat, __pdouble, __pstring, __rint, __rfloat, __rdouble, __rstring, __mem_alloc, __sys_exit, __pchar, __rchar, __sys_unsupported

.ktext
	mfc0 $k0, $cause
	bne $k0, $0, __exception_handler

__entry_point:
	li $sp, %STACK_INIT             # Set stack-pointer
	li $k1, 0x10                    # UM is bit 4
	mtc0 $k1, $status               # Set machine to user-mode
	nop
	nop
	j main                          # We are still in kernel-mode here

__exception_handler:
	la $k0, __save_reg
	sw $v0, 0($k0)                  # Not re-entrant and we can't trust $sp
	sw $a0, 4($k0)
	sw $ra, 8($k0)                  # But we need to use these registers
	mfc0 $k0, $cause                # Cause register
	srl $a0, $k0, 2                 # Extract ExcCode Field
	andi $a0, $a0, 0x1F
	sll $a0, $a0, 2
	la $v0, __exception_jumptable
	add $v0, $v0, $a0
	lw $v0, 0($v0)
	li $k0, 32                      # 8 << 2
	beq $a0, $k0, __skip_emsg       # Skip exeception message if syscall
	la $a0, __str_exception
	jal __kernel_strprint
__skip_emsg:
	jr $v0                          # Switch exception table (see table below)

	# 0  - Int  Interrupt (hardware)
	# 1  - Mod  TLB Modification
	# 2  - TLBL TLB Exception (load or instruction fetch)
	# 3  - TLBS TLB Exception (store)
	# 4  - AdEL Address Error Exception (load or instruction fetch)
	# 5  - AdES Address Error Exception (store)
	# 6  - IBE  Bus Error on Instruction Fetch
	# 7  - DBE  Bus Error on Load or Store
	# 8  - Sys  Syscall Exception
	# 9  - Bp   Breakpoint Exception
	# 10 - RI   Reserved Instruction Exception
	# 11 - CpU  Coprocessor Unimplemented
	# 12 - Ov   Arithmetic Overflow Exception
	# 13 - Tr   Trap
	# 15 - FPE  Floating Point Exception

__CpU:
__Bp:
__FPE:
__int:
	la $a0, __str_unimplemented
	jal __kernel_strprint
	j __epc
__Tr:
	la $a0, __str_trap
	jal __kernel_strprint
	sw $0, %IO_EXIT($0)
__unimpl1: # Mod
__TLBL:
__TLBS:
	mfc0 $k0, $entryhi
	nop # check if really necessary
	nop
	li $k1, 0xfffff000
	and $k0, $k0, $k1 # only get the vaddr
	addi $k0, $k0, 0x1001 # translate to paddr + valid bit
	mtc0 $k0, $entrylo
	j __epc
__unimpl4:
	la $a0, __str_unimplemented
	jal __kernel_strprint
	j __epc
__AdEL:
	la $a0, __str_ld_exc
	jal __kernel_strprint
	j __epc
__AdES:
	la $a0, __str_st_exc
	jal __kernel_strprint
	j __epc
__IBE:
	la $a0, __str_unimplemented
	jal __kernel_strprint
	j __epc
__DBE:
	la $a0, __str_unimplemented
	jal __kernel_strprint
	j __epc
__Ov:
	la $a0, __str_overflow
	jal __kernel_strprint
	j __epc
__RI:
	la $a0, __str_reserved
	jal __kernel_strprint
	j __epc
__Sys:
	la $k0, __save_reg
	lw $a0, 4($k0)                  # Restore original a0
	la $v0, __syscall_jumptable
	lw $k0, 0($k0)                  # Restore original v0
	li $k1, 13
	slt $k1, $k0, $k1               # Out of range
	beq $k1, $0, __sys_unsupported
	sll $k0, $k0, 2
	add $v0, $v0, $k0               # Calculate where to jump
	lw $v0, 0($v0)
	xor $k1, $k1, $k1               # Clear register
	jr $v0                          # Switch syscall table (see table below)

	# 0  - Print integer as hex value (custom)
	# 1  - Print integer, $a0 = value
	# 2  - Print float (not supported)
	# 3  - Print double (not supported)
	# 4  - Print string, $a0 = address of string
	# 5  - Read integer, $v0 = value read
	# 6  - Read float (not supported)
	# 7  - Read double (not supported)
	# 8  - Read string (not supported)
	# 9  - Memory allocation (not supported)
	# 10 - Exit, end of program
	# 11 - Print character, $a0 = character
	# 12 - Read character, $v0 = character read

__pint_hex:
	sw $a0, %IO_HEX($0)
	j __epc
__pint:
	sw $a0, %IO_INT($0)
	j __epc
__pfloat:
__pdouble:
	j __sys_unsupported
__pstring:
	jal __kernel_strprint
	j __epc
__rint:
	lw $v0, %IO_INT($0)
	li $k1, 1                       # Skip load of v0
	j __epc
__rfloat:
__rdouble:
__rstring:
__mem_alloc:
	j __sys_unsupported
__sys_exit:
	sw $0, %IO_EXIT($0)
__pchar:
	sw $a0, %IO_CHAR($0)
	j __epc
__rchar:
	lw $v0, %IO_CHAR($0)
	li $k1, 1                       # Skip load of v0
	j __epc
__sys_unsupported:
	la $a0, __str_syscall_uns
	jal __kernel_strprint
	la $k0, __save_reg
	lw $v0, 0($k0)
	sw $v0, %IO_INT($0)
	la $a0, __str_syscall_uns2
	jal __kernel_strprint
	xor $k1, $k1, $k1               # Clear register
	j __epc

__epc:
	mfc0 $a0, $epc
	andi $a0, $a0, 0x3              # Is EPC word-aligned?
	beq $a0, $0, __ret_exception
	sw $0, %IO_EXIT($0)             # Exit
__ret_exception:
	la $k0, __save_reg
	bne $k1, $0, __skip_v0
	lw $v0, 0($k0)                  # Restore registers
__skip_v0:
	lw $a0, 4($k0)
	lw $ra, 8($k0)
	move $k0, $0                    # Can't touch this
	mtc0 $0, $cause                 # Clear cause
	li $k1, 0x10
	mtc0 $k1, $status               # Set machine to user-mode
	eret                            # Return

# Note that kernel functions do not save registers

__kernel_strprint:
	lw $k0, 0($a0)
	andi $k1, $k0, 0xFF
	beq $k1, $0, __kernel_strprint_ret
	sw $k1, %IO_CHAR($0)
	srl $k0, $k0, 8
	andi $k1, $k0, 0xFF
	beq $k1, $0, __kernel_strprint_ret
	sw $k1, %IO_CHAR($0)
	srl $k0, $k0, 8
	andi $k1, $k0, 0xFF
	beq $k1, $0, __kernel_strprint_ret
	sw $k1, %IO_CHAR($0)
	srl $k0, $k0, 8
	andi $k1, $k0, 0xFF
	beq $k1, $0, __kernel_strprint_ret
	sw $k1, %IO_CHAR($0)
	addi $a0, $a0, 4
	j __kernel_strprint
__kernel_strprint_ret:
	jr $ra
