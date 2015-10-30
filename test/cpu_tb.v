`include "cpu.v"

// Simple CPU
module cpu_tb;

reg clk = 0;
reg reset = 0;

cpu cpu(.clk(clk), .reset(reset));

always #5 clk = !clk;

initial begin
	$dumpfile("traces/cpu_tb.vcd");
	$dumpvars(0, cpu_tb);

	#40 $finish;
end

endmodule
