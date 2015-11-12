`include "multiplexer.v"

// Testbench Multiplexer
module multiplexer_tb;

reg [31:0] a = 32'd2015;
reg [31:0] b = 32'd1337;
wire [31:0] c;

// indexes right to left -> in_data({3,2,1,0})

multiplexer mux(
	.in_data({a, b}),
	.out_data(c),
	.select(1'b0));

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, multiplexer_tb);
	`endif

	# 1
	$display("%d <- c", c);
end

endmodule
