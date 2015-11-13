`ifndef _alu
`define _alu

`include "defines.v"

//
// Algorithmetic Logic Unit
// 
// This unit is asynchronous
// 
// Ports:
//
// alu_op - alu operation
// s - input s
// t - input t
// shamt - shift amount, ignored unless shift operation
// zero - if division by 0
// overflow - if overflow
// out - alu ouput
// 
module alu(
	input wire [3:0] aluop,
	input wire [N-1:0] s,
	input wire [N-1:0] t,
	input wire [4:0] shamt,
	output reg zero = 1'd0,
    output reg overflow = 1'd0,
	output reg [N-1:0] out = {N{1'b0}}
);

parameter N = 32;

always @* begin
	case (aluop)
        `ALUOP_SLL: out <= t << shamt;
        `ALUOP_SRL: out <= t >> shamt;
        `ALUOP_SRA: out <= t >>> shamt;
        `ALUOP_ADD: out <= s + t;
        `ALUOP_SUB: out <= s - t;
        `ALUOP_AND: out <= s & t;
        `ALUOP_OR:  out <= s | t;
        `ALUOP_XOR: out <= s ^ t;
        `ALUOP_NOR: out <= ~(s | t);
        `ALUOP_SLT: out <= (s < t)? 32'd1 : 32'd0;
		default:
			$display("%4t Warning: ALU received unknown alu_op signal: %x", $time, aluop);
	endcase
    
    zero     <= (out == 32'd0) ? 1'b1 : 1'b0;
    overflow <= 1'b0; // TODO fix overflow formula
end

endmodule

`endif
