`ifndef _cache_direct
`define _cache_direct

`include "defines.v"

///////////
// Cache //
///////////
module cache_direct (
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

parameter ALIAS = "Cache";

// address = tag | index | offset
wire [WB-1:0]     offset = addr[WB-1:0];
wire [DB-1:0]     index  = addr[WB+DB-1:WB];
wire [31-WB-DB:0] tag    = addr[31:WB+DB];

wire [DB-1:0]     mem_read_index = mem_read_addr[WB+DB-1:WB];
wire [31-WB-DB:0] mem_read_tag   = mem_read_addr[31:WB+DB];

wire [WIDTH-1:0] bit_mask;

genvar i;
generate
	for (i = 0; i < BYTES; i = i+1) begin
		assign bit_mask[8*i+7:8*i] = {8{byte_enable[i]}};
	end
endgenerate

reg [DEPTH-1:0] validbits = {DEPTH{1'b0}};
reg [DEPTH-1:0] dirtybits = {DEPTH{1'b0}};
reg [31-WB-DB:0] tags [0:DEPTH-1];
reg [WIDTH-1:0] lines [0:DEPTH-1];

wire hit_int = tags[index] == tag && validbits[index];

// Handle requests
always @(mem_write_req, mem_write_ack, mem_read_req, mem_read_ack) begin
	if (mem_write_ack) mem_write_req = 1'b0;
	if (mem_read_ack & ~mem_write_req) begin
		`INFO(("[%s] Fill %x <= %x", ALIAS, mem_read_addr[15:0], mem_read_data))
		lines[mem_read_index] = mem_read_data;
		tags[mem_read_index] = mem_read_tag;
		validbits[mem_read_index] = 1'b1;
		dirtybits[mem_read_index] = 1'b0;
		mem_read_req = 1'b0;
	end
end

always @(posedge clk) begin
	if (reset) begin
		// Write all dirties?
		validbits <= {DEPTH{1'b0}};
		dirtybits <= {DEPTH{1'b0}};
		data_out <= 0;
		hit <= 0;
		mem_write_req <= 0;
		mem_write_addr <= 0;
		mem_write_data <= 0;
		mem_read_req <= 0;
		mem_read_addr <= 0;
	end else begin
		if (master_enable) begin
			hit <= hit_int;
			if (hit_int) begin
				if (read_write) begin
					data_out = lines[index];
					`INFO(("[%s] Hit %x => %x", ALIAS, addr[15:0], data_out))
				end else begin
					lines[index] = (lines[index] & ~bit_mask) | (data_in & bit_mask);
					dirtybits[index] = 1'b1;
					data_out = lines[index];
					`INFO(("[%s] Hit %x <= %x", ALIAS, addr[15:0], data_out))
				end
			end else begin
				// Wait for memory
				if (~mem_read_req & ~mem_write_req) begin
					`INFO(("[%s] Miss %x", ALIAS, addr[15:0]))
					// Save line if necessary
					if (validbits[index] & dirtybits[index]) begin
						mem_write_addr = {tags[index], index, {WB{1'b0}}};
						mem_write_data = lines[index];
						`INFO(("[%s] Evict %x => %x", ALIAS, mem_write_addr[15:0], mem_write_data))
						mem_write_req = 1'b1;
					end
					validbits[index] = 1'b0;
					// Memory request
					mem_read_addr = addr;
					mem_read_req = 1'b1;
				end
			end
		end else hit <= 1'b0;
	end
end

endmodule

`endif
