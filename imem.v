`ifndef _imem
`define _imem

module imem(
	input wire clk,
	input wire [31:0] addr,
	output reg [31:0] instr);

endmodule

`endif
