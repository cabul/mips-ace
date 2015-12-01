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
localparam WB = $clog2(WIDTH) - 3; // Width bits
localparam DB = $clog2(DEPTH); // Depth bits
localparam BYTES = 2**WB;
localparam SETS = 2; // 2-way associative

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

reg [SETS-1:0] set_waiting = {SETS{1'b0}};
wire [SETS-1:0] set_valid;
wire [SETS-1:0] set_hits; // Whether any of the sets has the data
assign hit = | set_hits;

reg lru_status = 1'b0;

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

		assign set_valid[i] = valids[index];
		assign set_hits[i] = (tags[index] == tag) && set_valid[i];

		// Copy value on hit
		always @(posedge clk) begin
			if (reset) valids <= {DEPTH{1'b0}}; // Invalidate all the lines
			else begin
				if (mem_write_ack) mem_write_req = 1'b0;
				if (mem_read_ack & !mem_write_req) begin
					if (set_waiting[i]) begin
						`DMSG(("[Cache] set.%1d fill", i))
						lines[mem_read_index] = mem_read_data;
						tags[mem_read_index] = mem_read_tag;
						valids[mem_read_index] = 1'b1;
						mem_read_req = 1'b0;
						set_waiting[i] = 1'b0;
					end
				end
				if (master_enable) begin
					if (set_hits[i]) begin
						if (read_write) begin
							data_out <= lines[index];
						end else begin
							lines[index] <= (lines[index] & ~bit_mask) | (data_in & bit_mask);
						end
						lru_status <= i;
					end else begin
						if (!hit) begin
							// Stall if we are waiting for a response from memory
							if (!mem_read_req && !mem_write_req) begin
								case (i)
									0: begin
										if (!set_valid[0] || lru_status == 1'b1) begin
											set_waiting[0] = 1'b1;
										end
									end
									1: begin
										if ((set_valid[0] && !set_valid[1]) || lru_status == 1'b0) begin
											set_waiting[1] = 1'b1;
										end
									end
								endcase
								if (set_waiting[i]) begin
									`DMSG(("[Cache] set.%1d miss", i))
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
		lru_status <= 0;
	end
end

endmodule

`endif
