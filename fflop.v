`ifndef _fflop
`define _fflop

module fflop(
	input clk,
	input clear,
	input we,
	input wire [N-1:0] in,
	output reg [N-1:0] out = {N{1'b0}});

parameter N = 1;

always @(posedge clk) begin
	if (clear)
		out <= {N{1'b0}};
	else if (we)
		out <= in;
	else
		out <= out;
end

endmodule

`endif
