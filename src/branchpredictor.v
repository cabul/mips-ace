`ifndef _branchpredictor
`define _branchpredictor

`include "defines.v"

module branchpredictor(
    input wire clk,
    input wire reset,
    input wire [31:0] current_pc,
    output reg [31:0] jump_addr,
    output reg jump_taken,
    output reg opinion = 0
);

// Configuration

parameter ADDR_SIZE = 32; // bits
parameter SIZE = 4; // 2^SIZE
localparam BPSIZE = 2 ** SIZE;

// BP memory

reg [ADDR_SIZE-1:0] pc [BPSIZE-1:0];
reg [ADDR_SIZE-1:0] jump_pc [BPSIZE-1:0];
reg [1:0] taken_state [BPSIZE-1:0]; // 2 bit state
reg valid [BPSIZE-1:0];

// Utils

reg [SIZE-1:0] index;
integer i;

always @(posedge clk) begin
    index = current_pc >> 2;
    
	if (reset) begin
		for (i = 0; i < BPSIZE; i = i+1) begin
			valid[i] <= 0;
		end        
	end else begin
        opinion    <= (current_pc == pc[index]) && valid[index];
        jump_taken <= taken_state[index] > 2'b01;
        jump_addr  <= jump_pc[index];
    end
end

// I have opinion if stored in memory

endmodule

`endif
