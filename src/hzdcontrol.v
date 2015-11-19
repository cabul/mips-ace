`ifndef _hzdcontrol
`define _hzdcontrol

`include "defines.v"

module hzdcontrol (
	input wire memtoreg,
	input wire [15:0] instr_top,
	input wire [4:0] rt,
	output reg stall = 0
);

wire [5:0] opcode;
wire [4:0] ex_rs;
wire [4:0] ex_rt;

assign opcode = instr_top[15:10];
assign ex_rs  = instr_top[9:5];
assign ex_rt  = instr_top[4:0];

always @* begin
	if (memtoreg)
		case (opcode)
			`OP_J:   stall <= 0;
			`OP_JAL: stall <= 0;
			default:
				stall <= (ex_rs == rt || ex_rt == rt);
		endcase
	else stall <= 0;
end

endmodule

`endif
