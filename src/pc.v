`ifndef _pc
`define _pc

`include "defines.v"

module pc(
    input wire clk,
    input wire reset,
    input wire we,
    input wire is_jump,
    input wire is_branch,
    input wire is_kernel,
    input wire is_eret,
    input wire is_bpredictor,
    input wire is_misspred,
    input wire [31:0] dst_nextpc,
    input wire [31:0] dst_jump,
    input wire [31:0] dst_branch,
    input wire [31:0] dst_kernel,
    input wire [31:0] dst_eret,
    input wire [31:0] dst_prediction,
    input wire [31:0] dst_misspred,
    input wire [31:0] initial_pc,
    output reg [31:0] pc_out
);

// Internal memory

wire [31:0] pc_computed;

// Multiplexer chain

assign pc_computed = is_misspred   ? dst_misspred   :
                     is_eret       ? dst_eret       :
                     is_kernel     ? dst_kernel     :
                     is_bpredictor ? dst_prediction :
                     is_branch     ? dst_branch     : 
                     is_jump       ? dst_jump       : dst_nextpc;

// Sync output

always @(posedge clk) begin
	if (reset)   pc_out <= initial_pc;
	else if (we) pc_out <= pc_computed;
end

endmodule

`endif
