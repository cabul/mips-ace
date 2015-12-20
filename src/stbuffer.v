`ifndef _stbuffer
`define _stbuffer

`include "defines.v"

/////////////////////////////
//                         //
//      Store Buffer       //
//                         //
/////////////////////////////

module stbuffer(
                input             clk,
                input wire        reset,
                input wire [31:0] in_addr,
                input wire [31:0] in_wdata,
                input wire        in_type,
                input wire        store,
                input wire        load,
                input wire        isALUOp,
                input wire        hit_dc,
                output reg [31:0] out_addr = 0,
                output reg [31:0] out_wdata = 0,
                output reg        out_type = 0,
                output reg        load_dc = 0,
                output reg        store_dc = 0,
                output reg        select_sb = 0
);

integer i = 0;

reg [64:0] stbuff [`STBUFF_DEPTH-1:0];
reg [4:0] counter = 0;
reg [31:0] temp = 0;

// Store buffer entry model :: { address || data || type }    64 33  32  1 0

always @(hit_dc) begin
   if(hit_dc & isALUOp) begin
      store_dc <= 0;
      for (i = 0; i < `STBUFF_DEPTH-1; i = i+1)
        stbuff[i] <= stbuff[i+1];

      stbuff[`STBUFF_DEPTH-1] <= {65{1'b0}};
      counter <= counter -1;
   end
   else if(hit_dc) begin
     select_sb <= 0;
     store_dc <= 0;
     load_dc <= 0;
   end
end

always @(posedge clk) begin
   if (reset) begin
     for (i = 0; i < `STBUFF_DEPTH; i = i+1) begin
       stbuff[i] <= {65{1'b0}};
     end
   end else if(load) begin //LOAD
      store_dc <= 0;
      temp = 0;
    for (i = 0; i < `STBUFF_DEPTH; i = i+1) begin
      if (stbuff[i][64:33] == in_addr)
        temp = stbuff[i][32:1];
     end if(!temp) begin //SB does not have the data
         out_wdata <= in_addr;
         load_dc <= 1;
         select_sb <= 0;
      end else  begin //SB does have the data
         out_wdata = temp;
         load_dc <= 0;
         select_sb <= 1;
      end
   end else if (store) begin //STORE
      load_dc <= 0;
      select_sb <= 0;
      if (counter < `STBUFF_DEPTH) begin //SB has enough room for a new element
         stbuff[counter][64:33] <= in_addr;
         stbuff[counter][32:1] <= in_wdata;
         stbuff[counter][0] <= in_type;
         store_dc <= 0;
         counter <= counter +1;
      end else begin //SB has not enough room for a new element
         out_addr <= stbuff[0][64:33];
         out_wdata <= stbuff[0][32:1];
         out_type <= stbuff[0][0];
         store_dc <= 1;
         for (i = 0; i < `STBUFF_DEPTH-1; i = i+1)
            stbuff[i]  <=  stbuff[i+1];

         stbuff[`STBUFF_DEPTH-1] <= {in_addr, in_wdata, in_type};
      end
  end else if (isALUOp) begin
      out_addr <= stbuff[0][64:33];
      out_wdata <= stbuff[0][32:1];
      out_type <= stbuff[0][0];
      store_dc <= 1;
      load_dc <= 0;
  end
end

endmodule

`endif
