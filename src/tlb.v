`ifndef _tlb
`define _tlb

`include "defines.v"

module tlb (
	input wire clk,
	input wire reset,
	input wire read_enable,
	input wire write_enable,
	input wire [31:0] vaddr,
	output reg [31:0] paddr = 0,
	output reg hit = 0,
	input wire [31:0] wr_vaddr,
	input wire [31:0] wr_paddr
);

parameter DEPTH = `TLB_DEPTH;
parameter PAGE_SIZE = `PAGE_SIZE;
parameter ALIAS = "TLB";

localparam DB = $clog2(DEPTH);     // Depth bits
localparam PB = $clog2(PAGE_SIZE); // Page bits
localparam VB = 32 - DB - PB;      // Virtual tag bits
localparam TB = 32 - PB;           // Physical tag bits

wire [PB-1:0] offset = vaddr[PB-1:0];
wire [DB-1:0] index  = vaddr[PB+DB-1:PB];
wire [VB-1:0] vtag   = vaddr[31:PB+DB];

wire [DB-1:0] wr_index = wr_vaddr[PB+DB-1:PB];
wire [VB-1:0] wr_vtag  = wr_vaddr[31:PB+DB];
wire [TB-1:0] wr_ptag  = wr_paddr[31-:TB];

reg [VB-1:0]    vtags [0:DEPTH-1];
reg [TB-1:0]    ptags [0:DEPTH-1];
reg [DEPTH-1:0] validbits = 0;

wire [TB-1:0] ptag = ptags[index];
wire hit_int = (vtags[index] == vtag) & validbits[index];

always @* if (~read_enable | reset)
	hit <= 0;
else hit <= hit_int;

always @* if (hit)
	paddr <= { ptag, offset };
else paddr <= 0;

always @(posedge clk) begin
	if (reset) validbits = 0;
	else if (write_enable) begin
		vtags[wr_index] = wr_vtag;
		ptags[wr_index] = wr_ptag;
		validbits[wr_index] = 1;
		`INFO(("[%s] Insert %x = %x", ALIAS, wr_vaddr, wr_paddr))
	end
end

endmodule

`endif
