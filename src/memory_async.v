`ifndef _memory_async
`define _memory_async

`include "defines.v"

// See: http://www.eecg.toronto.edu/~moshovos/ECE243-2009/lec24-external-interface.html

module memory_async (
	input wire reset,
	input wire [31:0] addr,
	input wire master_enable,
	input wire read_write,
	input wire [BYTES-1:0] byte_enable,
	input wire [WIDTH-1:0] data_in,
	output reg [WIDTH-1:0] data_out = 0,
	output reg ack = 0
);

parameter WIDTH = `MEMORY_WIDTH;
parameter DEPTH = `MEMORY_DEPTH;
localparam WB = $clog2(WIDTH) - 3; // Address in bytes
localparam DB = $clog2(DEPTH);
localparam BYTES = 2**WB; // Number of bytes
localparam SIZE = WIDTH * DEPTH / 8;

parameter DATA = `MEMORY_DATA;

parameter LATENCY = `MEMORY_LATENCY;

wire [DB-1:0] index = addr[WB+DB-1:WB];

reg [WIDTH-1:0] mem [0:DEPTH-1];

wire [WIDTH-1:0] bit_mask;

genvar i;
generate
	for (i = 0; i < BYTES; i = i+1) begin
		assign bit_mask[8*i+7:8*i] = {8{byte_enable[i]}};
	end
endgenerate

// Double guard
always @(posedge master_enable) if (!reset) # LATENCY if (!reset) begin
	if (addr >= SIZE) `WARN(("[Memory] Out of bounds"))
	if (read_write) begin
		data_out = mem[index];
		`INFO(("[Memory] Read %x => %x", addr[15:0], data_out))
	end else begin
		mem[index] = (mem[index] & ~bit_mask) | (data_in & bit_mask);
		data_out = mem[index];
		`INFO(("[Memory] Write %x <= %x", addr[15:0], data_out))
	end
	ack = 1;
end

always @(negedge master_enable) if(!reset) # 2 ack <= 1'b0;

always @(posedge reset) begin
	$readmemh(DATA, mem);
	ack <= 1'b0;
	data_out <= {WIDTH{1'b0}};
end

endmodule

`endif
