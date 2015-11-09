`ifndef _memory
`define _memory

`include "defines.v"

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
//TODO Update doc
module memory(
	input wire clk,
	input wire reset,
	input wire [31:0] addr,
	input wire [31:0] wdata,
	input wire memwrite,
	input wire memread,
	output reg [31:0] rdata = 0
);

parameter MEMDATA_IN = `MEMDATA_IN;
//parameter MEMDATA_OUT = `MEMDATA_OUT
parameter MEMDATA_LEN = `MEMDATA_LEN;

reg [31:0] mem [0:MEMDATA_LEN-1];

initial begin
	$readmemh(MEMDATA_IN, mem);
end

always @(posedge clk) begin
	if (memread) 
		rdata <= mem[addr[$clog2(MEMDATA_LEN)-1:2]][31:0];
	if (memwrite) 
		mem[addr[$clog2(MEMDATA_LEN)-1:2]] <= wdata;
end

endmodule

`endif
