`ifndef _cache
`define _cache

///////////
// Cache //
///////////
module cache (
	input wire clk,
	input wire reset,
	input wire [31:0] addr,
	output reg [WIDTH-1:0] data,
	output reg hit = 0
);

parameter WIDTH = 128; // Bits in cache line
parameter DEPTH = 4; // Number of cache lines
parameter SETS = 2; // 2-way associative
localparam WB = $clog2(WIDTH); // Width bits
localparam DB = $clog2(DEPTH); // Depth bits

wire [SETS-1:0] hits; // Whether any of the sets has the data

// address = tag | index | offset
wire [WB-1:0]     offset; // Offset is ignored!? Fetch whole line
wire [DB-1:0]     index;
wire [31-WB-DB:0] tag;

assign offset = addr[WB-1:0];
assign index  = addr[WB+DB-1:WB];
assign tag    = addr[31:WB+DB];

genvar i;
generate
	for(i=0; i < SETS; i = i+1) begin
		// Create set
		reg valids [0:DEPTH-1];
		reg [31-WB-DB:0] tags [0:DEPTH-1];
		reg [WIDTH-1:0] lines [0:DEPTH-1];
	
		assign hits[i] = tags[index] == tag && valids[index];
	
		// Copy value on hit
		always @(posedge clk)
			if (hits[i]) data <= lines[index];
	end
endgenerate

always @(posedge clk) hit <= | hits;

endmodule

`endif
