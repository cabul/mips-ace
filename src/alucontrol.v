`ifndef _alucontrol
`define _alucontrol

`include "defines.v"

module alucontrol(
	input wire [5:0] funct,
	input wire [5:0] opcode,
	input wire aluop_in,
	output reg [4:0] aluop_out = 0
);

always @* begin
	if (aluop_in) begin
		casex (opcode)
			`OP_ADDI: aluop_out <= `ALUOP_ADD;
			`OP_ANDI: aluop_out <= `ALUOP_AND;
			`OP_ORI:  aluop_out <= `ALUOP_OR;
			`OP_XORI: aluop_out <= `ALUOP_XOR;
			`OP_SLTI: aluop_out <= `ALUOP_SLT;
			`OP_BNE:  aluop_out <= `ALUOP_BNE;
			`OP_BEQ:  aluop_out <= `ALUOP_BEQ;
			`OP_LB:   aluop_out <= `ALUOP_ADD;
			`OP_LW:   aluop_out <= `ALUOP_ADD;
			`OP_SB:   aluop_out <= `ALUOP_ADD;
			`OP_SW:   aluop_out <= `ALUOP_ADD;
			`OP_LUI:  aluop_out <= `ALUOP_LUI;
			`OP_MFC0: aluop_out <= `ALUOP_MOV;
			`OP_MTC0: aluop_out <= `ALUOP_MOV;
			`OP_J:    aluop_out <= aluop_out;
			`OP_JAL:  aluop_out <= aluop_out;
			`OP_ERET: aluop_out <= aluop_out;
			`OP_RTYPE:
				`WARN(("ALU Control: Unexpected OP_RTYPE"))
			default:
				`WARN(("ALU Control: Unknown opcode signal %x", opcode))
		endcase
	end else begin
		casex (funct)
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
			`FN_JR:  aluop_out <= aluop_out;
			`FN_SYS: aluop_out <= aluop_out;
			default:
				`WARN(("ALU Control: Unknown funct signal %x", funct))
		endcase
	end
end

endmodule

`endif
