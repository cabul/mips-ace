`ifndef _multiplexer
`define _multiplexer

///
/// multiplexer
///
/// cantdeclare2darrayasinput.png
///
module multiplexer(
	input wire [$clog2(X)-1:0] select,
	input wire [N*X-1:0] input_data,
	output reg [N-1:0] output_data);

parameter N = 32;
parameter X = 2;

always @* begin
	output_data <= input_data[(select+1)*N-1-:N];
end

endmodule

`endif
