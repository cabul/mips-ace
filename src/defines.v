`ifndef _defines
`define _defines

// Functions

`define FN_SLL 6'b000000
`define FN_SRL 6'b000010
`define FN_SRA 6'b000011
`define FN_ADD 6'b100000
`define FN_SUB 6'b100010
`define FN_AND 6'b100100
`define FN_OR  6'b100101
`define FN_XOR 6'b100110
`define FN_NOR 6'b100111
`define FN_SLT 6'b101010

// ALU operations

`define ALUOP_AND 4'b0000
`define ALUOP_OR  4'b0001
`define ALUOP_ADD 4'b0010
`define ALUOP_SLL 4'b0100
`define ALUOP_SUB 4'b0110
`define ALUOP_SLT 4'b0111
`define ALUOP_SRL 4'b1000
`define ALUOP_SRA 4'b1001
`define ALUOP_XOR 4'b1010
`define ALUOP_NOR 4'b1100

// Opcodes
`define OP_ADDI 6'h8
`define OP_LW   6'h23
`define OP_SW   6'h2b
`define OP_BEQ  6'h4
`define OP_J    6'h2

// Debug macros
`ifdef DEBUG
	`define DMSG(M) $display M ;
`else
	`define DMSG(M)
`endif

`endif
