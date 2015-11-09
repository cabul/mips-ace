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

`define OP_AND 4'b0000
`define OP_OR  4'b0001
`define OP_ADD 4'b0010
`define OP_SLL 4'b0100
`define OP_SUB 4'b0110
`define OP_SLT 4'b0111
`define OP_SRL 4'b1000
`define OP_SRA 4'b1001
`define OP_XOR 4'b1010
`define OP_NOR 4'b1100

// Configuration
`ifndef MEMDATA_IN
`define MEMDATA_IN "data/default"
`endif

`ifndef MEMDATA_LEN
`define MEMDATA_LEN 16
`endif

`endif
