`include "comparator.v"

`ifndef TRACEFILE
`define TRACEFILE "traces/comperator_tb.vcd"
`endif

// Comparator Testbench
module comparator_tb;

wire cmp;

comparator comparator(
	.in_a(32'd23),
	.in_b(32'd2),
	.equal(cmp));

initial begin
	// Generate Trace
	$dumpfile(`TRACEFILE);
	$dumpvars(0, comparator_tb);
	
	# 1
	$display("%d <- cmp", cmp);
end

endmodule
