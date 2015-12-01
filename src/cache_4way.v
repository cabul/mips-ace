`ifndef _cache_4way
`define _cache_4way

`include "defines.v"

///////////
// Cache //
///////////
module cache_4way (
	input wire clk,
	input wire reset,
	input wire [31:0] addr,
	input wire read_write,
	input wire master_enable,
	input wire [BYTES-1:0] byte_enable,
	input wire [WIDTH-1:0] data_in,
	output reg [WIDTH-1:0] data_out,
	output wire hit,
	// Memory ports
	output reg mem_write_req,
	output reg [31:0] mem_write_addr,
	output reg [WIDTH-1:0] mem_write_data,
	input wire mem_write_ack,
	output reg mem_read_req,
	output reg [31:0] mem_read_addr,
	input wire [WIDTH-1:0] mem_read_data,
	input wire mem_read_ack
);

parameter WIDTH = 128; // Bits in cache line
parameter DEPTH = 4; // Number of cache lines
parameter SETS = 2; // 2-way associative
localparam WB = $clog2(WIDTH) - 3; // Width bits
localparam DB = $clog2(DEPTH); // Depth bits
localparam BYTES = 2**WB;

reg [SETS-1:0] hits; // Whether any of the sets has the data
assign hit = | hits;

// address = tag | index | offset
wire [WB-1:0]     offset; // Offset is ignored!? Fetch whole line
wire [DB-1:0]     index;
wire [31-WB-DB:0] tag;

assign offset = addr[WB-1:0];
assign index  = addr[WB+DB-1:WB];
assign tag    = addr[31:WB+DB];

wire [DB-1:0]     mem_read_index;
wire [31-WB-DB:0] mem_read_tag;
assign mem_read_index  = mem_read_addr[WB+DB-1:WB];
assign mem_read_tag    = mem_read_addr[31:WB+DB];

reg [SETS-1:0] waiting = {SETS{1'b0}};

wire [WIDTH-1:0] bit_mask;

genvar i;
generate
	for (i = 0; i < BYTES; i = i+1) begin
		assign bit_mask[8*i+7:8*i] = {8{byte_enable[i]}};
	end
endgenerate

generate
	for(i=0; i < SETS; i = i+1) begin
		// Create set
		reg [DEPTH-1:0] valids;
		reg [31-WB-DB:0] tags [0:DEPTH-1];
		reg [WIDTH-1:0] lines [0:DEPTH-1];

		// Copy value on hit
		always @(posedge clk) begin
			if (reset) valids <= {DEPTH{1'b0}}; // Invalidate all the lines
			else begin
				if (mem_write_ack) mem_write_req = 1'b0;
				if (mem_read_ack & !mem_write_req) begin
					if (waiting[i]) begin
						`DMSG(("[Set %1d] replace", i))
						lines[mem_read_index] = mem_read_data;
						tags[mem_read_index] = mem_read_tag;
						valids[mem_read_index] = 1'b1;
						mem_read_req = 1'b0;
						waiting[i] = 1'b0;
					end
				end
				if (master_enable) begin
					hits[i] = (tags[index] == tag) && valids[index];
					if (hits[i]) begin
						if (read_write) begin
							data_out <= lines[index];
						end else begin
							lines[index] <= (lines[index] & ~bit_mask) | (data_in & bit_mask);
						end
					end else begin
						// Only handle one miss at a time, aka wait for memory
						if (!hit) begin
							if (!mem_read_req && !mem_write_req) begin
								if (replace[i]) begin
									`DMSG(("[Set %1d] next", i))
									// Save line if necessary
									if (valids[index]) begin
										valids[index] = 1'b0;
										mem_write_addr = {tags[index], index, {WB{1'b0}}};
										mem_write_data = lines[index];
										mem_write_req = 1'b1;
									end
									// Memory request
									mem_read_addr = addr;
									mem_read_req = 1'b1;
								end
							end
						end
					end
				end
			end
		end
	end
endgenerate

always @(posedge clk) begin
	if (reset) begin
		mem_write_req <= 0;
		mem_read_req <= 0;
		data_out <= 0;
	end
end

endmodule

`endif
