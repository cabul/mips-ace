`ifndef _memory
`define _memory

`include "defines.v"

///////////////////////////////
//                           //
//           WIDTH           //
//        +---------->       //
//        | ........         //
//        | ........         //
//  DEPTH | ........         //
//        | ........         //
//        | ........         //
//        v                  //
//                           //
///////////////////////////////

module memory(
	input wire clk,
	input wire reset,
	input wire [ADDR-1:0] addr,
	input wire [WIDTH-1:0] wdata,
	input wire memwrite,
	input wire memread,
	output reg [WIDTH-1:0] rdata = {WIDTH{1'b0}}
);

parameter WIDTH = 128;
parameter DEPTH = 4; 
parameter ADDR = 32;
localparam WB = $clog2(WIDTH) - 3; // Width bits (address is in bytes)
localparam DB = $clog2(DEPTH); // Depth bits

// This parameter is the name of the hexfile that is loaded on startup.
// You usually do not! need to change this parameter manually, since
// the file is generated from the program passed to ace.
parameter DATA  = "build/memory.dat";

// Unrolling for debug port
`ifdef DEBUG_MEMORY
wire [WIDTH*DEPTH-1:0] dbg_mem;
genvar j;
generate
for (j = 0; j < DEPTH; j = j + 1) begin
	assign dbg_mem[WIDTH*j+WIDTH-1:WIDTH*j] = mem[DEPTH-1-j];
end
endgenerate

initial begin
	$display("[MEMORY] Size: %d bytes", WIDTH * DEPTH / 8);
	$display("[MEMORY] Width: %d bits", WIDTH);
	$display("[MEMORY] Depth: %d lines", DEPTH);
	$display("[MEMORY] Address: %d bits", ADDR);
end
`endif

wire [DB-1:0] index;
assign index = addr[DB+WB-1:WB]; // Get whole line

reg [WIDTH-1:0] mem [0:DEPTH-1];

//TODO Add delay/latency
always @* begin
	if (memread && !reset) begin
		`ifdef DEBUG // lw $X, 0xffffffff == exit
		if (& addr) # 20 $finish; else // Wait 2 cycles
		`endif
		rdata <= mem[index];
	end
end

always @(posedge clk) begin
	if (reset) $readmemh(DATA, mem);
	else if (memwrite) begin
		`ifdef DEBUG // sw $X, 0xffffffff == print $X
		if (& addr) $display("[DEBUG] %8x", wdata); else
		if (& addr -1) $write("%c", wdata); else
		`endif
		mem[index] <= wdata;
	end
end

endmodule

`endif
