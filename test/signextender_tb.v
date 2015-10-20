`include "signextender.v"

module signextender_tb;

reg [15:0] inmediato = 16'hf001;
wire [31:0] inmediato_extend;

signextender signextender (.extend(inmediato), .extended(inmediato_extend));

initial begin
	$monitor("%h = %h", signextender.extend, signextender.extended);
end

endmodule
