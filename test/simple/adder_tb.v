`include "adder.v"

// Adder Testbench
module adder_tb;

wire [31:0] out;

adder adder(
	.in_s(32'd100),
	.in_t(32'd4),
	.out(out));

initial begin
	$monitor("%d + %d = %d", adder.in_s, adder.in_t, out);
end

endmodule
