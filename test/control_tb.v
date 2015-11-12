`include "control.v"

module control_tb;

reg [5:0] funct = 6'h20, opcode= 0;
wire regwrite, memtoreg, memread, memwrite, isbranch, regdst, alusrc, isjump;
wire [1:0] aluop;


control control(
	.funct(funct),
	.opcode(opcode),
	.regwrite(regwrite),
	.memtoreg(memtoreg),
	.memread(memread),
	.memwrite(memwrite),
	.isbranch(isbranch),
	.isjump(isjump),
	.regdst(regdst),
	.aluop(aluop),
	.alusrc(alusrc)
);

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFULE);
	$dumpvars(0, control_unit_tb);
	`endif

	$monitor("funct= %h, opcode = %h \nregwrite = %b, memtoreg = %b, memread= %b, memwrite= %b, isbranch= %b, isjump= %b, regdst= %b, aluop= %b, alusrc= %b", funct, opcode, regwrite, memtoreg, memread, memwrite, isbranch, isjump, regdst , aluop , alusrc);
end

endmodule
