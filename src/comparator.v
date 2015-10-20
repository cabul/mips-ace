`ifndef _comparator
`define _comparator

///
/// Signextender
/// 
/// This unit is asynchronous
/// 
/// Ports:
/// extend - input register to be sign-extended
/// extended - output sign-extended register
/// 
module comparator(
	input wire [N-1:0] in_a,
	input wire [N-1:0] in_b,
	output reg equal);

parameter N = 32;

always @* begin
	equal <= (in_a == in_b);
end

endmodule

`endif
