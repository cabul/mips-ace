`ifndef _branchpredictor
`define _branchpredictor

`include "defines.v"

// Direct mapping

module branchpredictor(
    input wire clk,
    input wire reset,
    input wire [ADDR_SIZE-1:0] current_pc,
    // Feedback
    input wire feedback_enable,
    input wire feedback_branch_taken,
    input wire [ADDR_SIZE-1:0] feedback_branch_addr,
    input wire [ADDR_SIZE-1:0] feedback_current_pc,
    // Output
    output reg [ADDR_SIZE-1:0] branch_addr = 0,
    output reg branch_taken = 0,
    output reg opinion = 0
);

// Configuration

parameter ADDR_SIZE = 32; // bits
parameter SIZE = 4; // 2^SIZE
localparam REAL_ADDR_SIZE = ADDR_SIZE - 2;
localparam BPSIZE = 2 ** SIZE;

// BP memory

reg [REAL_ADDR_SIZE-1:0] pc [BPSIZE-1:0];
reg [REAL_ADDR_SIZE-1:0] branch_pc [BPSIZE-1:0];
reg [1:0] taken_state [BPSIZE-1:0]; // 2 bit state
reg valid [BPSIZE-1:0];

// Utils

reg [SIZE-1:0] index;
reg [SIZE-1:0] feedback_index;
integer i;

// Internal memory setup

initial begin
    for (i = 0; i < BPSIZE; i = i+1) begin
        valid[i]       <= 0;
        taken_state[i] <= 2'b01;
        branch_pc[i]   <= 32'd0;
        pc[i]          <= 32'd0;
    end
end

// Output block (async)

always @* begin
    index = current_pc >> 2;
    
    opinion      <= ((current_pc >> 2) == pc[index]) && valid[index];
    branch_taken <= taken_state[index] > 2'b01;
    branch_addr  <= branch_pc[index] << 2;
end

// Feedback block (sync)

always @(posedge clk) begin
	if (reset) begin
		for (i = 0; i < BPSIZE; i = i+1) begin
			valid[i]       <= 0;
            taken_state[i] <= 2'b01;
		end
    end else begin
        feedback_index = feedback_current_pc >> 2;
        
        if (feedback_enable) begin
            pc[feedback_index]        <= feedback_current_pc >> 2;
            branch_pc[feedback_index] <= feedback_branch_addr >> 2;
            valid[feedback_index]     <= 1;
            
            // Saturated counter
            case (taken_state[feedback_index])
                2'b00: taken_state[feedback_index] <= feedback_branch_taken;
                2'b01: taken_state[feedback_index] <= feedback_branch_taken ? 2'b10 : 2'b00;
                2'b10: taken_state[feedback_index] <= feedback_branch_taken ? 2'b11 : 2'b01;
                2'b11: taken_state[feedback_index] <= feedback_branch_taken ? 2'b11 : 2'b10;
            endcase
        end
    end
end

endmodule

`endif
