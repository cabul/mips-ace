`include "shifter.v"

// Shifter Testbench
module shifter_tb;

reg [31:0] toshift = 32'b10000000000000000000000000000000;
reg[4:0] number = 5'b11111;
reg direction = 1;  //0 izquierda, 1 derecha
wire [31:0] shifted;

shifter shifter_ (.toshift(toshift), .number(number), .direction(direction), .shifted(shifted));

initial begin
	$dumpfile("out/shifter_tb.vcd");
	$dumpvars(0, shifter_tb);

	$monitor("Registro= %b, posiciones = %b, direccion (0 izqda) = %b, ** resultado = %b **", shifter_.toshift, shifter_.number, shifter_.direction, shifter_.shifted);
end

endmodule
