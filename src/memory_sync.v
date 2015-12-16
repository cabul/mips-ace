`ifndef _memory_sync
`define _memory_sync

`include "defines.v"

// See: http://www.eecg.toronto.edu/~moshovos/ECE243-2009/lec24-external-interface.html

module memory_sync (
	input wire clk,
	input wire reset,
	input wire [31:0] addr,
	input wire master_enable,
	input wire write_enable,
	input wire byte_enable,
	input wire [31:0] data_in,
	output reg [31:0] data_out = 0
);

parameter WIDTH = `MEMORY_WIDTH;
parameter DEPTH = `MEMORY_DEPTH;
localparam WB = $clog2(WIDTH) - 3; // Address in bytes
localparam DB = $clog2(DEPTH);

parameter ALIAS = "memory";

parameter DATA = `MEMORY_DATA;

wire [DB-1:0] index  = addr[WB+DB-1:WB];
wire [WB-1:0] offset = addr[WB-1:0];

reg [WIDTH-1:0] mem [0:DEPTH-1];

wire [WIDTH-1:0] line_out = mem[index];
wire [31:0] word_out      = (WIDTH == 32) ?
	line_out :
	line_out[(addr[WB-1:2]+1)*32-1-:32]; 
wire [7:0] byte_out       = line_out[(offset+1)*8-1-:8];

always @* if (master_enable & ~reset) begin
	if (byte_enable) data_out <= {24'h000000, byte_out};
	else data_out <= word_out;
end else data_out <= 32'h00000000;

always @(posedge clk) begin
	if (reset) $readmemh(DATA, mem);
	else if (master_enable) begin
		if (write_enable) begin
			if (byte_enable) mem[index][(offset+1)*8-1-:8] = data_in[7:0];
			else if (WIDTH == 32) mem[index] = data_in;
			else mem[index][(addr[WB-1:2]+1)*32-1-:32] = data_in;
			`INFO(("[%s] Write %x <= %x", ALIAS, addr[15:0], data_in))
		end else `INFO(("[%s] Read %x => %x", ALIAS, addr[15:0], data_out))
	end
end

endmodule

`endif
