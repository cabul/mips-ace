`ifndef _regfile
`define _regfile

module regfile(
	input wire clk,
	input wire [4:0] rreg1, rreg2,
	output reg [31:0] rdata1, rdata2,
	input wire regwrite,
	input wire [4:0] wreg,
	input wire [31:0] wdata);

reg [31:0] mem [0:31];

//TODO Only read after clk edge?

always @(*) begin
	if (rreg1 == 5'b0)
		rdata1 <= 32'b0;
	/*
	else if(regwrite && wreg == rreg1)
		rdata1 <= wdata;
	*/
	else
		rdata1 <= mem[rreg1][31:0];
end

always @(*) begin
	if (rreg2 == 5'b0)
		rdata2 <= 32'b0;
	/*
	else if(regwrite && wreg == rreg2)
		rdata2 <= wdata;
	*/
	else
		rdata2 <= mem[rreg2][31:0];
end

always @(posedge clk) begin
	if (regwrite && wreg != 5'b0)
		mem[wreg] <= wdata;
end

endmodule

`endif
