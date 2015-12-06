`ifndef _control
`define _control

`include "defines.v"

module control(
	input wire [5:0] opcode,
	input wire [5:0] funct,
	input wire cpu_mode,
	output reg regwrite = 0,
	output reg memtoreg = 0,
	output reg memread = 0,
	output reg memwrite = 0,
	output reg isbranch = 0,
	output reg isjump = 0,
	output reg jumpdst = 0,
	output reg islink = 0,
	output reg regdst = 0,
	output reg aluop = 0,
	output reg alu_s = 0,
	output reg alu_t = 0,
	output reg exc_ri = 0,
	output reg exc_sys = 0,
	output reg cowrite = 0,
	output reg exc_ret = 0
);

always @* begin
	casez(opcode)
		`OP_RTYPE: begin
			case(funct)
				`FN_JR: begin
					regwrite <= 0;
					memtoreg <= 0;
					memread  <= 0;
					memwrite <= 0;
					isbranch <= 0;
					regdst   <= 0;
					alu_s    <= 0;
					alu_t    <= 0;
					aluop    <= 0;
					isjump   <= 1;
					jumpdst  <= 1;
					islink   <= 0;
					exc_ri   <= 0;
					exc_sys  <= 0;
					cowrite  <= 0;
					exc_ret  <= 0;
				end
				`FN_SYS: begin
					regwrite <= 0;
					memtoreg <= 0;
					memread  <= 0;
					memwrite <= 0;
					isbranch <= 0;
					regdst   <= 0;
					alu_s    <= 0;
					alu_t    <= 0;
					aluop    <= 0;
					isjump   <= 0;
					jumpdst  <= 0;
					islink   <= 0;
					exc_ri   <= 0;
					exc_sys  <= 1;
					cowrite  <= 0;
					exc_ret  <= 0;
				end
				default: begin
					regwrite <= 1;
					memtoreg <= 0;
					memread  <= 0;
					memwrite <= 0;
					isbranch <= 0;
					regdst   <= 1;
					alu_s    <= 0;
					alu_t    <= 0;
					aluop    <= 0;
					isjump   <= 0;
					jumpdst  <= 0;
					islink   <= 0;
					exc_ri   <= 0;
					exc_sys  <= 0;
					cowrite  <= 0;
					exc_ret  <= 0;
				end
			endcase
		end
		`OP_ADDI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 1;
			aluop    <= 1;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			exc_ri   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			exc_ret  <= 0;
		end
		`OP_LW: begin
			regwrite <= 1;
			memtoreg <= 1;
			memread  <= 1;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 1;
			aluop    <= 1;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			exc_ri   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			exc_ret  <= 0;
		end
		`OP_SW:	begin
			regwrite <= 0;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 1;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 1;
			aluop    <= 1;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			exc_ri   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			exc_ret  <= 0;
		end
		`OP_J: begin
			regwrite <= 0;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 0;
			aluop    <= 1;
			isjump   <= 1;
			jumpdst  <= 0;
			islink   <= 0;
			exc_ri   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			exc_ret  <= 0;
		end
		`OP_ANDI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 1;
            aluop    <= 1;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			exc_ri   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			exc_ret  <= 0;
		end
		`OP_ORI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 1;
			aluop    <= 1;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			exc_ri   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			exc_ret  <= 0;
		end
		`OP_XORI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 1;
			aluop    <= 1;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			exc_ri   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			exc_ret  <= 0;
		end
		`OP_SLTI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 1;
			aluop    <= 1;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			exc_ri   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			exc_ret  <= 0;
		end
		`OP_BEQ: begin
			regwrite <= 0;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 1;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 0;
			aluop    <= 1;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			exc_ri   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			exc_ret  <= 0;
		end
		`OP_BNE: begin
			regwrite <= 0;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 1;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 0;
			aluop    <= 1;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			exc_ri   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			exc_ret  <= 0;
		end
		`OP_LUI: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 1;
			aluop    <= 1;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			exc_ri   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			exc_ret  <= 0;
		end
		`OP_JAL: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 0;
			aluop    <= 1;
			isjump   <= 1;
			jumpdst  <= 0;
			islink   <= 1;
			exc_ri   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			exc_ret  <= 0;
		end
		`OP_MFC0: begin
			regwrite <= 1;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 1;
			alu_t    <= 0;
			aluop    <= 1;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			cowrite  <= 0;
			exc_sys  <= 0;
			exc_ret  <= 0;
			if(cpu_mode == 1) begin		
				exc_ri   <= 0;				
			end else begin
				exc_ri   <= 1;
			end
		end
		`OP_MTC0: begin
			regwrite <= 0;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 0;
			aluop    <= 1;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			exc_sys  <= 0;
			exc_ret  <= 0;	
			if(cpu_mode == 1) begin		
				exc_ri   <= 0;
				cowrite  <= 1;				
			end else begin
				exc_ri   <= 1;
				cowrite  <= 0;
			end end
		`OP_ERET: begin
			regwrite <= 0;
			memtoreg <= 0;
			memread  <= 0;
			memwrite <= 0;
			isbranch <= 0;
			regdst   <= 0;
			alu_s    <= 0;
			alu_t    <= 0;
			aluop    <= 0;
			isjump   <= 0;
			jumpdst  <= 0;
			islink   <= 0;
			exc_sys  <= 0;
			cowrite  <= 0;
			if(cpu_mode == 1) begin	
				exc_ri   <= 0;
				exc_ret  <= 1;
				//cambiar el PC con el contenido de EPC
			end else begin
				exc_ri   <= 1;
				exc_ret  <= 0;
			end end
				
		default:
			$display("%5t # [WARNING] Control Unit received unknown opcode signal %x", $time, opcode);
	endcase
end

endmodule

`endif
