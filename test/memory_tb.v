`include "memory.v"
`include "defines.v"

// Memory Testbench
module memory_tb;

reg clk = 0;
reg reset = 0;
reg [31:0] addr = 32'b0;
wire [15:0] rdata;

always #5 clk = !clk;

memory #(
	.DATA("test/memory_tb.hex"),
	.WIDTH(2), .DEPTH(4)
) mem(
	.clk(clk),
	.reset(reset),
	.addr(addr),
	.rdata(rdata),
	.wdata(16'b0),
	.memwrite(0),
	.memread(1)
);

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, memory_tb);
	`endif

	$display("Clock    Address     Read");
	$display("-----    -------     ----");
	$monitor("%x        %x    %x", clk, addr, rdata);

	reset <= 1;
	# 10 reset <= 0;

	#2 addr <= 'h4;
	#10 addr <= 'h8;
	#10 addr <= 'hc;
	#10 $finish;
end

endmodule
