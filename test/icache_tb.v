`include "icache.v"

module icache_tb;

reg clk = 0;
reg reset = 0;

reg[31:0] addr = 0;
wire[31:0] data;
wire hit;

icache icache(
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
	$dumpvars(0, icache_tb);
	`endif

	# 10 addr <= 32'h00400040;
	# 10 addr <= 32'h0030e042;
	# 10 $finish;

end

endmodule
