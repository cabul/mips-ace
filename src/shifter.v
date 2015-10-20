`ifndef _shifter
`define _shifter

/*
 * SHIFTER info & pinout
 * -----------------
 *
 * This unit is asynchronous
 * 
 * toshift: input register to shift
 * number: input number of bits to be shifted
 * direction: input whether the shift is to the left (0) or to the right (1)
 * shifted: output register shifted
 */

module shifter(
		input wire [31:0] toshift,
		input wire [4:0] number,
		input wire direction,  //0 izquierda, 1 derecha
		output reg [31:0] shifted
		);

always @* begin
	if(direction == 1) begin
		shifted <= toshift >> number;
	end
	else begin
		shifted <= toshift << number;
	end

end
		
endmodule

`endif
