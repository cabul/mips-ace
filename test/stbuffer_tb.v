`include "defines.v"
`include "stbuffer.v"

module stbuffer_tb;

   reg tb_clk = 0;
   reg tb_reset = 0;
   reg [31:0] tb_in_addr = 0;
   reg [31:0] tb_in_wdata = 0;
   reg        tb_store = 0;
   reg        tb_isALUOp = 0;
   reg        tb_load = 0;
   wire [31:0] tb_out_addr;
   wire [31:0] tb_out_wdata;
   wire        tb_stall;
   wire        tb_memwrite;

   stbuffer stbuffer(.clk(tb_clk), .reset(tb_reset), .in_addr(tb_in_addr), .in_wdata(tb_in_wdata), .store(tb_store), .isALUOp(tb_isALUOp), .out_addr(tb_out_addr), .out_wdata(tb_out_wdata), .stall(tb_stall), .memwrite(tb_memwrite), .load(tb_load));

initial begin
	`ifdef TRACEFILE
	$dumpfile(`TRACEFILE);
	$dumpvars(0, stbuffer_tb);
	`endif
   tb_clk = 0;

   #5 begin
   tb_clk = 1;

   tb_in_addr = 32'd5;
   tb_in_wdata = 32'd1;
   tb_store = 1;
   tb_isALUOp = 0;
                     tb_load = 0;
   end

   #5
      tb_clk = 0;

      #5 begin
         tb_clk =1;

 tb_in_addr = 32'd5;
 //  tb_in_wdata = 32'd2;
   tb_store = 0;
   tb_isALUOp = 0;
 tb_load = 1;
      end

   #5 tb_clk = 0;


   #5 begin
      tb_clk=1;
 tb_in_addr = 32'd15;
   tb_in_wdata = 32'd3;
      tb_isALUOp = 0;
      tb_store = 1;
   end

   #5      tb_clk = 0;

   #5
      tb_clk = 1;

   #5
      tb_clk = 0;
/*
   #5 begin
      tb_clk = 1;
      tb_isALUOp = 1;
      tb_store = 0;
                     tb_load = 1;
                     tb_in_addr = 32'd3;
   end

   #5 tb_clk = 0;

   #5 tb_clk = 1;

   #5  tb_clk = 0;

   #5 tb_clk = 1;

   #5 tb_clk = 0;
   #5 tb_clk = 1;
*/
   #5 begin
      tb_clk = 0;
      $finish;
   end


end

endmodule
