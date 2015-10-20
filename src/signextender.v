`ifndef _signextender
`define _signextender

/*
 * SIGNEXTENDER info & pinout
 * -----------------
 *
 * This unit is asynchronous
 * 
 * extend: input register to be sign-extended
 * extended: output sign-extended register
 */

module signextender(
		input wire [15:0] extend,
		output reg [31:0] extended);

always @* begin
 		extended[31:0] <= { {16{extend[15]}}, extend[15:0] };
end
endmodule
`endif
