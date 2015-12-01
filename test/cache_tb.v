`include "defines.v"
`include "memory_async.v"
`include "cache_fully.v"
`include "cache_2way.v"
//`include "cache_4way.v"

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

memory_async #(
	.DATA("test/memory.raw"),
	.WIDTH(32),
	.DEPTH(4),
	.LATENCY(27)
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
reg cache_rw = 1;
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
cache_fully
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

always @(posedge cache_mem_read_req) begin
	`DMSG(("[Test] req read addr %x", cache_mem_read_addr))
	mem_rw = 1;
	mem_addr = cache_mem_read_addr;
	mem_enable = 1;
end

always @(posedge mem_ack) #1 begin
	`DMSG(("[Test] ack read data %x", mem_data_out))
	cache_mem_read_data = mem_data_out;
	cache_mem_read_ack = 1;
end

always @(negedge cache_mem_read_req) begin
	mem_enable = 0;
end

always @(negedge mem_ack) begin
	cache_mem_read_ack = 0;
end

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, cache_tb);
	`endif

	cache_rw <= 1;
	cache_enable <= 1;
	cache_addr <= 32'h400;

	reset <= 1;
	# 10 reset <= 0;

	# 100 cache_addr <= 32'h404;
	# 100 cache_addr <= 32'h408;
	# 100 cache_addr <= 32'h40C;
	
	# 100 cache_addr <= 32'h400;

	# 2000 $finish;
end

endmodule
