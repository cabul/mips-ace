`ifndef _fwdcontrol
`define _fwdcontrol

module fwdcontrol(
	input wire [4:0] rs,
	input wire [4:0] rt,
	input wire [4:0] mem_dst,
   	input wire [4:0] wb_dst,
   	input wire mem_rw,
   	input wire wb_rw,
	output reg [1:0] ctrl_s = 2'b0,
	output reg [1:0] ctrl_t = 2'b0
);

// TODO logic could be optimized, but whocaresxddd

always @* begin
	// Default
    
	ctrl_s = 2'b0;
	ctrl_t = 2'b0;

	// EX hazards

	if ((mem_rw == 1'b1) && (mem_dst != 5'b0) && (mem_dst == rs))
		ctrl_s = 2'b10;

	if ((mem_rw == 1'b1) && (mem_dst != 5'b0) && (mem_dst == rt))
		ctrl_t = 2'b10;

	// MEM hazards

	if ((wb_rw == 1'b1) && (wb_dst != 5'b0) && (wb_dst == rs) && 
			!((mem_rw == 1'b1) && (mem_dst != 5'b0) && (mem_dst == rs)))
		ctrl_s = 2'b01;

	if ((wb_rw == 1'b1) && (wb_dst != 5'b0) && (wb_dst == rt) &&
			!((mem_rw == 1'b1) && (mem_dst != 5'b0) && (mem_dst == rt)))
		ctrl_t = 2'b01;
end

endmodule

`endif
