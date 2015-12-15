`include "memory_sync.v"
`include "defines.v"

// Memory Testbench
module memory_sync_tb;

reg clk = 0;
reg reset = 0;
reg [31:0] addr;
wire [31:0] data_out;
reg [31:0] data_in;
reg write_enable = 0;
reg byte_enable = 0;

always #5 clk = !clk;

memory_sync #(
	.DATA("test/memory.raw"),
	.WIDTH(32), .DEPTH(4)
) mem(
	.clk(~clk),
	.reset(reset),
	.addr(addr),
	.data_in(data_in),
	.data_out(data_out),
	.byte_enable(byte_enable),
	.master_enable(1),
	.write_enable(write_enable)
);

integer iter = 0;
integer step = 4;

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, memory_sync_tb);
	`endif

	reset = 1;
	addr = 0;
	byte_enable = 0;
	write_enable = 0;
	data_in = 0;

	# 6 reset = 0;

	$display("Test: lw");
end

always @(posedge clk) begin
	if (!reset) begin
		addr = addr + step;
		if (addr == 16) begin
			case (iter)
				0: begin
					$display("Test: lb");
					byte_enable <= 1;
					write_enable <= 0;
					step <= 1;
				end
				1: begin
					$display("Test: sw");
					byte_enable <= 0;
					write_enable <= 1;
					step <= 4;
				end
				2: begin // cont.
					byte_enable <= 0;
					write_enable <= 0;
					step <= 4;
				end
				3: begin
					$display("Test: sb");
					byte_enable <= 1;
					write_enable <= 1;
					step <= 1;
				end 
				4: begin // cont.
					byte_enable <= 0;
					write_enable <= 0;
					step <= 4;
				end
				default: $finish;
			endcase
			iter = iter + 1;
			addr = 0;
		end
		if (write_enable) begin
			data_in = {8{addr[3:0]}};
		end
	end
end

endmodule
