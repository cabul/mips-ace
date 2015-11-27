`ifndef _coprocessor
`define _coprocessor

`include "defines.v"

// Coprocessor 0
// http://en.wikichip.org/wiki/mips/coprocessor_0
// mfc0 rt,rd and mtc0 rd,rt

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

reg [31:0] status; // reg 12
reg [31:0] cause;  // reg 13
reg [31:0] epc;    // reg 14

always @(posedge clk) begin
	if (reset) begin
        rdata  <= 32'd0;
        status <= 32'd0; // TODO fix default value
        cause  <= 32'd0; // TODO fix default value
        epc    <= 32'd0; // TODO fix default value
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
