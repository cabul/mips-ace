`ifndef _alucontrol
`define _alucontrol

`include "defines.v"

module alucontrol(
	input wire [5:0] funct,
	input wire [3:0] aluop_in,
	output reg [3:0] aluop_out = 0
);

always @* begin
	case (aluop_in)
		4'h1: aluop_out <= `ALUOP_ADD;
		4'h2: aluop_out <= `ALUOP_AND;
		4'h3: aluop_out <= `ALUOP_OR;
		4'h4: aluop_out <= `ALUOP_XOR;
		4'h5: aluop_out <= `ALUOP_SLT;
		4'h6: aluop_out <= `ALUOP_BEQ;
		4'h7: aluop_out <= `ALUOP_BNE;
		4'h8: aluop_out <= `ALUOP_LUI;
		4'h0: 
            case (funct)
                `FN_SLL: aluop_out <= `ALUOP_SLL;
                `FN_SRL: aluop_out <= `ALUOP_SRL;
                `FN_SRA: aluop_out <= `ALUOP_SRA;
                `FN_ADD: aluop_out <= `ALUOP_ADD;
                `FN_SUB: aluop_out <= `ALUOP_SUB;
                `FN_AND: aluop_out <= `ALUOP_AND;
                `FN_OR:  aluop_out <= `ALUOP_OR;
                `FN_XOR: aluop_out <= `ALUOP_XOR;
                `FN_NOR: aluop_out <= `ALUOP_NOR;
                `FN_SLT: aluop_out <= `ALUOP_SLT;
				`FN_MUL: aluop_out <= `ALUOP_MUL;
				`FN_DIV: aluop_out <= `ALUOP_DIV;
                default:
                    $display("[WARNING] ALU Control received unknown funct signal %x", funct);
            endcase
		default:
			$display("[WARNING] ALU Control received unknown aluop signal %x", aluop_in);
	endcase
end

endmodule

`endif
