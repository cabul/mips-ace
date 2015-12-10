`ifndef _multiplexer
`define _multiplexer

module multiplexer(
	input wire [$clog2(X)-1:0] select,
	input wire [N*X-1:0] data_in,
	output reg [N-1:0] data_out
);

parameter N = 32;
parameter X = 2;

always @* begin
	data_out <= data_in[(select+1)*N-1-:N];
end

endmodule

`endif
