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

	`ifdef DEBUG
	$display("[DEBUG] Memory Width = %4d", `MEMORY_WIDTH);
	$display("[DEBUG] Memory Depth = %4d", `MEMORY_DEPTH);
	`endif

	reset <= 1;
	# 15 reset <= 0;

	# 300000 begin
		$display("It's a trap!");
		$finish;
	end
end

endmodule
