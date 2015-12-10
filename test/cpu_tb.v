`include "cpu.v"
`include "memory_async.v"

// Simple CPU
module cpu_tb;
integer cycle = 0;

reg clk = 1;
reg reset = 0;

localparam WIDTH = `MEMORY_WIDTH;
localparam BYTES = WIDTH / 8;

wire mem_enable;
wire mem_rw;
wire mem_ack;
wire [31:0] mem_addr;
wire [WIDTH-1:0] mem_data_in;
wire [WIDTH-1:0] mem_data_out;

cpu cpu (
	.clk(clk),
	.reset(reset),
	// Memory ports
	.mem_enable(mem_enable),
	.mem_rw(mem_rw),
	.mem_ack(mem_ack),
	.mem_addr(mem_addr),
	.mem_data_in(mem_data_in),
	.mem_data_out(mem_data_out)
);

memory_async mem (
	.reset(reset),
	.addr(mem_addr),
	.master_enable(mem_enable),
	.read_write(mem_rw),
	.byte_enable({BYTES{1'b1}}),
	.data_in(mem_data_in),
	.data_out(mem_data_out),
	.ack(mem_ack)
);

always #5 clk = ~clk;

always @(posedge clk) if(!reset) cycle = cycle + 1;

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, cpu_tb);
	`endif

	reset <= 1;
	# 10 reset <= 0;
	cycle = 0;

	# 3000000 begin
		$display("It's a trap!");
		$finish;
	end
end

endmodule
