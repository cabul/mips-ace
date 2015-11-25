`include "defines.v"
`include "mainmemory.v"

module mainmemory_tb;

reg reset = 0;
reg [3:0] addr = 0;
reg master_enable = 0;
reg read_write = 0;
reg [3:0] byte_enable = 0;
reg [31:0] data_in = 0;
wire [31:0] data_out;
wire ack;

mainmemory #(
	.DATA("test/memory.raw"),
	.WIDTH(32), .DEPTH(4),
	.LATENCY(100)
) mem (
	.reset(reset),
	.addr({28'h0, addr}),
	.master_enable(master_enable),
	.read_write(read_write),
	.byte_enable(byte_enable),
	.data_in(data_in),
	.data_out(data_out),
	.ack(ack)
);

reg done = 0;

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, mainmemory_tb);
	`endif

	reset = 1;
	byte_enable = 4'b0001;
	# 10 begin
		reset = 0;
		addr = 0;
		read_write = 1;
		master_enable = 1;
	end
end

always @(posedge ack) begin
	if (read_write)
		$display("%4t # Read.%x  => %x", $time, addr, data_out);
	master_enable = 0;
	addr = addr + 1;
	if (!read_write) begin
		byte_enable = byte_enable << 1;
		if (byte_enable == 4'b0000) byte_enable = 4'b0001;
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
		if (!read_write)
			$display("%4t # Write.%x <= %x [%b]", $time, addr, data_in, byte_enable);
		master_enable = 1;
	end
end

endmodule
