`ifndef _defines
`define _defines

// Functions

`define FN_ADD 6'h20
`define FN_SUB 6'h22
`define FN_AND 6'h24
`define FN_NOR 6'h27
`define FN_OR  6'h25
`define FN_XOR 6'h26
`define FN_SLL 6'h0
`define FN_SRL 6'h2
`define FN_SRA 6'h3
`define FN_SLT 6'h2a
`define FN_MUL 6'h18
`define FN_DIV 6'h1a
`define FN_JR  6'h8
`define FN_SYS 6'hc

// ALU operations

`define ALUOP_AND 4'h0
`define ALUOP_OR  4'h1
`define ALUOP_ADD 4'h2
`define ALUOP_NOR 4'h3
`define ALUOP_SLL 4'h4
`define ALUOP_SUB 4'h6
`define ALUOP_SLT 4'h7
`define ALUOP_SRL 4'h8
`define ALUOP_SRA 4'h9
`define ALUOP_XOR 4'ha
`define ALUOP_BEQ 4'hb
`define ALUOP_BNE 4'hc
`define ALUOP_LUI 4'hd
`define ALUOP_MUL 4'he
`define ALUOP_DIV 4'hf

// Opcodes

`define OP_RTYPE 6'h0
`define OP_ADDI  6'h8
`define OP_ANDI  6'hc
`define OP_ORI	 6'hd
`define OP_XORI	 6'he
`define OP_SLTI	 6'ha
`define OP_BEQ   6'h4
`define OP_BNE	 6'h5
`define OP_J     6'h2
`define OP_LB	 6'h20
`define OP_LUI	 6'hf
`define OP_LW    6'h23
`define OP_SB	 6'h28
`define OP_SW    6'h2b
`define OP_JAL   6'h3
`define OP_MFC0  6'h10
`define OP_MTC0  6'h11

// Coprocessor0

`define C0_SR       5'd12
`define C0_CAUSE    5'd13
`define C0_EPC      5'd14

// SYS IO

`define SYS_PRINT_CHAR  11 
`define SYS_PRINT_INT    1
`define SYS_PRINT_FLOAT  2
`define SYS_READ_CHAR   12
`define SYS_READ_INT     5
`define SYS_READ_FLOAT   6
`define SYS_EXIT        10

`define IO_EXIT  8'hff
`define IO_CHAR  8'hfe
`define IO_INT   8'hfd
`define IO_FLOAT 8'hfc
`define IO_HEX   8'hfb

// Debug macros

`ifdef DEBUG
	`define DMSG(M) $display M ;
`else
	`define DMSG(M)
`endif

`define MEMORY_DATA "build/memory.raw"

`endif
