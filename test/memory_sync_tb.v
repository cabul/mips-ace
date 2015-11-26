`include "memory_sync.v"
`include "defines.v"

// Memory Testbench
module memory_sync_tb;

reg clk = 0;
reg reset = 0;
reg [31:0] addr;
reg read_write;
reg [3:0] byte_enable;
wire [31:0] data_out;
reg [31:0] data_in;

always #5 clk = !clk;

memory_sync #(
	.DATA("test/memory.raw"),
	.WIDTH(32), .DEPTH(4)
) mem(
	.clk(clk),
	.reset(reset),
	.addr(addr),
	.data_in(data_in),
	.data_out(data_out),
	.byte_enable(byte_enable),
	.master_enable(1),
	.read_write(read_write)
);

reg done = 0;

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, memory_sync_tb);
	`endif

	reset = 1;
	addr = 0;
	byte_enable = 4'b0000;
	read_write = 1;
	data_in = 0;

	# 10 reset = 0;
end

always @(posedge clk) begin
	if (!reset) begin
		if (read_write)
			$display("%4t # Read.%x  => %x", $time, addr, data_out);
		else
			$display("%4t # Write.%x <= %x [%b]", $time, addr, data_in, byte_enable);
		addr = addr + 1;
		if (addr == 16) begin
			if (read_write && done) $finish;
			read_write = ~read_write;
			done = 1;
			addr = 0;
		end
		if (!read_write) begin
			byte_enable = byte_enable << 1;
			if (byte_enable == 4'b0000) byte_enable = 4'b0001;
			data_in = {8{addr[3:0]}};
		end
	end
end

endmodule
