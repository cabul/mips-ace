//TODO Testbench branchpredictor_tb

`include "defines.v"
`include "branchpredictor.v"

module branchpredictor_tb;

reg c = 0;
reg r = 1;
reg [31:0] c_pc = 0;
reg f_e = 0;
reg f_b_t = 0;
reg [31:0] f_b_a = 0;
reg [31:0] f_c_p = 0;
wire [31:0] b_a;
wire b_t;
wire opi;

branchpredictor branchpredictor(
    .clk(c),
    .reset(r),
    .current_pc(c_pc),
    .feedback_enable(f_e),
    .feedback_branch_taken(f_b_t),
    .feedback_branch_addr(f_b_a),
    .feedback_current_pc(f_c_p),
    .branch_addr(b_a),
    .branch_taken(b_t),
    .opinion(opi)
);

always #10 c = !c;

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, branchpredictor_tb);
	`endif
    
    r = 1;
    #20
    r = 0;
    #10
    $display("Opinion: %d", opi);
    f_e <= 1;
    f_b_t <= 1;
    f_b_a <= 32'h300;
    f_c_p <= 32'h100; // At address 0x100 we jump to 0x300!
    c_pc <= 32'h100;
    #30
    $display("Opinion: %d", opi);
    
    $finish;
end

endmodule
