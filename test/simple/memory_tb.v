`include "memory.v"

/// Memory Testbench
module memory_tb;

reg clk = 0;
reg [31:0] addr = 32'b0;
wire [31:0] instr;

always #5 clk = !clk;

imem #(.DATA("data/mem_data.hex")) im(.clk(clk), .addr(addr), .data(instr));

initial begin
	$dumpfile("traces/memory_tb.vcd");
	$dumpvars(0, memory_tb);
	
	#2 addr <= 'h4;
	#10 addr <= 'h8;
	#10 addr <= 'hc;
	#10 $finish;
end

endmodule
