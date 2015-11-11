`include "memory.v"

// Memory Testbench
module memory_tb;

reg clk = 0;
reg reset = 0;
reg [31:0] addr = 32'b0;
wire [31:0] rdata;

always #5 clk = !clk;

memory mem(.clk(clk), .addr(addr), .data(instr));

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE)
	$dumpvars(0, memory_tb);
	`endif
	
	#2 addr <= 'h4;
	#10 addr <= 'h8;
	#10 addr <= 'hc;
	#10 $finish;
end

endmodule
