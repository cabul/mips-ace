`ifndef _cache
`define _cache

`include "multiplexer.v"

///////////
// Cache //
//////////
module cache(
	input wire clk,
	input wire reset,
	input wire[31:0] addr,
	output wire[31:0] data,
	output reg hit = 0
);

parameter BLOCKSIZE = 4; // 2^BLOCKSIZE Bytes
parameter ASSOC = 2; // N-way associative
parameter SETS = 2; // 2^SETS sets

wire[ASSOC-1:0] hits;

wire[31-SETS-BLOCKSIZE:0] tag;
wire[SETS-1:0] set; // index
wire[BLOCKSIZE-1:0] offset;

assign offset = addr[BLOCKSIZE-1:0];
assign set = addr[BLOCKSIZE+SETS-1:BLOCKSIZE];
assign tag = addr[31:BLOCKSIZE+SETS];

reg valids[ASSOC-1:0][SETS-1:0];
reg[31-SETS-BLOCKSIZE:0] tags[ASSOC-1:0][SETS-1:0];
// 2^BLOCKSIZE Bytes
reg[2**(BLOCKSIZE+3)-1:0] blocks[ASSOC-1:0][SETS-1:0];

reg[2**(BLOCKSIZE+3)-1:0] block;

// setdata[0][set] => tag

multiplexer #(.N(32), .X(BLOCKSIZE-2)) mux(
	.select(offset[BLOCKSIZE-1:2]),
	.in_data(block),
	.out_data(data)
);

genvar i;
generate
for(i=0; i < ASSOC; i = i+1) begin
	assign hits[i] = (tags[i][set] == tag) && valids[i][set];

	always @(posedge clk) begin
		if (hits[i]) begin
			block <= blocks[i][set];
		end
	end
end
endgenerate

always @(posedge clk) begin
	hit <= | hits;
end

endmodule

`endif
