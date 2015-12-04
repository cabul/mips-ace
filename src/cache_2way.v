`ifndef _cache_2way
`define _cache_2way

`include "defines.v"

///////////
// Cache //
///////////
module cache_2way (
	input wire clk,
	input wire reset,
	input wire [31:0] addr,
	input wire read_write,
	input wire master_enable,
	input wire [BYTES-1:0] byte_enable,
	input wire [WIDTH-1:0] data_in,
	output reg [WIDTH-1:0] data_out,
	output reg hit,
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
localparam WB = $clog2(WIDTH) - 3; // Width bits
localparam DB = $clog2(DEPTH); // Depth bits
localparam BYTES = 2**WB;
localparam SETS = 2; // 2-way associative

parameter ALIAS = "Cache";

// address = tag | index | offset
wire [WB-1:0]     offset = addr[WB-1:0];
wire [DB-1:0]     index  = addr[WB+DB-1:WB];
wire [31-WB-DB:0] tag    = addr[31:WB+DB];

wire [DB-1:0]     mem_read_index = mem_read_addr[WB+DB-1:WB];
wire [31-WB-DB:0] mem_read_tag   = mem_read_addr[31:WB+DB];

// Global set variables
reg [SETS-1:0] set_select = {SETS{1'b0}};
wire [SETS-1:0] set_valid;
wire [SETS-1:0] set_hit; // Whether any of the sets has the data

wire hit_int = | set_hit;

wire all_valid = & set_valid;

wire [WIDTH-1:0] bit_mask;

genvar i;
generate
	for (i = 0; i < BYTES; i = i+1) begin
		assign bit_mask[8*i+7:8*i] = {8{byte_enable[i]}};
	end
endgenerate

reg lru_state = 1'b0;

generate for(i=0; i < SETS; i = i+1) begin
	// Create set
	reg [DEPTH-1:0] validbits = {DEPTH{1'b0}};
	reg [DEPTH-1:0] dirtybits = {DEPTH{1'b0}};
	reg [31-WB-DB:0] tags [0:DEPTH-1];
	reg [WIDTH-1:0] lines [0:DEPTH-1];

	assign set_valid[i] = validbits[index];
	assign set_hit[i] = (tags[index] == tag) && set_valid[i];

	// Handle requsts
	always @* begin
		if (set_select[i]) begin
			if (mem_write_ack) mem_write_req = 1'b0;
			if (mem_read_ack && !mem_write_req) begin
				`INFO(("[%s] .%1d Fill %x <= %x", ALIAS, i, mem_read_addr[15:0], mem_read_data))
				lines[mem_read_index] = mem_read_data;
				tags[mem_read_index] = mem_read_tag;
				validbits[mem_read_index] = 1'b1;
				dirtybits[mem_read_index] = 1'b0;
				mem_read_req = 1'b0;
				// Deselect
				set_select[i] = 1'b0;
			end
		end
	end

	always @(posedge clk) begin
		if (reset) begin
			validbits <= {DEPTH{1'b0}};
			dirtybits <= {DEPTH{1'b0}};
		end else begin
			if (master_enable) begin
				if (set_hit[i]) begin
					if (read_write) begin
						data_out = lines[index];
						`INFO(("[%s] .%d Hit %x => %x", ALIAS, i, addr[15:0], data_out))
					end else begin
						lines[index] = (lines[index] & ~bit_mask) | (data_in & bit_mask);
						dirtybits[index] = 1'b1;
						data_out = lines[index];
						`INFO(("[%s] .%d Hit %x <= %x", ALIAS, i, addr[15:0], data_out))
					end
					// Update LRU
					lru_state = i;
				end else begin
					if (!hit_int) begin
						// Wait for memory
						if (!mem_read_req && !mem_write_req) begin
							// Select set
							case (i)
								0: if (set_valid[0] == 1'b0 ||
									(all_valid && lru_state == 1'b1))
										set_select[0] = 1'b1;
								1: if (set_valid == 2'b01 ||
									(all_valid && lru_state == 1'b0))
										set_select[1] = 1'b1;
							endcase
							// Issue requests
							if (set_select[i]) begin
								`INFO(("[%s] .%1d Miss %x", ALIAS, i, addr[15:0]))
								// Save line if necessary
								if (validbits[index] && dirtybits[index]) begin
									mem_write_addr = {tags[index], index, {WB{1'b0}}};
									mem_write_data = lines[index];
									`INFO(("[%s] .%1d Evict %x => %x", ALIAS, i, mem_write_addr[15:0], mem_write_data))
									mem_write_req = 1'b1;
								end
								validbits[index] = 1'b0;
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
end endgenerate

always @(posedge clk) begin
	if (reset) begin
		mem_write_req <= 0;
		mem_write_addr <= 0;
		mem_write_data <= 0;
		mem_read_req <= 0;
		mem_read_addr <= 0;
		data_out <= 0;
		lru_state <= 0;
	end else if (master_enable)
		hit <= hit_int;
	else hit <= 1'b0;
end

endmodule

`endif
