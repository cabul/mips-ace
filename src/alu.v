`ifndef _alu
`define _alu

`include aludefines.v

///
/// Algorithmetic Logic Unit
/// 
/// This unit is asynchronous
/// 
/// Ports:
///
/// alu_op - alu operation
/// s - input s
/// t - input t
/// shamt - shift amount, ignored unless shift operation
/// zero - if division by 0
/// overflow - if overflow
/// out - alu ouput
/// 
module alu(
	input wire [3:0] alu_op,
	input wire [N-1:0] s,
	input wire [N-1:0] t,
	input wire [4:0] shamt,
	output reg zero = 1'd0,
    output reg overflow = 1'd0,
	output reg [N-1:0] out = {N{1'b0}});

parameter N = 32;

always @* begin
	case (alu_op)
        OP_SLL: out <= t << shamt;
        OP_SRL: out <= t >> shamt;
        OP_SRA: out <= t >>> shamt;
        OP_ADD: out <= s + t;
        OP_SUB: out <= s - t;
        OP_AND: out <= s & t;
        OP_OR:  out <= s | t;
        OP_XOR: out <= s ^ t;
        OP_NOR: out <= ~(s | t);
        OP_SLT: out <= (s < t)? 32'd1 : 32'd0;
		default:
			$display("Warning: ALU received unknown alu_op signal.");
	endcase
    
    zero     <= (out == 32'd0) 1'b1 : 1'b0;
    overflow <= 1'b0; // TODO fix overflow formula
end

endmodule

`endif
