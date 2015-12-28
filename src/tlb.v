`ifndef _tlb
`define _tlb

`include "defines.v"

module tlb (
	input wire clk,
	input wire reset,

	input wire read_enable,
	input wire write_enable,

	input wire [31:0] index_in,
	output reg [31:0] index_out,

	input wire [31:0] vaddr,
	output reg [31:0] paddr = 0,
	output reg hit = 0,
	output reg valid = 0,

	input wire [31:0] wr_vaddr,
	input wire [31:0] wr_paddr
);

parameter DEPTH = `TLB_DEPTH;
parameter PAGE_SIZE = `PAGE_SIZE;
parameter ALIAS = "tlb";

localparam DB = $clog2(DEPTH);     // Depth bits
localparam PB = $clog2(PAGE_SIZE); // Page bits
localparam TB = 32 - PB;           // Tag bits

integer i;

wire [TB-1:0] wr_ptag = wr_paddr[31-:TB];
wire [TB-1:0] wr_vtag = wr_vaddr[31-:TB];

wire [TB-1:0] vtag = vaddr[31-:TB];
wire [PB-1:0] voff = vaddr[31-TB:0];

reg [TB-1:0] vtags [0:DEPTH-1];
reg [TB-1:0] ptags [0:DEPTH-1];
reg [DEPTH-1:0] validbits = 0;

always @* if (read_enable & ~reset & ~hit) begin
	for (i = 0; i < DEPTH & ~hit; i = i+1) begin
		if (vtags[i] == vtag) begin
			paddr     <= {ptags[i],voff};
			index_out <= i;
			hit       <= 1;
			valid     <= validbits[i];
		end
	end
end else begin
	paddr     <= 0;
	index_out <= 0;
	hit       <= 0;
	valid     <= 0;
end

always @(posedge clk) begin
	if (reset) validbits = 0;
	else if (write_enable) begin
		vtags[index_in] <= wr_vtag;
		ptags[index_in] <= wr_ptag;
		validbits[index_in] <= 1;
		`INFO(("[%s] Fill %x <=> %x", ALIAS, wr_vtag, wr_ptag))
	end
end

endmodule

`endif
