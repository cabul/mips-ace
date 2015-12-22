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
	input wire [69:0] exception_bus,
	output reg cop_reset = 0,
	output reg [31:0] pc_kernel = 32'h0,
	output reg [31:0] rdata = 32'd0,
	output reg [31:0] epc = 32'd0,
	output reg pc_select = 0,
	output reg cpu_mode = 0
);

reg [31:0] co_regs [14:8];
// C0_BADVA 8
// C0_SR    12
// C0_CAUSE 13
// C0_EPC   14

always @* begin
    rdata <= (rreg >= `C0_BADVA && rreg <= `C0_EPC) ? co_regs[rreg] : 32'd0;
	cpu_mode <= co_regs[`C0_SR][4];
	epc <= co_regs[`C0_EPC];
end

always @(posedge clk) begin
	if (reset) begin
        rdata <= 32'd0;
		co_regs[`C0_BADVA] <= 32'd0;
        co_regs[`C0_SR]    <= 1 << `C0_SR_UM;
        co_regs[`C0_CAUSE] <= 32'd0;
        co_regs[`C0_EPC]   <= 32'd0;
		cpu_mode <= co_regs[`C0_SR][4];

	end else if (enable) begin
        if (wreg >= `C0_SR && wreg <= `C0_EPC || wreg == `C0_BADVA) begin
            co_regs[wreg] <= wdata;
        end
    end
end

always @(exception_bus) begin
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[`EXC_OFF_TR     ]}} & (`INT_TR      << `C0_SR_EC));
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[`EXC_OFF_OVF    ]}} & (`INT_OVF     << `C0_SR_EC));
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[`EXC_OFF_RI     ]}} & (`INT_RI      << `C0_SR_EC));
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[`EXC_OFF_SYSCALL]}} & (`INT_SYSCALL << `C0_SR_EC));
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[`EXC_OFF_ADDRS  ]}} & (`INT_ADDRS   << `C0_SR_EC));
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[`EXC_OFF_ADDRL  ]}} & (`INT_ADDRL   << `C0_SR_EC));

    if (| exception_bus[66 -: 3]) begin
        co_regs[`C0_EPC] <= exception_bus[63:32];
        cop_reset <= 1;
		pc_select <= 1;
		cpu_mode <= 1;
		co_regs[`C0_SR] = co_regs[`C0_SR] | 1 << `C0_SR_EL;
		co_regs[`C0_SR] = co_regs[`C0_SR] | 1 << `C0_SR_UM;
		`INFO(("[Exception] %s",
			(exception_bus[`EXC_OFF_TR     ] ? `EXC_MSG_TR      :
			(exception_bus[`EXC_OFF_OVF    ] ? `EXC_MSG_OVF     :
			(exception_bus[`EXC_OFF_RI     ] ? `EXC_MSG_RI      :
			(exception_bus[`EXC_OFF_SYSCALL] ? `EXC_MSG_SYSCALL :
			(exception_bus[`EXC_OFF_ADDRS  ] ? `EXC_MSG_ADDRS   :
			(exception_bus[`EXC_OFF_ADDRL  ] ? `EXC_MSG_ADDRL   :
			                                   `EXC_MSG_PANIC
		))))))))
    end else begin
        cop_reset <= 0;
		pc_select <= 0;
    end
end

endmodule

`endif
