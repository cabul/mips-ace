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
    input wire [34:0] exception_bus,
    output reg [31:0] rdata = 32'd0
);

reg [31:0] co_regs [14:12];
// C0_SR    12
// C0_CAUSE 13
// C0_EPC   14

always @* begin
    rdata <= (rreg >= `C0_SR && rreg <= `C0_EPC) ? co_regs[rreg] : 32'd0;
end

always @(posedge clk) begin
	if (reset) begin
        rdata <= 32'd0;
        co_regs[`C0_SR]    <= 32'd0; // TODO fix default value
        co_regs[`C0_CAUSE] <= 32'd0;
        co_regs[`C0_EPC]   <= 32'd0;
	end else if (enable) begin
        if (wreg >= `C0_SR && wreg <= `C0_EPC) begin
            co_regs[wreg] <= wdata;
        end
    end
end

always @(exception_bus) begin
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[34]}} & (`INT_OVF     << `C0_SR_EC));
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[33]}} & (`INT_RI      << `C0_SR_EC));
    co_regs[`C0_CAUSE] = co_regs[`C0_CAUSE] | ({32{exception_bus[32]}} & (`INT_SYSCALL << `C0_SR_EC));
    
    if (| exception_bus[34 -: 3]) begin
        co_regs[`C0_EPC] <= exception_bus[31:0];
    end
end

endmodule

`endif
