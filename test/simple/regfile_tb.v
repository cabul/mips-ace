`include "regfile.v"

// Register File Testbench
module regfile_tb;

reg clk = 0;
reg reset = 0;
reg regwrite = 0;
reg [4:0] rreg1 = 5'b0, rreg2 = 5'b0, wreg = 5'b0;
reg [31:0] wdata = 32'b0;
wire [31:0] rdata1, rdata2;

regfile file(.reset(reset), .clk(clk), .regwrite(regwrite), .rreg1(rreg1), .rreg2(rreg2), .wreg(wreg), .wdata(wdata), .rdata1(rdata1), .rdata2(rdata2));

always #5 clk = !clk;

initial begin
	$dumpfile("traces/regfile_tb.vcd");
	$dumpvars(0, regfile_tb);
	
	# 2 reset <= 1;

	# 10 begin
		reset <= 0;
		wdata <= 14;
		wreg <= 1;
		regwrite <= 1;
	end

	# 1 begin
		rreg1 <= 1;
	end
	
	# 10 $finish;
end

endmodule
