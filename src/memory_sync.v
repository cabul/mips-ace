`ifndef _memory_sync
`define _memory_sync

`include "defines.v"

// See: http://www.eecg.toronto.edu/~moshovos/ECE243-2009/lec24-external-interface.html

module memory_sync (
	input wire clk,
	input wire reset,
	input wire [31:0] addr,
	input wire master_enable,
	input wire read_write,
	input wire [3:0] byte_enable,
	input wire [31:0] data_in,
	output reg [31:0] data_out
);

parameter WIDTH = `MEMORY_WIDTH;
parameter DEPTH = `MEMORY_DEPTH;
localparam WB = $clog2(WIDTH) - 3; // Address in bytes
localparam DB = $clog2(DEPTH);

parameter ALIAS = "Memory";

parameter DATA = `MEMORY_DATA;

wire [DB-1:0] index  = addr[WB+DB-1:WB];
wire [WB-1:0] offset = addr[WB-1:0];

reg [WIDTH-1:0] mem [0:DEPTH-1];

wire [31:0] bit_mask;
assign bit_mask[31:24] = {8{byte_enable[3]}};
assign bit_mask[23:16] = {8{byte_enable[2]}};
assign bit_mask[15:8]  = {8{byte_enable[1]}};
assign bit_mask[7:0]   = {8{byte_enable[0]}};

always @(posedge clk) begin
	if (reset) begin
		$readmemh(DATA, mem);
		data_out <= 0;
	end
	else if (master_enable) begin
		if (read_write) begin
			if (WIDTH == 32)
				data_out = mem[index];
			else
				data_out = mem[index][(offset[WB-1:2]+1)*32-1-:32];
			`INFO(("[%s] Read %x => %x", ALIAS, addr[15:0], data_out))
		end else begin
			if (WIDTH == 32) begin
				mem[index] = (mem[index] & ~bit_mask) | (data_in & bit_mask);
				data_out = mem[index];
			end else begin
				mem[index][32*(offset[WB-1:2]+1)-1-:32] =
					(mem[index][32*(offset[WB-1:2]+1)-1-:32] & ~bit_mask) |
					(data_in                                 & bit_mask);
				data_out = mem[index][(offset[WB-1:2]+1)*32-1-:32];
			end
			`INFO(("[%s] Write %x <= %x", ALIAS, addr[15:0], data_out))
		end
	end
end

endmodule

`endif
