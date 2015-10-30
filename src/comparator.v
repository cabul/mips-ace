`ifndef _comparator
`define _comparator

//
// Comparator
// 
// This unit is asynchronous
// 
// Ports:
// in_a - port a to compare
// in_b - port b to compare
// equal - if in_a equals in_b
// 
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
