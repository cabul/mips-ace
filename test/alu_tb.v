`include "alu.v"

`ifndef TRACEFILE
`define TRACEFILE "traces/alu_tb.vcd"
`endif

// ALU Testbench
module alu_tb;

wire zero;
wire [31:0] out;

alu alu(
	.alu_op(6'b100000),
	.in_s(32'd100),
	.in_t(32'd130),
	.shamt(32'd0),
	.zero(zero),
	.out(out));

initial begin
	$dumpfile(`TRACEFILE);
	$dumpvars(0, alu_tb);

	$monitor("%d + %d = %d", alu.in_s, alu.in_t, out);
end

endmodule
