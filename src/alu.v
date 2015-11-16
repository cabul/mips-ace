`ifndef _alu
`define _alu

`include "defines.v"

module alu(
	input wire [3:0] aluop,
	input wire [N-1:0] s,
	input wire [N-1:0] t,
	input wire [4:0] shamt,
	output reg zero = 1'd0,
    output reg overflow = 1'd0,
	output reg [N-1:0] out = {N{1'b0}}
);

parameter N = 32;
reg [63:0] tmp = 0;

always @* begin
	case (aluop)
        `ALUOP_SLL: begin
			zero <= 0;
			overflow <= 0;
			out <= t << shamt;
		end
        `ALUOP_SRL: begin
			zero <= 0;
			overflow <= 0;
			out <= t >> shamt;
		end
        `ALUOP_SRA: begin
			zero <= 0;
			overflow <= 0;
			out <= t >>> shamt;
		end
        `ALUOP_ADD: begin
			zero <= 0;
			out <= s + t;
			if((s[31] == t[31]) && (out[31] != s[31])) overflow <= 1;
			else overflow <= 0;
		end
        `ALUOP_SUB: begin
			zero <= 0;
			out <= s - t;
			if((s[31] != t[31]) && (out[31] != s[31])) overflow <= 1;
			else overflow <= 0;
		end	
        `ALUOP_AND: begin
			zero <= 0;
			overflow <= 0;
			out <= s & t;
		end
        `ALUOP_OR:  begin
			zero <= 0;
			overflow <= 0;
			out <= s | t;
		end
        `ALUOP_XOR: begin
			zero <= 0;
			overflow <= 0;
			out <= s ^ t;
		end
        `ALUOP_NOR: begin
			zero <= 0;
			overflow <= 0;
			out <= ~(s | t);
		end
        `ALUOP_SLT: begin
			zero <= 0;
			overflow <= 0;
			out <= (s < t)? 32'd1 : 32'd0;
		end
		`ALUOP_BEQ: begin
			overflow <= 0;
			out <= 32'd0;
			if((s - t) == 0) zero <= 1;
			else zero <= 0;		
		end
		`ALUOP_BNE: begin
			out <= 32'd0;
			overflow <= 0;
			if((s - t) == 0) zero <= 0;
			else zero <= 1;
		end
		`ALUOP_LUI: begin
			zero <= 0;
			overflow <= 0;
			out <= {t[15:0], 16'h0000};
		end
		`ALUOP_MUL: begin
			zero <= 0;
			tmp <= s * t;
			out <= tmp[31:0];
			if({32{out[31]}} != tmp[63:32]) overflow <= 1;
			else overflow <= 0;
		end
		`ALUOP_DIV: begin
			zero <= 0;
			if(t == 0)  begin 
				overflow <= 1;
				out <= 32'd0;
			end	else begin
				tmp <= s / t;
				out <= tmp[31:0];
				overflow <= 0;
			end
		end
		default:
			$display("[WARNING] ALU received unknown aluop signal %x", aluop);
	endcase
end

endmodule

`endif
