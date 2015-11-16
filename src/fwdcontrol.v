`ifndef _fwdcontrol
`define _fwdcontrol

module fwdcontrol(
	input wire [4:0] rs,
	input wire [4:0] rt,
	input wire [4:0] ex_dst,
	input wire [4:0] mem_dst,
   	input wire [4:0] wb_dst,
   	input wire ex_rw,
   	input wire mem_rw,
   	input wire wb_rw,
	output reg [1:0] ctrl_rs = 2'b0,
	output reg [1:0] ctrl_rt = 2'b0
);

// TODO logic could be optimized, but whocaresxddd

// 00 -> Regfile
// 01 -> Ex data
// 10 -> Mem data
// 11 -> Wb data

always @* begin
	// Default
    
	ctrl_rs = 2'b0;
	ctrl_rt = 2'b0;

	// WB hazards

	if (wb_rw && (wb_dst != 5'b0) && (wb_dst == rs)) 
		ctrl_rs = 2'b11;

	if (wb_rw && (wb_dst != 5'b0) && (wb_dst == rt))
		ctrl_rt = 2'b11;

	// MEM hazards

	if (mem_rw && (mem_dst != 5'b0) && (mem_dst == rs))
		ctrl_rs = 2'b10;

	if (mem_rw && (mem_dst != 5'b0) && (mem_dst == rt))
		ctrl_rt = 2'b10;

	// EX hazards
	if (ex_rw && (ex_dst != 5'b0) && (ex_dst == rs))
		ctrl_rs = 2'b01;

	if (ex_rw && (ex_dst != 5'b0) && (ex_dst == rt))
		ctrl_rt = 2'b01;

end

endmodule

`endif
