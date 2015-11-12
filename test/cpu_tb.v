`include "cpu.v"

// Simple CPU
module cpu_tb;

reg clk = 0;
reg reset = 0;

cpu cpu(.clk(clk), .reset(reset));

always #5 clk = !clk;

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, cpu_tb);
	`endif

	reset <= 1;
	# 12 reset <= 0;


	# 10000 $finish;
end

endmodule
