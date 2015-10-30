`ifndef _alucontrol
`define _alucontrol

`include "defines.v"

module alucontrol(
	input wire [5:0] func,
	input wire [1:0] alu_op_in,
	output reg [3:0] alu_op_out
);

always @* begin
	case (alu_op_in)
		2'b00: alu_op_out <= OP_ADD;
		2'b01: alu_op_out <= OP_SUB;
		2'b10:
            case (func)
                FN_SLL: alu_op_out <= OP_SLL;
                FN_SRL: alu_op_out <= OP_SRL;
                FN_SRA: alu_op_out <= OP_SRA;
                FN_ADD: alu_op_out <= OP_ADD;
                FN_SUB: alu_op_out <= OP_SUB;
                FN_AND: alu_op_out <= OP_AND;
                FN_OR:  alu_op_out <= OP_OR;
                FN_XOR: alu_op_out <= OP_XOR;
                FN_NOR: alu_op_out <= OP_NOR;
                FN_SLT: alu_op_out <= OP_SLT;
                default:
                    $display("Warning: ALUcontrol received unknown func signal.");
            endcase
		default:
			$display("Warning: ALUcontrol received unknown op_in signal.");
	endcase
end

endmodule

`endif
