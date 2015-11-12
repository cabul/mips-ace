`ifndef _memory
`define _memory

`include "defines.v"

`define MEMORY_LINE (WIDTH*8)-1:0
`define MEMORY_DB $clog2(DEPTH)
`define MEMORY_WB $clog2(WIDTH)

//TODO Update doc
module memory(
	input wire clk,
	input wire reset,
	input wire [31:0] addr,
	input wire [`MEMORY_LINE] wdata,
	input wire memwrite,
	input wire memread,
	output reg [`MEMORY_LINE] rdata = 0
);

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
// SIZE = DEPTH * WIDTH      //
//                           //
// DEPTH BITS = log2(DEPTH)  //
// WIDTH BITS = log2(WIDTH)  //
//                           //
// USED BITS = DB + WB       //
//                           //
///////////////////////////////

parameter WIDTH = 4;      // Bytes per line
parameter DEPTH = 'h1000; // Number of lines
parameter DATA  = "build/memory.hex"; // Careful with this

wire [`MEMORY_DB-1:0] index;
assign index = addr[`MEMORY_DB+`MEMORY_WB-1:`MEMORY_WB];

reg [`MEMORY_LINE] mem [0:DEPTH-1];

//TODO Address out of bounds
always @(posedge clk) begin
	if (reset) begin
		$readmemh(DATA, mem);
	end
	// Always operate on a memory line
	if (memread) 
		rdata <= mem[index][`MEMORY_LINE];
	if (memwrite)
		mem[index] <= wdata;
end

endmodule

`endif
