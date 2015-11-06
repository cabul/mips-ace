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
/// id_regwrite - Control signal regwrite
/// id_memtoreg - Control signal memtoreg
/// id_memread- Control signal memread
/// id_memwrite- Control signal memwrite
/// id_isbranch- Control signal isbranch
/// id_regdst- Control signal regdst
/// id_aluop- Control signal aluop
/// id_alusrc- Control signal alusrc
///
module control_unit(
	input wire [5:0] opcode,
	input wire [5:0] funct,
	output reg id_regwrite,
	output reg id_memtoreg,
	output reg id_memread,
	output reg id_memwrite,
	output reg id_isbranch,
	output reg id_regdst,
	output reg [1:0] id_aluop,
	output reg id_alusrc
	);

always @*begin
	if(opcode == 0) begin //R - Instruction Format
		case(funct)
			6'h20:	begin
				id_regwrite <= 1;
				id_memtoreg <= 0;
				id_memread <= 0;
				id_memwrite <= 0;
				id_isbranch <= 0;
				id_regdst <= 1;
				id_aluop <= 2'b00; //Look for this opcode
				id_alusrc <= 0;
				end
			default:
				$display("Warning: Control Unit received unknown opcode signal");
		endcase
	end
	else begin // I/J - Instruction Format
		case(opcode)
			//ADDI
			6'h8: begin
				id_regwrite <= 1;
				id_memtoreg <= 0;
				id_memread <= 0;
				id_memwrite <= 0;
				id_isbranch <= 0;
				id_regdst <= 0;
				id_aluop <= 2'b00; //Look for this opcode
				id_alusrc <= 1;
				end
			//LW
			6'h23:  begin
				id_regwrite <= 1;
				id_memtoreg <= 1;
				id_memread <= 1;
				id_memwrite <= 0;
				id_isbranch <= 0;
				id_regdst <= 0;
				id_aluop <= 2'b00; //Look for this opcode
				id_alusrc <= 1;
				end
			//SW
			6'h2b:	begin
				id_regwrite <= 0;
				id_memtoreg <= 0; //This one does not matter
				id_memread <= 0;
				id_memwrite <= 1;
				id_isbranch <= 0;
				id_regdst <= 0; //This one does not matter
				id_aluop <= 2'b00; //Look for this opcode
				id_alusrc <= 1;
				end
			//BEQ
			6'h4:	begin
				id_regwrite <= 0;
				id_memtoreg <= 0; //This one does not matter
				id_memread <= 0;  //This one does not matter
				id_memwrite <= 0;  //This one does not matter
				id_isbranch <= 1;
				id_regdst <= 0;  //This one does not matter
				id_aluop <= 2'b00; //Look for this opcode
				id_alusrc <= 0;
				end
			default:
				$display("Warning: Control Unit received unknown function signal");
		endcase


	end	
end

endmodule

`endif
