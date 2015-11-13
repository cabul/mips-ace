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
	output reg [1:0] aluop = 0,
	output reg alusrc = 0,
	output reg isjump = 0
	);

always @* begin
	case(opcode)
		6'h0: begin //R - Instruction Format
			regwrite <= 1;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst <= 1;
			aluop <= 2'b10;
			alusrc <= 0;
			isjump <= 0;
			end
		`OP_ADDI: begin // I/J - Instruction Format
			regwrite <= 1;
			memtoreg <= 0;
			memread <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst <= 0;
			aluop <= 2'b00;
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
			aluop <= 2'b00;
			alusrc <= 1;
			isjump <= 0;
			end
		`OP_SW:	begin
			regwrite <= 0;
			memtoreg <= 0; //This one does not matter
			memread <= 0;
			memwrite <= 1;
			isbranch <= 0;
			regdst <= 0; //This one does not matter
			aluop <= 2'b00;
			alusrc <= 1;
			isjump <= 0;
			end
		`OP_BEQ: begin
			regwrite <= 0;
			memtoreg <= 0; //This one does not matter
			memread <= 0;  //This one does not matter
			memwrite <= 0;  //This one does not matter
			isbranch <= 1;
			regdst <= 0;  //This one does not matter
			aluop <= 2'b00;
			alusrc <= 0;
			isjump <= 0;
			end
		`OP_J: begin
			regwrite <= 0;
			memtoreg <= 0; //This one does not matter
			memread <= 0;  //This one does not matter
			memwrite <= 0;  //This one does not matter
			isbranch <= 0;
			regdst <= 0;  //This one does not matter
			aluop <= 2'b00;
			alusrc <= 0;
			isjump <= 1;
			end
		default:
			$display("[WARNING] Control Unit received unknown opcode signal %x", opcode);
	endcase
end

endmodule

`endif
