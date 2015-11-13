`ifndef _alucontrol
`define _alucontrol

`include "defines.v"

module alucontrol(
	input wire [5:0] func,
	input wire [1:0] aluop_in,
	output reg [3:0] aluop_out
);

always @* begin
	case (aluop_in)
		2'b00: aluop_out <= `ALUOP_ADD;
		2'b01: aluop_out <= `ALUOP_SUB;
		2'b10:
            case (func)
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
                default:
                    $display("Warning: ALUcontrol received unknown func signal.");
            endcase
		default:
			$display("Warning: ALUcontrol received unknown op_in signal.");
	endcase
end

endmodule

`endif
