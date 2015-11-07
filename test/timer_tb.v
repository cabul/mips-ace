`include "timer.v"

`ifndef TRACEFILE
`define TRACEFILE "traces/timer_tb.vcd"
`endif

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
	$dumpfile(`TRACEFILE);
	$dumpvars(0, timer_tb);

	$monitor("%d", signal);
	# 200 $finish;
end

endmodule
