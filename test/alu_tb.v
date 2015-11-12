`include "alu.v"

// ALU Testbench
module alu_tb;

wire zero;
wire [31:0] out;

alu alu(
	.alu_op(6'b100000),
	.s(32'd100),
	.t(32'd130),
	.shamt(32'd0),
	.zero(zero),
	.out(out));

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, alu_tb);
	`endif

	$monitor("%d + %d = %d", alu.s, alu.t, out);
end

endmodule
