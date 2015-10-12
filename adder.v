`ifndef _adder
`define _adder

/*
 * ADDER info & pinout
 * -----------------
 *
 * This unit is asinchronous
 * 
 * in_s: input s
 * in_t: input t
 * out: adder ouput
 */

module adder(
	input wire [N-1:0] in_s,
	input wire [N-1:0] in_t,
	output reg [N-1:0] out = {N{1'b0}});

parameter N = 32;

always @* begin
	// TODO check for overflow?

	out <= in_s + in_t;
end

endmodule

`endif