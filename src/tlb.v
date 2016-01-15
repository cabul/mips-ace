`ifndef _tlb
`define _tlb

`include "defines.v"

module tlb (
	input wire clk,
	input wire reset,

	input wire we,
	input wire [31:0] index,
	input wire [31:0] entrylo,
	input wire [31:0] entryhi,

	input wire en,
	input wire [31:0] vaddr,
	output reg [31:0] paddr,
	output reg hit,
	output reg valid
);

parameter ENTRIES = `TLB_ENTRIES;
parameter PAGE_SIZE = `PAGE_SIZE;
parameter ALIAS = "tlb";

localparam PB = $clog2(PAGE_SIZE); // Page bits
localparam TB = 32 - PB;           // Tag bits

integer i;

reg [31:0] entryhis [ENTRIES-1:0]; // vaddr
reg [31:0] entrylos [ENTRIES-1:0]; // paddr valdibit

always @* if (en & ~reset) begin
	hit = 0;
	for (i = 0; (i < ENTRIES) && ~hit; i = i+1) begin
		if (vaddr[31-:TB] == entryhis[i][31-:TB]) begin
			hit = 1;
			valid = entrylos[i][0];
			paddr = {entrylos[i][31-:TB], vaddr[PB-1:0]};
		end
	end
end else begin
	paddr     <= 0;
	hit       <= 0;
	valid     <= 0;
end

always @(posedge clk) begin
	if (reset) begin
		for (i = 0; i < ENTRIES; i = i+1) begin
			entryhis[i] <= 0;
			entrylos[i] <= 0;
		end
	end else if (we) begin
		entrylos[index] <= entrylo;
		entryhis[index] <= entryhi;
		`INFO(("[%s] Fill .%d %x <=> %x", ALIAS, index, entryhi, entrylo))
	end
end

endmodule

`endif
