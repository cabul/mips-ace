`ifndef _alu
`define _datapath

/*
 * This unit is asinchronous
 *
 * alu_op: alu operation
 * in_s: input s
 * in_t: input t
 * shamt: shift amount (ignored unless shift op)
 * out: alu ouput
 */

module alu(
	input wire [5:0] alu_op,
	input wire [N-1:0] in_s,
	input wire [N-1:0] in_t,
    input wire [N-1:0] shamt,
	output reg [N-1:0] out = {N{1'b0}});

parameter N = 32;

always @* begin
    // TODO check for overflow, div by 0 and unsigned operations
    // TODO multiplications requiere two output channels (or a N*2 bus)
	case (alu_op)
	    6'b000000: out <= in_t << shamt;
		6'b000011: out <= in_t >> shamt;
		6'b100000: out <= in_s + in_t;
		6'b100010: out <= in_s - in_t;
		6'b100100: out <= in_s & in_t;
		6'b100101: out <= in_s | in_t;
		default: begin
		    $display("Warning: ALU received unknown alu_op signal.");
		    out <= N{1'b0};
		end
	endcase
end

endmodule

`endif