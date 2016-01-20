`ifndef _stdio
`define _stdio

`include "defines.v"

module stdio (
	input wire [7:0] addr,
	input wire clk,
	input wire reset,
	input wire read_write,
	input wire enable,
	input wire [31:0] data_in,
	output reg [31:0] data_out,
	output reg exit = 0
);

integer err;

parameter STDIN  = 32'h8000_0000;
parameter STDOUT = 32'h8000_0001;
parameter STDERR = 32'h8000_0002;

always @(posedge clk) begin
	if (reset) begin
		data_out <= 0;
		exit <= 1'b0;
	end else if (enable) begin
		if (read_write) begin
			case (addr)
				`IO_CHAR:  data_out = $fgetc(STDIN);
				`IO_INT:   err      = $fscanf(STDIN, "%d", data_out);
				`IO_FLOAT: err      = $fscanf(STDIN, "%f", data_out);
				`IO_HEX:   err      = $fscanf(STDIN, "%x", data_out);
				`IO_EXIT: $finish;
				default: `WARN(("[IO] Unknown operation"))
			endcase
		end else begin
			case (addr)
				`IO_CHAR:  $fwrite(STDERR, "%0c", data_in);
				`IO_INT:   $fwrite(STDERR, "%0d", data_in);
				`IO_FLOAT: $fwrite(STDERR, "%0f", data_in);
				`IO_HEX:   $fwrite(STDERR, "%0x", data_in);
				`IO_EXIT: exit <= 1'b1;
				default: `WARN(("[IO] Unknown operation"))
			endcase
			$fflush(STDERR);
		end
	end
end

endmodule

`endif
