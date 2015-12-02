`include "defines.v"
`include "memory_async.v"
`include "cache_direct.v"
`include "cache_2way.v"
`include "cache_4way.v"

module cache_tb;

reg clk = 0;
reg reset = 0;

always #5 clk = ~clk;

reg [31:0] mem_addr = 0;
reg [31:0] mem_data_in = 0;
wire [31:0] mem_data_out; 
reg mem_enable = 0;
reg mem_rw = 0;
wire mem_ack;

`ifndef MEMORY_LATENCY
`define MEMORY_LATENCY 27
`endif

memory_async #(
	.DATA("test/memory.raw"),
	.WIDTH(32),
	.DEPTH(4),
	.LATENCY(`MEMORY_LATENCY)
) memory (
	.reset(reset),
	.master_enable(mem_enable),
	.addr(mem_addr),
	.read_write(mem_rw),
	.byte_enable(4'hf),
	.data_in(mem_data_in),
	.data_out(mem_data_out),
	.ack(mem_ack)
);

reg [31:0] cache_addr = 0;
reg [31:0] cache_data_in = 0;
wire [31:0] cache_data_out;
reg cache_enable = 1;
wire cache_rw;
// Write to odd addresses
assign cache_rw = ~cache_addr[4];
wire cache_hit;

reg [31:0] cache_mem_read_data = 0;
wire [31:0] cache_mem_read_addr;
wire cache_mem_read_req;
reg cache_mem_read_ack = 0;

wire [31:0] cache_mem_write_data;
wire [31:0] cache_mem_write_addr;
wire cache_mem_write_req;
reg cache_mem_write_ack = 0;

`ifdef CACHE_2WAY
cache_2way
`elsif CACHE_4WAY
cache_4way
`else
cache_direct
`endif
#(
	.WIDTH(32),
	.DEPTH(4)
) cache (
	.clk(clk),
	.reset(reset),
	.addr(cache_addr),
	.data_in(cache_data_in),
	.data_out(cache_data_out),
	.master_enable(cache_enable),
	.byte_enable(4'hf),
	.read_write(cache_rw),
	.hit(cache_hit),
	.mem_read_data(cache_mem_read_data),
	.mem_read_addr(cache_mem_read_addr),
	.mem_read_req(cache_mem_read_req),
	.mem_read_ack(cache_mem_read_ack),
	.mem_write_data(cache_mem_write_data),
	.mem_write_addr(cache_mem_write_addr),
	.mem_write_req(cache_mem_write_req),
	.mem_write_ack(cache_mem_write_ack)
);

reg [1:0] mem_state = 2'b00;

always @* begin
	case (mem_state)
		2'b00: begin // Initial
			if (cache_mem_write_req) begin
				mem_state = 2'b10;
				mem_rw = 0;
				mem_addr = cache_mem_write_addr;
				mem_data_in = cache_mem_write_data;
				mem_enable = 1;
			end else if (cache_mem_read_req) begin
				mem_state = 2'b01;
				mem_rw = 1;
				mem_addr = cache_mem_read_addr;
				mem_enable = 1;
			end
		end
		// Connect the wires
		2'b01: begin // Reading
			cache_mem_read_ack = mem_ack;
			mem_enable = cache_mem_read_req;
		end
		2'b10: begin // Writing
			cache_mem_write_ack = mem_ack;
			mem_enable = cache_mem_write_req;
		end
	endcase
end

// Reset initial state with clock
always @(posedge clk) if (!mem_enable && !mem_ack) mem_state = 2'b00;


initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, cache_tb);
	`endif

	cache_enable <= 1;
	cache_addr <= 32'h000;

	reset <= 1;
	# 10 reset <= 0;

	# 100 cache_addr <= 32'h004;
	# 100 cache_addr <= 32'h008;
	# 100 cache_addr <= 32'h00C;

	# 100 cache_addr <= 32'h010;
	# 100 cache_addr <= 32'h014;
	# 100 cache_addr <= 32'h018;
	# 100 cache_addr <= 32'h01C;

	# 100 cache_addr <= 32'h020;
	# 100 cache_addr <= 32'h024;
	# 100 cache_addr <= 32'h028;
	# 100 cache_addr <= 32'h02C;

	# 100 cache_addr <= 32'h030;
	# 100 cache_addr <= 32'h034;
	# 100 cache_addr <= 32'h038;
	# 100 cache_addr <= 32'h03C;

	# 100 cache_addr <= 32'h040;
	# 100 cache_addr <= 32'h044;
	# 100 cache_addr <= 32'h048;
	# 100 cache_addr <= 32'h04C;

	# 2000 $finish;
end

endmodule
