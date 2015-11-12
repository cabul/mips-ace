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

`define MEMORY_LINE (2**(WIDTH+3)-1):0

//TODO Update doc
module memory(
	input wire clk,
	input wire reset,
	input wire [31:0] address,
	input wire [`MEMORY_LINE] wdata,
	input wire memwrite,
	input wire memread,
	output reg [`MEMORY_LINE] rdata = 0
);

parameter WIDTH = 4; // 2^WIDTH Bytes per line
//TODO Real depth
parameter DEPTH = 4; // 2^DEPTH Number of lines
parameter DATA  = "build/memory.dat"; // Careful with this

wire [DEPTH-1:0] index;
assign index = address[DEPTH+WIDTH-1:WIDTH];

reg [`MEMORY_LINE] mem [0:2**DEPTH-1];

`ifdef DEBUG_MEMORY
initial begin
	$display("[MEMORY] Load: %s", DATA);
	$display("[MEMORY] Width: %d Bytes", 2**WIDTH);
	$display("[MEMORY] Depth: %d Lines", 2**DEPTH);
	$display("[MEMORY] Size: %d Bytes", 2**(WIDTH+DEPTH));
end
`endif

//TODO Address out of bounds
// Always operate on a memory line
always @(posedge clk) begin
	if (reset) $readmemh(DATA, mem);
	else if (memread) begin
		rdata <= mem[index];
		`ifdef DEBUG_MEMORY
		$display("[MEMORY] Read  @%x => %x", address, mem[index]);
		`endif
	end else if (memwrite) begin
		mem[index] <= wdata;
		`ifdef DEBUG_MEMORY
		$display("[MEMORY] Write @%x <= %x", address, wdata);
		`endif
	end
end

endmodule

`endif
