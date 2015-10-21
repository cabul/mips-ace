`include "flipflop.v"

/// Flip Flop Testbench
module flipflop_tb;

reg clk = 0;
reg we = 1;
reg reset = 0;

reg [7:0] in = {8'b0};
wire [7:0] out;

fflop #(.N(8)) ff1(.clk(clk), .reset(reset), .we(we), .in(in), .out(out));

always #5 clk = !clk;

initial begin
	$dumpfile("traces/flipflop_tb.vcd");
	$dumpvars(0, flipflop_tb);

	$display("in\tout\twe\tclear\tclk");
	$display("--\t---\t--\t-----\t---");
	$monitor("%h\t%h\t%b\t%b\t%b\t%t", in, out, we, reset, clk, $time);

	in = 'haa;

	# 8 begin
		in = 'hbb;
		we = 0;
	end
	# 8 begin
		reset = 1;
		we = 1;
	end
	# 12 reset = 0;
	# 10 $finish;
	
end

endmodule
