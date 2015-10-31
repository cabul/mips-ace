`ifndef _regfile
`define _regfile

//
// Register File
//
// 32 General purpose registers of 32 bits.
//
// Description:
//
// Reads are asynchronous.
// Writes happen on rising edge.
// Register 0 is always 0 and cannot be written to.
// 
// Ports:
// clk - Clock signal
// reset - Reset signal
// rreg1 - Read data 1 from this register
// rreg2 - Read data 2 from this register
// rdata1 - Read data 1 output
// rdata2 - Read data 2 output
// regwrite - On 1 write to register
// wreg - Write to this register
// wdata - Write this data
//
module regfile(
	input wire clk,
	input wire reset,
	input wire [4:0] rreg1, rreg2,
	output reg [31:0] rdata1, rdata2,
	input wire regwrite,
	input wire [4:0] wreg,
	input wire [31:0] wdata
);

reg [31:0] mem [0:31];

always @(*) begin
	if (rreg1 == 5'b0)
		rdata1 <= 32'b0;
	/* This enables bypass
	else if(regwrite && wreg == rreg1)
		rdata1 <= wdata;
	*/
  else
	  rdata1 <= mem[rreg1][31:0];
end

always @(*) begin
	if (rreg2 == 5'b0)
		rdata2 <= 32'b0;
	/* This enables bypass
	else if(regwrite && wreg == rreg2)
		rdata2 <= wdata;
	*/
  else
	  rdata2 <= mem[rreg2][31:0];
end

always @(posedge clk) begin
	if (reset) begin
		//TODO Prettify
		mem[0] <= 0;
		mem[1] <= 0;
		mem[2] <= 0;
		mem[3] <= 0;
		mem[4] <= 0;
		mem[5] <= 0;
		mem[6] <= 0;
		mem[7] <= 0;
		mem[8] <= 0;
		mem[9] <= 0;
		mem[10] <= 0;
		mem[11] <= 0;
		mem[12] <= 0;
		mem[13] <= 0;
		mem[14] <= 0;
		mem[15] <= 0;
		mem[16] <= 0;
		mem[17] <= 0;
		mem[18] <= 0;
		mem[19] <= 0;
		mem[20] <= 0;
		mem[21] <= 0;
		mem[22] <= 0;
		mem[23] <= 0;
		mem[24] <= 0;
		mem[25] <= 0;
		mem[26] <= 0;
		mem[27] <= 0;
		mem[28] <= 0;
		mem[29] <= 0;
		mem[30] <= 0;
		mem[31] <= 0;
	end
	else if (regwrite && wreg != 5'b0)
		mem[wreg] <= wdata;
end

endmodule

`endif
