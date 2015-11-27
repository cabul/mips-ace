//TODO Testbench coprocessor_tb

`include "defines.v"
`include "coprocessor.v"

module coprocessor_tb;

reg c = 0;
reg w = 0;
reg r = 1;
reg [4:0] r_reg = 5'd13;
reg [4:0] w_reg = 5'd13;
reg [31:0] in = 0;
reg [34:0] bus = 0;
wire [31:0] out;

coprocessor coprocessor(
    .clk(c),
    .reset(r),
    .enable(w),
    .rreg(r_reg),
    .wreg(w_reg),
    .wdata(in),
    .exception_bus(bus),
    .rdata(out)
);


always #10 c = !c;

initial begin
    #20
    r <= 0;
    
    #20
	$display("Read cause: %x", out);
    
    #20
    bus[32] <= 1;
    bus[8] <= 1;
    
    #20
	$display("Read cause: %x", out);
    
    #20
    r_reg <= `C0_EPC;
    
    #20
	$display("Read EPC: %x", out);
    
    $finish;
end

endmodule
