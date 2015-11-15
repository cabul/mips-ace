`ifndef _control
`define _control

`include "defines.v"

///
/// control_unit
///
/// This unit is asynchronus
///
/// Ports:
/// opcode - Instruction opcode
/// funct - Instruction function code
/// regwrite - Control signal regwrite
/// memtoreg - Control signal memtoreg
/// memread - Control signal memread
/// memwrite- Control signal memwrite
/// isbranch - Control signal isbranch
/// regdst - Control signal regdst
/// aluop - Control signal aluop
/// alusrc - Control signal alusrc
/// isjump - Control signal isjump
///
module control(
	input wire [5:0] opcode,
	input wire [5:0] funct,
	output reg regwrite = 0,
	output reg memtoreg = 0,
	output reg memread = 0,
	output reg memwrite = 0,
	output reg isbranch = 0,
	output reg regdst = 0,
	output reg [3:0] aluop = 0,
	output reg alusrc = 0,
	output reg isjump = 0
);

always @* begin
	case(opcode)
		`OP_RTYPE: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst <= 1;
			aluop <= 4'h0;
			alusrc <= 0;
			isjump <= 0;
			end
		`OP_ADDI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst <= 0;
			aluop <= 4'h1;
			alusrc <= 1;
			isjump <= 0;
			end
		`OP_LW: begin
			regwrite <= 1;
			memtoreg <= 1;
			memread <= 1;
			memwrite <= 0;
			isbranch <= 0;
			regdst <= 0;
			aluop <= 4'h1;
			alusrc <= 1;
			isjump <= 0;
			end
		`OP_SW:	begin
			regwrite <= 0;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 1;
			isbranch <= 0;
			regdst <= 0;
			aluop <= 4'h1;
			alusrc <= 1;
			isjump <= 0;
			end
		`OP_J: begin
			regwrite <= 0;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst <= 0;
			aluop <= 4'h1;
			alusrc <= 0;
			isjump <= 1;
			end
		`OP_ANDI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst <= 0;
			aluop <= 4'h2;
			alusrc <= 1;
			isjump <= 0;
			end
		`OP_ORI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst <= 0;
			aluop <= 4'h3;
			alusrc <= 1;
			isjump <= 0;
			end
		`OP_XORI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst <= 0;
			aluop <= 4'h4;
			alusrc <= 1;
			isjump <= 0;
			end
		`OP_SLTI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst <= 0;
			aluop <= 4'h5;
			alusrc <= 1;
			isjump <= 0;
			end
		`OP_BEQ: begin
			regwrite <= 0;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 0;
			isbranch <= 1;
			regdst <= 0;
			aluop <= 4'h6;
			alusrc <= 0;
			isjump <= 0;
			end
		`OP_BNE: begin
			regwrite <= 0;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 0;
			isbranch <= 1;
			regdst <= 0;
			aluop <= 4'h7;
			alusrc <= 0;
			isjump <= 0;
			end
		`OP_LUI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst <= 0;
			aluop <= 4'h8;
			alusrc <= 1;
			isjump <= 0;
			end
		default:
			$display("[WARNING] Control Unit received unknown opcode signal %x", opcode);
	endcase
end

endmodule

`endif
