`ifndef _control
`define _control

`include "defines.v"

module control(
	input wire [5:0] opcode,
	input wire [5:0] funct,
	output reg regwrite = 0,
	output reg memtoreg = 0,
	output reg memread = 0,
	output reg memwrite = 0,
	output reg isbranch = 0,
	output reg regdst = 0,
	output reg aluop = 0,
	output reg alusrc = 0,
	output reg isjump = 0
);

always @* begin
	case(opcode)
		`OP_RTYPE: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 1;
			alusrc   <= 0;
			aluop    <= 0;
			isjump   <= 0;
		end
		`OP_ADDI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alusrc   <= 1;
			aluop    <= 1;
			isjump   <= 0;
		end
		`OP_LW: begin
			regwrite <= 1;
			memtoreg <= 1;
			memread  <= 1;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alusrc   <= 1;
			aluop    <= 1;
			isjump   <= 0;
		end
		`OP_SW:	begin
			regwrite <= 0;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 1;
			isbranch <= 0;
			regdst   <= 0;
			alusrc   <= 1;
			aluop    <= 1;
			isjump   <= 0;
		end
		`OP_J: begin
			regwrite <= 0;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alusrc   <= 0;
			aluop    <= 1;
			isjump   <= 1;
		end
		`OP_ANDI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alusrc   <= 1;
            aluop    <= 1;
			isjump   <= 0;
		end
		`OP_ORI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alusrc   <= 1;
			aluop    <= 1;
			isjump   <= 0;
		end
		`OP_XORI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alusrc   <= 1;
			aluop    <= 1;
			isjump   <= 0;
		end
		`OP_SLTI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alusrc   <= 1;
			aluop    <= 1;
			isjump   <= 0;
		end
		`OP_BEQ: begin
			regwrite <= 0;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 1;
			regdst   <= 0;
			alusrc   <= 0;
			aluop    <= 1;
			isjump   <= 0;
		end
		`OP_BNE: begin
			regwrite <= 0;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 1;
			regdst   <= 0;
			alusrc   <= 0;
			aluop    <= 1;
			isjump   <= 0;
		end
		`OP_LUI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alusrc   <= 1;
			aluop    <= 1;
			isjump   <= 0;
		end
		default:
			$display("[WARNING] Control Unit received unknown opcode signal %x", opcode);
	endcase
end

endmodule

`endif
