	.kdata
exception:	.asciiz 	"  Exception: "
tlb:		.asciiz	"  [TLB]"
bad_inst:	.asciiz	"  [Bad instruction address] "
bad_data:	.asciiz	"  [Bad data address] "
syscll:	.asciiz	"  [Error in syscall] "
reserved:	.asciiz	"  [Reserved instruction] "
overflow:	.asciiz	"  [Arithmetic overflow] "
s1:	.word 0
s2:	.word 0

	.ktext 0x80000180
	sw $v0 s1		# Not re-entrant and we can't trust $sp
	sw $a0 s2		# But we need to use these registers

	mfc0 $k0 $13		# Cause register
	srl $a0 $k0 2		# Extract ExcCode Field
	andi $a0 $a0 0x1f

	# Print information about exception.
	#
	li $v0 4		# syscall 4 (print_str)
	la $a0 exception
	syscall

	srl $a0 $k0 2		# Extract ExcCode Field
	andi $a0 $a0 0x1f

#0	INT	External interrupt
#4	ADDRL	Address error exception (load or instruction fetch)
#5	ADDRS	Address error exception (store)
#6	IBUS	Bus error on instruction fetch
#7	DBUS	Bus error on data load or store
#8	SYSCALL	System call
#10	RI	Reservesd instruction exception
#12	OVF	Arithmetic overflow exception
#1	TLB ****

	li $s1, 12
	beq $a0, $s1, ov_ex
	li $s1, 8
	beq $a0, $s1, sys_ex
	li $s1, 1
	beq $a0, $s1, tlb_ex
	li $s1, 7
	beq $a0, $s1, ldsd_ex
	li $s1, 10
	beq $a0, $s1, ri_ex

	ov_ex:
	li $v0 4
	la $a0 overflow
	syscall

	j epc

	sys_ex:
	li $v0 4
	la $a0 syscll
	syscall

	j epc

	tlb_ex:
	li $v0 4
	la $a0 tlb
	syscall

	j epc

	ldsd_ex:
	li $v0 4
	la $a0 bad_data
	syscall

	j epc

	ri_ex:
	li $v0 4
	la $a0 reserved
	syscall

epc:
	mfc0 $a0 $14		# EPC
	andi $a0 $a0 0x3		# Is EPC word-aligned?
	beq $a0 0 ret

	li $v0 10		# Exit on really bad PC
	syscall


ret:
# Return from (non-interrupt) exception. Skip offending instruction
# at EPC to avoid infinite loop.
#
	mfc0 $k0 $14		# Bump EPC register
	addi $k0 $k0 4		# Skip faulting instruction
	mtc0 $k0 $14

# Restore registers and reset procesor state
#
	lw $v0 s1		# Restore other registers
	lw $a0 s2
	mtc0 $0 $13		# Clear Cause register

	eret

# Standard startup code.
	.text
	.globl __start
__start:
	li $sp, 0x7fffeffc
	lw $a0 0($sp)		# argc
	addiu $a1 $sp 4		# argv
	addiu $a2 $a1 4		# envp
	sll $v0 $a0 2
	addu $a2 $a2 $v0
	jal main

	li $v0 10
	syscall			# syscall 10 (exit)

	.globl __eoth
__eoth:
