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
    input wire [66:0] exception_bus,
	output reg cop_reset = 0,
	output reg [31:0] pc_kernel = 32'h80000180,
    output reg [31:0] rdata = 32'd0,
	output reg [31:0] epc = 32'd0,
	output reg pc_select = 0,
	output reg cpu_mode = 0
);

reg [31:0] co_regs [14:8];
// C0_BadAR 8
// C0_SR    12
// C0_CAUSE 13
// C0_EPC   14

always @* begin
    rdata <= (rreg >= `C0_BadAR && rreg <= `C0_EPC) ? co_regs[rreg] : 32'd0;
	cpu_mode <= co_regs[`C0_SR][4];
	epc <= co_regs[`C0_EPC];
end

always @(posedge clk) begin
	if (reset) begin
        rdata <= 32'd0;
		co_regs[`C0_BadAR] <= 32'd0;
        co_regs[`C0_SR]    <= 1 << `C0_SR_UM;
        co_regs[`C0_CAUSE] <= 32'd0;
        co_regs[`C0_EPC]   <= 32'd0;
		cpu_mode <= co_regs[`C0_SR][4];

	end else if (enable) begin
        if (wreg >= `C0_BadAR && wreg <= `C0_EPC) begin
            co_regs[wreg] <= wdata;
        end
    end
end

always @(exception_bus) begin
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[66]}} & (`INT_OVF     << `C0_SR_EC));
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[65]}} & (`INT_RI      << `C0_SR_EC));
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[64]}} & (`INT_SYSCALL << `C0_SR_EC));

/*
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[34]}} & (`INT_OVF     << `C0_SR_PI));
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[33]}} & (`INT_RI      << `C0_SR_PI));
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[32]}} & (`INT_SYSCALL << `C0_SR_PI));*/
    

    if (| exception_bus[66 -: 3]) begin
        co_regs[`C0_EPC] <= exception_bus[63:32];
        cop_reset <= 1;
		pc_select <= 1;
		cpu_mode <= 1; 
		co_regs[`C0_SR] = co_regs[`C0_SR] | 1 << `C0_SR_EL;
		co_regs[`C0_SR] = co_regs[`C0_SR] | 1 << `C0_SR_UM;
		 
    end else begin
        cop_reset <= 0;
		pc_select <= 0;
    end
/*
	if (| exception_bus[66 -: 3]) begin //////////
        co_regs[`C0_BadAR] <= exception_bus[63:32];
    end */
end

endmodule

`endif
