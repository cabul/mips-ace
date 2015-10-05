`include "frame.v"

module frame_tb;

reg clk = 0;
reg we = 1;
reg clear = 0;

reg [7:0] in = {8'b0};
wire [7:0] out;

frame #(.N(8)) r1(.clk(clk), .clear(clear), .we(we), .in(in), .out(out));

always #5 clk = !clk;

initial begin
	$dumpfile("frame_tb.vcd");
	$dumpvars(0, frame_tb);

	$display("in\tout\twe\tclear\tclk");
	$display("--\t---\t--\t-----\t---");
	$monitor("%h\t%h\t%b\t%b\t%b\t%t", in, out, we, clear, clk, $time);

	in = 'haa;

	# 8 begin
		in = 'hbb;
		we = 0;
	end
	# 8 begin
		clear = 1;
		we = 1;
	end
	# 12 clear = 0;
	# 10 $finish;
	
end

endmodule
