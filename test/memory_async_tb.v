`include "defines.v"
`include "memory_async.v"

module memory_async_tb;

reg reset = 0;
reg [3:0] addr = 0;
reg master_enable = 0;
reg read_write = 0;
reg [31:0] data_in = 0;
wire [31:0] data_out;
wire ack;

memory_async #(
	.DATA("test/memory.raw"),
	.WIDTH(32), .DEPTH(4),
	.LATENCY(100)
) mem (
	.reset(reset),
	.addr({28'h0, addr}),
	.master_enable(master_enable),
	.read_write(read_write),
	.data_in(data_in),
	.data_out(data_out),
	.ack(ack)
);

reg done = 0;

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, memory_async_tb);
	`endif

	reset = 1;
	# 10 begin
		reset = 0;
		addr = 0;
		read_write = 1;
		master_enable = 1;
	end
end

always @(posedge ack) begin
	master_enable = 0;
	addr = addr + 4;
	if (~read_write) begin
		data_in = {8{addr}};
	end
end

always @(negedge ack) begin
	if (!reset) begin
		if (addr == 0) begin
			if (read_write && done) $finish;
			read_write = ~read_write;
			done = 1;
		end
		master_enable = 1;
	end
end

endmodule
