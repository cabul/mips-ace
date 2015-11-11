`include "control_unit.v"

module control_unit_tb;

reg [5:0] funct = 6'h20, opcode= 0;
wire id_regwrite, id_memtoreg, id_memread, id_memwrite, id_isbranch, id_regdst, id_alusrc;
wire [1:0] id_aluop;


control_unit control(.funct(funct), .opcode(opcode), .id_regwrite(id_regwrite), .id_memtoreg(id_memtoreg), .id_memread(id_memread), .id_memwrite(id_memwrite), .id_isbranch(id_isbranch), .id_regdst(id_regdst), .id_aluop(id_aluop), .id_alusrc( id_alusrc));

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFULE);
	$dumpvars(0, control_unit_tb);
	`endif

	$monitor("funct= %h, opcode = %h \nregwrite = %b, memtoreg = %b, memread= %b, memwrite= %b, isbranch= %b, regdst= %b, aluop= %b, alusrc= %b", funct, opcode, control.id_regwrite, control.id_memtoreg, control.id_memread, control.id_memwrite,  control.id_isbranch, control.id_regdst  , control.id_aluop , control.id_alusrc);
end

endmodule
