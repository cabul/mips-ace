`include "cache.v"

module cache_tb;

reg clk = 0;
reg reset = 0;

reg[31:0] addr = 0;
wire[31:0] data;
wire hit;

cache cache(
	.clk(clk),
	.reset(reset),
	.addr(addr),
	.data(data),
	.hit(hit)
);

always #5 clk = !clk;

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, cache_tb);
	`endif

	# 10 addr <= 32'h00400040;
	# 10 addr <= 32'h0030e042;
	# 10 $finish;

end

endmodule
