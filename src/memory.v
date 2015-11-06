`ifndef _memory
`define _memory

//
// Main Memory
// 
// Description:
//
// A basic memory implementation.
// On startup loads data from file.
// Currently does not allow to write data.
// 
// Ports:
// clk - Clock signal
// addr - Memory address
// data - Data output
//
//TODO Allow writes
//TODO Add reset
module memory(
	input wire clk,
	input wire reset,
	input wire [31:0] addr,
	input wire [31:0] wdata,
	input wire memwrite,
	input wire memread,
	output reg [31:0] rdata = 0
);

parameter DATA = "mem_data.hex";
parameter MEM_SIZE = 64; // 16 instructions
parameter TAG_SIZE = 6;
// Two least significant bits are ignored

reg [31:0] mem [0:MEM_SIZE/4-1];

initial begin
	$readmemh(DATA, mem);
end

always @(posedge clk) begin
	if (memread) 
		rdata <= mem[addr[TAG_SIZE-1:2]][31:0];
	if (memwrite) 
		mem[addr[TAG_SIZE-1:2]] <= wdata;
end

endmodule

`endif
