`ifndef _stbuffer
`define _stbuffer

`include "defines.v"

//TODO Module stbuffer
module stbuffer(
                input wire reset,
                input wire [31:0] in_addr,
                input wire [31:0] in_wdata,
                input wire store,
                input wire isALUOp,
                output reg [31:0] out_addr,
                output reg [31:0] out_wdata,
                output reg stall,
                output reg memwrite
);

parameter ELEMENTS = `STBUFF_DEPTH;
parameter DEPTH = `STBUFF_DEPTH*2;
parameter WIDTH = 32;
integer i;

reg [WIDTH-1:0] stbuff [DEPTH-1:0];
reg counter = 0;

always @(posedge clk) begin
   if (reset) begin
     for (i = 0; i < DEPTH; i = i+1) begin
        stbuff[i] <= {WIDTH{1'b0}};
     end
  end else if (store == 1) begin
      if (counter < ELEMENTS) begin
         stbuff[2*counter] <= in_addr;
         stbuff[2*counter+1] <= in_wdata;
         counter <= counter +1;
         stall <= 0;
         memwrite <= 0;
      end else begin
         stall <= 1;
         out_addr <= stbuff[0];
         out_wdata <= stbuff[1];
         for (i = 0; i < 2*(DEPTH-1); i = i+1) begin
            stbuff[i] <= stbuff[i+2];
         end
         stbuff[2*(DEPTH-1)] <= in_addr;
         stbuff[2*(DEPTH-1)+1] <= in_wdata;
         end
  end else if (isALUOp == 1) begin
      out_addr <= stbuff[0];
      out_wdata <= stbuff[1];
  end
   else stall <= 0;
end

endmodule

`endif
