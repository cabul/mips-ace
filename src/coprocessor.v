`ifndef _coprocessor
`define _coprocessor

`include "defines.v"

// Coprocessor 0
// http://en.wikichip.org/wiki/mips/coprocessor_0
// mfc0 rs,rd and mtc0 rd,rs

module coprocessor(
	input wire clk,
	input wire reset,
	input wire enable,

	input wire [4:0] rreg,
	input wire [4:0] wreg,
	input wire [31:0] wdata,
	output reg [31:0] rdata = 32'd0,

	input wire int_ext,
	input wire int_tr,
	input wire int_ovf,
	input wire int_ri,
	input wire int_sys,
	input wire int_addrs,
	input wire int_addrl,

	input wire [31:0] epc_in,
	input wire [31:0] badvaddr_in,

	output reg [31:0] pc_kernel = 32'h0,
	output reg cop_reset = 0,

	// Status unmangled
	output reg user_mode,
	output reg exc_level,
	output reg [31:0] epc_out,
	output reg [31:0] badvaddr_out,
	output reg [31:0] random_out
);

// see: http://www.cs.cornell.edu/courses/cs3410/2015sp/MIPS_Vol3.pdf
reg [31:0] cop_regs [31:0];
integer i;

always @* begin
	epc_out      <= cop_regs[`COP_EPC];
	user_mode    <= cop_regs[`COP_STATUS][`COP_STATUS_UM];
	exc_level    <= cop_regs[`COP_STATUS][`COP_STATUS_EXL];
	badvaddr_out <= cop_regs[`COP_BADVADDR];
	random_out   <= cop_regs[`COP_RANDOM];
end

always @* if (reset) rdata <= 32'd0;
else rdata <= cop_regs[rreg];

always @(posedge clk) begin
	if (reset) begin
		for (i = 0; i < 32; i = i+1) begin
			cop_regs[i] <= 32'd0;
		end
	end else if (enable) begin
		cop_regs[wreg] <= wdata;
		`INFO(("[cop] Write $%2d <= %x", wreg, wdata))
	end
	cop_regs[`COP_RANDOM] <= $random;
	if (cop_reset) cop_reset <= 1'b0;
end

always @(int_ext or int_tr or int_ovf or int_ri or int_sys or int_addrs or int_addrl) begin
	if (~exc_level) begin
		if      (int_ext)   cop_regs[`COP_CAUSE][6:2] = `INT_EXT;
		else if (int_tr)    cop_regs[`COP_CAUSE][6:2] = `INT_TR;
		else if (int_ovf)   cop_regs[`COP_CAUSE][6:2] = `INT_OVF;
		else if (int_ri)    cop_regs[`COP_CAUSE][6:2] = `INT_RI;
		else if (int_sys)   cop_regs[`COP_CAUSE][6:2] = `INT_SYS;
		else if (int_addrs) cop_regs[`COP_CAUSE][6:2] = `INT_ADDRS;
		else if (int_addrl) cop_regs[`COP_CAUSE][6:2] = `INT_ADDRL;

		if (| cop_regs[`COP_CAUSE][6:2]) begin
			cop_reset <= 1'b1;
			cop_regs[`COP_EPC] <= epc_in;
			cop_regs[`COP_STATUS][`COP_STATUS_EXL] <= 1'b1;
			cop_regs[`COP_STATUS][`COP_STATUS_UM]  <= 1'b0;

			case (cop_regs[`COP_CAUSE][6:2])
				`INT_EXT   : `INFO(("[exception] %s", `EXC_MSG_EXT))
				`INT_TR    : `INFO(("[exception] %s", `EXC_MSG_TR))
				`INT_OVF   : `INFO(("[exception] %s", `EXC_MSG_OVF))
				`INT_RI    : `INFO(("[exception] %s", `EXC_MSG_RI))
				`INT_SYS   : `INFO(("[exception] %s", `EXC_MSG_SYS))
				`INT_ADDRS : `INFO(("[exception] %s", `EXC_MSG_ADDRS))
				`INT_ADDRL : `INFO(("[exception] %s", `EXC_MSG_ADDRL))
				default    : `INFO(("[exception] %s", `EXC_MSG_PANIC))
			endcase
			`INFO(("[cop] exception at @%x", epc_in))
		end
	end
end

endmodule

`endif
