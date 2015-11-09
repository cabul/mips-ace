`include "cpu.v"

`ifndef TRACEFILE
`define TRACEFILE "traces/cpu_tb.vcd"
`endif

// Simple CPU
module cpu_tb;

reg clk = 0;
reg reset = 0;

cpu cpu(.clk(clk), .reset(reset));

always #5 clk = !clk;

initial begin
	$dumpfile(`TRACEFILE);
	$dumpvars(0, cpu_tb);
	reset <= 1;
	# 10 reset <= 0;


	# 10000 $finish;
end

endmodule
