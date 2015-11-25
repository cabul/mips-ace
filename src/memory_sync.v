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
	input wire [BYTES-1:0] byte_enable,
	input wire [WIDTH-1:0] data_in,
	output reg [WIDTH-1:0] data_out
);

parameter WIDTH = `MEMORY_WIDTH;
parameter DEPTH = `MEMORY_DEPTH;
localparam WB = $clog2(WIDTH) - 3; // Address in bytes
localparam DB = $clog2(DEPTH);
localparam BYTES = 2**WB; // Number of bytes

parameter DATA = `MEMORY_DATA;

wire [DB-1:0] index;
assign index = addr[WB+DB-1:WB];

reg [WIDTH-1:0] mem [0:DEPTH-1];

wire [WIDTH-1:0] bit_mask;

genvar i;
generate
	for (i = 0; i < BYTES; i = i+1) begin
		assign bit_mask[8*i+7:8*i] = {8{byte_enable[i]}};
	end
endgenerate

`ifdef DEBUG
integer err;
`endif

always @(posedge clk) begin
	if (reset) begin
		$readmemh(DATA, mem);
		data_out = 0;
	end else if (master_enable) begin

		`ifdef DEBUG
		if (addr < 'hFFFF_FFF0) begin
		`endif

		if (read_write)
			data_out = mem[index];
		else
			mem[index] = (mem[index] & ~bit_mask) | (data_in & bit_mask);

		`ifdef DEBUG
		end else begin
			$display("--> %x %d", addr, read_write);
			if (read_write)
				case (addr[3:0])
					4'h2: data_out = $fgetc('h8000_0000);
					4'h1: err = $fscanf('h8000_0000, "%d", data_out);
					4'h0: err = $fscanf('h8000_0000, "%x", data_out);
				endcase
			else
				case (addr[3:0])
					4'hF: $finish;
					4'h2: $write("%c", data_in);
					4'h1: $write("%d", data_in);
					4'h0: $display("%x", data_in);
				endcase
		end
		`endif

	end
end

endmodule

`endif
