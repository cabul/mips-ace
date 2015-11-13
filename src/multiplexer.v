`ifndef _multiplexer
`define _multiplexer

module multiplexer(
	input wire [$clog2(X)-1:0] select,
	input wire [N*X-1:0] in_data,
	output reg [N-1:0] out_data
);

parameter N = 32;
parameter X = 2;

always @* begin
	out_data <= in_data[(select+1)*N-1-:N];
end

endmodule

`endif
