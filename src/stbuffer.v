`ifndef _stbuffer
`define _stbuffer

`include "defines.v"

module stbuffer(
                input             clk,
                input wire        reset,
                input wire [31:0] in_addr,
                input wire [31:0] in_wdata,
                input wire        store,
                input wire        load,
                input wire        isALUOp,
                output reg [31:0] out_addr = 0,
                output reg [31:0] out_wdata = 0,
                output reg        stall = 0,
                output reg        memwrite = 0
);

parameter ELEMENTS = `STBUFF_DEPTH;
parameter DEPTH = `STBUFF_DEPTH*2;
parameter WIDTH = 32;
integer i= 0;

reg [WIDTH-1:0] stbuff [DEPTH-1:0];
reg [2:0] counter = 0;
reg [31:0] temp = 0;


always @(posedge clk) begin
   if (reset) begin
     for (i = 0; i < DEPTH; i = i+1) begin
        stbuff[i] <= {WIDTH{1'b0}};
     end
   end else if(load == 1) begin
    for (i = 0; i < ELEMENTS; i = i+1) begin
      if (stbuff[2*i] == in_addr)
          temp <= stbuff[2*i+1];
    end
     out_wdata <= temp;
     memwrite <= 0;
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
         memwrite <= 1;
         for (i = 0; i < 2*(ELEMENTS-1); i = i+1) begin
            stbuff[i] <= stbuff[i+2];
         end
         stbuff[2*(ELEMENTS-1)] <= in_addr;
         stbuff[2*(ELEMENTS-1)+1] <= in_wdata;
         end
  end else if (isALUOp == 1) begin
      out_addr <= stbuff[0];
      out_wdata <= stbuff[1];
      memwrite <= 1;
      for (i = 0; i < 2*(ELEMENTS-1); i = i+1) begin
            stbuff[i] <= stbuff[i+2];
         end
      stbuff[2*(ELEMENTS-1)] <= {WIDTH{1'b0}};
      stbuff[2*(ELEMENTS-1)+1] <= {WIDTH{1'b0}};
      counter <= counter -1;
      stall <= 0;
  end
end

endmodule

`endif
