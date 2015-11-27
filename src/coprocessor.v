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

// reg [31:0] status; // reg 12
// reg [31:0] cause;  // reg 13
// reg [31:0] epc;    // reg 14

always @* begin
    rdata <= (rreg >= `C0_SR && rreg <= `C0_EPC) ? co_regs[rreg] : 32'd0;
end

always @(posedge clk) begin
	if (reset) begin
        rdata <= 32'd0;
        co_regs[`C0_SR] <= 32'd0; // TODO fix default value
        co_regs[`C0_CAUSE] <= 32'd0; // TODO fix default value
        co_regs[`C0_EPC] <= 32'd0; // TODO fix default value
	end else if (enable) begin
        case (wreg)
            `C0_SR: begin
            
            end
            `C0_CAUSE: begin
            
            end
            `C0_EPC: begin
            
            end
        endcase
    end
end

endmodule

`endif
