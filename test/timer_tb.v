`include "timer.v"

// Timer Testbench
module timer_tb;

wire signal;
reg clk = 0;

timer timer(
	.clk(clk),
	.match(32'd4),
	.signal(signal));

always # 5 clk = !clk;

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, timer_tb);
	`endif

	$monitor("%d", signal);
	# 200 $finish;
end

endmodule
