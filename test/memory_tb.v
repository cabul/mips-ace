`include "memory.v"
`include "defines.v"

// Memory Testbench
module memory_tb;

reg clk = 0;
reg reset = 0;
reg [31:0] addr = 32'b0;
reg memwrite = 0;
reg memread = 1;
wire [15:0] rdata;
reg [15:0] wdata;

always #5 clk = !clk;

memory #(
	.DATA("test/memory_tb.dat"),
	.WIDTH(16), .DEPTH(4)
) mem(
	.clk(clk),
	.reset(reset),
	.addr(addr),
	.rdata(rdata),
	.wdata(wdata),
	.memwrite(memwrite),
	.memread(memread)
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

	#2  addr <= 32'h00;
	#10 addr <= 32'h08;
	#10 addr <= 32'h10;
	#10 addr <= 32'h18;
	#10 begin
		memwrite <= 1;
		memread <= 0;
		addr <= 32'h00;
		wdata <= 16'h0;
	end
	#10 begin
		addr <= 32'h08;
		wdata <= 16'h1;
	end
	#10 begin
		addr <= 32'h10;
		wdata <= 16'h2;
	end
	#10 begin
		addr <= 32'h18;
		wdata <= 16'h3;
	end
	#10 begin
		addr <= 32'h00;
		memwrite <= 0;
		memread <= 1;
	end
	#10 addr <= 32'h08;
	#10 addr <= 32'h10;
	#10 addr <= 32'h18;
	#10 $finish;
end

endmodule
