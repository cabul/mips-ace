`ifndef _alu
`define _alu

/*
 * ALU info & pinout
 * -----------------
 *
 * This unit is asynchronous
 * 
 * alu_op: alu operation
 * in_s: input s
 * in_t: input t
 * shamt: shift amount (ignored unless shift op)
 * zero: if division by 0 (TODO check this and any other output needed)
 * out: alu ouput
 */

module alu(
	input wire [5:0] alu_op,
	input wire [N-1:0] in_s,
	input wire [N-1:0] in_t,
	input wire [4:0] shamt,
	output reg zero = 1'd0,
	output reg [N-1:0] out = {N{1'b0}});

parameter N = 32;

always @* begin
	// TODO check for overflow, div by 0
	// TODO implement unsigned operations
	// TODO multiplications write to a special register LO and HI
	// TODO multiplications and data hazards?
	case (alu_op)
		6'b000000: out <= in_t << shamt;
		6'b000010: out <= in_t >> shamt;
		6'b000011: out <= in_t >>> shamt; // TODO check operator
		6'b100000: out <= in_s + in_t;
		6'b100010: out <= in_s - in_t;
		6'b100100: out <= in_s & in_t;
		6'b100101: out <= in_s | in_t;
		6'b100110: out <= in_s ^ in_t;
		default: begin
			$display("Warning: ALU received unknown alu_op signal.");
			out <= {N{1'b0}};
		end
	endcase
end

endmodule

`endif