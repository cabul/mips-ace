`ifndef _control
`define _control

// Control Unit
//
// This unit is async
// TODO Everything
module control(
	input wire[5:0] op_code,
	input wire[5:0] funct,
	output reg reg_dst = 0,
	output reg jump = 0,
	output reg branch = 0,
	output reg mem_read = 0,
	output reg mem_to_reg = 0,
	output reg[3:0] alu_op = 0,
	output reg mem_write = 0,
	output reg alu_src = 0,
	output reg reg_write = 0
);

endmodule

`endif
