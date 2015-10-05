`include "frame.v"

module pipeline_tb;

reg clk = 0;
reg clear = 0;
reg we = 1;

reg [3:0] data_A = {4'b0};
wire [3:0] data_B;
wire [3:0] data_C;
//TODO Try to combine frames

frame #(.N(4)) frame_AB(.clk(clk), .clear(clear), .we(we), .in(data_A), .out(data_B));
frame #(.N(4)) frame_BC(.clk(clk), .clear(clear), .we(we), .in(data_B), .out(data_C));

always #5 clk = !clk;

initial begin
	$dumpfile("pipeline_tb.vcd");
	$dumpvars(0, pipeline_tb);

	$display("A\tB\tC");
	$display("-\t-\t-");
	$monitor("%h\t%h\t%h%t", data_A, data_B, data_C, $time);

	# 2 data_A = 1;
	# 10 data_A = 2;
	# 10 data_A = 3;
	# 10 data_A = 4;
	# 10 data_A = 5;
	# 10 data_A = 6;
	# 10 $finish;
end

endmodule
