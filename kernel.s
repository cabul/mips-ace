	.kdata
exception:	.asciiz 	"  Exception: "
tlb_fetch:	.asciiz		"  [TLB on Instruction Fetch]" 
tlb_data:	.asciiz		"  [TLB on Load or Store]"
syscll:		.asciiz		"  [Syscall] "
reserved:	.asciiz		"  [Reserved instruction] "
overflow:	.asciiz		"  [Arithmetic overflow] "
load_exc:	.asciiz		"  [Address Error Exception (load or instruction fetch)]"
str_exc:	.asciiz		"  [Address Error Exception (store)]"
unimpl:		.asciiz		"  [Unimplemented]"
save_reg1:	.word 0
save_reg2:	.word 0
exception_jumptable:	.word int, unimpl1, unimpl2, unimpl3, AdEL, AdES, IBE, DBE, Sys, Bp, RI, CpU, Ov, Tr, unimpl4, FPE
syscall_jumptable: 		.word print_int, print_float, print_double, print_string, read_int, read_float, read_double, read_string, sbrk, exit

	.ktext 0x80000180
	la $k0, save_reg1
	sw $v0, 0($k0)		# Not re-entrant and we can't trust $sp
	la $k0, save_reg2
	sw $a0, 0($k0)		# But we need to use these registers

	# Print information about exception.
	#
	li $v0, 4		# syscall 4 (print_str)
	la $a0, exception
	syscall

	## Exception Table
	#0 Int Interrupt (hardware)
	#4 AdEL Address Error Exception (load or instruction fetch)
	#5 AdES Address Error Exception (store)
	#6 IBE Bus Error on Instruction Fetch
	#7 DBE Bus Error on Load or Store
	#8 Sys Syscall Exception
	#9 Bp Breakpoint Exception
	#10 RI Reserved Instruction Exception
	#11 CpU Coprocessor Unimplemented
	#12 Ov Arithmetic Overflow Exception
	#13 Tr Trap
	#15 FPE Floating Point Exception

	mfc0 $k0, $13		# Cause register
	srl $a0, $k0, 2		# Extract ExcCode Field
	andi $a0, $a0, 0x1f

	## Switch exception
	sll $a0, $a0, 2
	la $v0, exception_jumptable
	add $v0, $v0, $a0
	lw $v0, ($v0)
	jr $v0

CpU:
Bp:
FPE:
int:
Tr:
unimpl1:
unimpl2:
unimpl3:
unimpl4: 
			la $a0, unimpl
			li $v0, 4
			syscall
				
		    j epc

AdEL:	
	li $v0, 4
	la $a0, load_exc
	syscall

	j epc

AdES:
	li $v0, 4
	la $a0, str_exc
	syscall

	j epc

IBE:
	li $v0, 4
	la $a0, tlb_fetch
	syscall

	j epc

DBE:
	li $v0, 4
	la $a0, tlb_data
	syscall

	j epc

Ov:
	li $v0, 4
	la $a0, overflow
	syscall

	j epc

RI:
	li $v0, 4
	la $a0, reserved
	syscall

Sys:
	li $v0, 4
	la $a0, syscll
	syscall

	la $k0, save_reg1
	lw $v0, 0($k0)

	## Switch syscall
	addi $v0, $v0, -1
	sll $v0, $v0, 2
	la $a0, syscall_jumptable
	add $v0, $v0, $a0
	lw $v0, ($v0)
	jr $v0

###########################################################################	
print_int:	la $k0, save_reg2
			lw $a0, 0($k0)
			# Pasar a stdio a0 para que lo pinte
			j epc

print_float: 	la $k0, save_reg2
				lw $a0, 0($k0)
				# Pasar a stdio a0 para que lo pinte
				j epc

print_double: 	la $k0, save_reg2
				lw $a0, 0($k0)
				# Pasar a stdio a0 para que lo pinte
				j epc

print_string: 	la $k0, save_reg2
				lw $a0, 0($k0)
				# Pasar a stdio a0 para que lo pinte
				j epc

read_int: 	# Pedir a stdio que lea un entero y lo devuelva en a0
			la $k0, save_reg2
			sw $a0, 0($k0)
			j epc

read_float:	# Pedir a stdio que lea un float y lo devuelva en a0
			la $k0, save_reg2
			sw $a0, 0($k0)
			j epc

read_double:	#Pedir a stdio que lea un double y lo devuelva en a0
				la $k0, save_reg2
				sw $a0, 0($k0)
				j epc

read_string: 	#Pedir a stdio que lea un string y devuelva su @ en a0
				la $k0, save_reg2
				sw $a0, 0($k0)
				j epc

sbrk: 	# Memoria dinámica, no es necesario implementarlo
			j epc

exit: # Pedir a stdio que finalice la ejecucion
			j epc

###########################################################################

epc:

# Añadir que mire las pending interrupts y las trate

	mfc0 $a0, $14			# EPC
	andi $a0, $a0, 0x3		# Is EPC word-aligned?
	beq $a0, 0, ret_exception

	li $v0 10		# Exit on really bad PC
	syscall

ret_exception:
# Restore registers and reset procesor state
#
	la $k0, save_reg1
	lw $v0, 0($k0)		# Restore other registers
	la $k0, save_reg2
	lw $a0, 0($k0)
	mtc0 $0, $13		# Clear Cause register

	eret

# Standard startup code.
	.text
	li $sp, 0x7fffeffc
	jal main
