`ifndef _regfile
`define _regfile

`include "defines.v"

module regfile(
	`ifdef DEBUG
	output wire [WIDTH*DEPTH-1:0] dbg_mem,
	`endif
	input wire clk,
	input wire reset,
	input wire [ADDR-1:0] rreg1, rreg2,
	output reg [WIDTH-1:0] rdata1 = {WIDTH{1'b0}},
	output reg [WIDTH-1:0] rdata2 = {WIDTH{1'b0}},
	input wire regwrite,
	input wire [ADDR-1:0] wreg,
	input wire [WIDTH:0] wdata
);

parameter WIDTH = 32;
parameter DEPTH = 32;
localparam ADDR = $clog2(WIDTH);
integer i;

reg [WIDTH-1:0] mem [DEPTH-1:0];

`ifdef DEBUG
genvar j;
generate
for (j = 0; j < DEPTH; j = j + 1) begin
	assign dbg_mem[WIDTH*j+WIDTH-1:WIDTH*j] = mem[DEPTH-1-j];
end
endgenerate
`endif

always @* begin
	if (rreg1 == {ADDR{1'b0}})
		rdata1 <= {WIDTH{1'b0}};
	else begin
		rdata1 <= mem[rreg1][WIDTH-1:0];
		`DMSG(("[REGFILE] Read $%d => %x", rreg1, mem[rreg1][WIDTH-1:0]))
	end
end

always @* begin
	if (rreg2 == {ADDR{1'b0}})
		rdata2 <= {WIDTH{1'b0}};
	else begin
		rdata2 <= mem[rreg2][WIDTH-1:0];
		`DMSG(("[REGFILE] Read $%d => %x", rreg2, mem[rreg2][WIDTH-1:0]))
	end
end

always @(posedge clk) begin
	if (reset) begin
		for (i = 0; i < DEPTH; i = i+1) begin
			mem[i] <= {WIDTH{1'b0}};
		end
	end
	else if (regwrite && wreg != {ADDR{1'b0}}) begin
		mem[wreg] <= wdata;
		`DMSG(("[REGFILE] Write $%d <= %x", wreg, wdata))
	end
end

endmodule

`endif
