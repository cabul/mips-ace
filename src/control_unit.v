`ifndef _control_unit
`define _control_unit

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
/// memread- Control signal memread
/// memwrite- Control signal memwrite
/// isbranch- Control signal isbranch
/// regdst- Control signal regdst
/// aluop- Control signal aluop
/// alusrc- Control signal alusrc
///
module control_unit(
	input wire [5:0] opcode,
	input wire [5:0] funct,
	output reg regwrite = 0,
	output reg memtoreg = 0,
	output reg memread = 0,
	output reg memwrite = 0,
	output reg isbranch = 0,
	output reg regdst = 0,
	output reg [1:0] aluop = 0,
	output reg alusrc = 0
	);

always @*begin
	if(opcode == 0) begin //R - Instruction Format
		case(funct)
			6'h20:	begin
				regwrite <= 1;
				memtoreg <= 0;
				memread <= 0;
				memwrite <= 0;
				isbranch <= 0;
				regdst <= 1;
				aluop <= 2'b10; //Look for this opcode
				alusrc <= 0;
				end
			6'h0: begin
				regwrite <= 0;
				regwrite <= 0;
				memtoreg <= 0;
				memread <= 0;
				memwrite <= 0;
				isbranch <= 0;
				regdst <= 0;
				aluop <= 2'b00; //Look for this opcode
				alusrc <= 0;
			end
			default:
				$display("Warning: Control Unit received unknown funct signal");
		endcase
	end
	else begin // I/J - Instruction Format
		case(opcode)
			//ADDI
			6'h8: begin
				regwrite <= 1;
				memtoreg <= 0;
				memread <= 0;
				memwrite <= 0;
				isbranch <= 0;
				regdst <= 0;
				aluop <= 2'b00; //Look for this opcode
				alusrc <= 1;
				end
			//LW
			6'h23:  begin
				regwrite <= 1;
				memtoreg <= 1;
				memread <= 1;
				memwrite <= 0;
				isbranch <= 0;
				regdst <= 0;
				aluop <= 2'b00; //Look for this opcode
				alusrc <= 1;
				end
			//SW
			6'h2b:	begin
				regwrite <= 0;
				memtoreg <= 0; //This one does not matter
				memread <= 0;
				memwrite <= 1;
				isbranch <= 0;
				regdst <= 0; //This one does not matter
				aluop <= 2'b00; //Look for this opcode
				alusrc <= 1;
				end
			//BEQ
			6'h4:	begin
				regwrite <= 0;
				memtoreg <= 0; //This one does not matter
				memread <= 0;  //This one does not matter
				memwrite <= 0;  //This one does not matter
				isbranch <= 1;
				regdst <= 0;  //This one does not matter
				aluop <= 2'b00; //Look for this opcode
				alusrc <= 0;
				end
			default:
				$display("Warning: Control Unit received unknown opcode signal");
		endcase


	end	
end

endmodule

`endif
