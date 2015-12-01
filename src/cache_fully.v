`ifndef _cache_fully
`define _cache_fully

`include "defines.v"

///////////
// Cache //
///////////
module cache_fully (
	input wire clk,
	input wire reset,
	input wire [31:0] addr,
	input wire read_write,
	input wire master_enable,
	input wire [BYTES-1:0] byte_enable,
	input wire [WIDTH-1:0] data_in,
	output reg [WIDTH-1:0] data_out = 0,
	output reg hit = 0,
	// Memory ports
	output reg mem_write_req = 0,
	output reg [31:0] mem_write_addr = 0,
	output reg [WIDTH-1:0] mem_write_data = 0,
	input wire mem_write_ack,
	output reg mem_read_req = 0,
	output reg [31:0] mem_read_addr = 0,
	input wire [WIDTH-1:0] mem_read_data,
	input wire mem_read_ack
);

parameter WIDTH = 128; // Bits in cache line
parameter DEPTH = 4; // Number of cache lines
localparam WB = $clog2(WIDTH) - 3; // Width bits
localparam DB = $clog2(DEPTH); // Depth bits
localparam BYTES = 2**WB;

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

wire [WIDTH-1:0] bit_mask;

genvar i;
generate
	for (i = 0; i < BYTES; i = i+1) begin
		assign bit_mask[8*i+7:8*i] = {8{byte_enable[i]}};
	end
endgenerate

reg [DEPTH-1:0] valids = {DEPTH{1'b0}};
reg [31-WB-DB:0] tags [0:DEPTH-1];
reg [WIDTH-1:0] lines [0:DEPTH-1];

// Copy value on hit
always @(posedge clk) begin
	if (reset) begin
		valids <= {DEPTH{1'b0}};
		data_out <= 0;
		mem_write_req <= 0;
		mem_write_addr <= 0;
		mem_write_data <= 0;
		mem_read_req <= 0;
		mem_read_addr <= 0;
		hit <= 0;
	end else begin
		if (mem_write_ack) mem_write_req = 1'b0;
		if (mem_read_ack & !mem_write_req) begin
			`DMSG(("[Cache] fill"))
			lines[mem_read_index] = mem_read_data;
			tags[mem_read_index] = mem_read_tag;
			valids[mem_read_index] = 1'b1;
			mem_read_req = 1'b0;
		end
		hit = valids[index] && (tags[index] == tag);
		if (master_enable) begin
			if (hit) begin
				`DMSG(("[Cache] hit"))
				if (read_write) begin
					data_out = lines[index];
				end else begin
					lines[index] = (lines[index] & ~bit_mask) | (data_in & bit_mask);
					data_out = lines[index];
				end
			end else begin
				if (!mem_read_req && !mem_write_req) begin
					`DMSG(("[Cache] miss"))
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

endmodule

`endif
