`ifndef _stbuffer_circular
`define _stbuffer_circular

`include "defines.v"

/////////////////////////////
//                         //
//  Circular Store Buffer  //
//                         //
/////////////////////////////

module stbuffer_circular(
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

//Keep in mind that Store Buffer's depth is "STBUFF_DEPTH"-1 due to pointers!!

// Pointers to the newest and oldest entry beg_p -> oldest entry
reg [$clog2(`STBUFF_DEPTH)-1:0] beg_p = 0, end_p = 0;
//Temporal registers
reg [31:0] temp1 = 0, temp2 = 0;
//State machine register
reg [2:0] stbuff_state = 3'b000;
// Store buffer entry model :: { address || data || type }
reg [64:0] stbuff [`STBUFF_DEPTH-1:0];
integer i = 0;

//Synchronism ->  Store Buffer -- cache
always @(hit_dc) begin
   if(hit_dc & isALUOp) begin //It's ALU operation, and DC has a hit
      store_dc <= 0; //Clear signals
      load_dc <= 0;
      beg_p <= (beg_p +1) % `STBUFF_DEPTH; //Clear entry in SB
   end
   else if(hit_dc) begin //It's a load and DC has a hit
     select_sb <= 0; //Clear signals
     store_dc <= 0;
     load_dc <= 0;
   end
end

//Store Buffer
always @(posedge clk) begin
   if (reset) begin
      beg_p <= 0;
      end_p <= 0;
      i = 0;
     while(i<`STBUFF_DEPTH) begin
        stbuff[i] <= {65{1'b0}};
        i = i+1;
     end
   end else begin
      stbuff_state = {isALUOp, store, load};
      case(stbuff_state)
        3'b001: begin //LOAD
           store_dc <= 0;
           if(beg_p == end_p) begin //Empty
              out_wdata <= 32'd0;
           end else begin
              i = 0;
              temp1 = end_p;
              temp2 = 0;
              while(i<`STBUFF_DEPTH) begin //Let's get the youngest entry
                 if (stbuff[end_p][64:33] == in_addr)
                   temp2 = stbuff[end_p][32:1];
                end_p = (end_p +1) % `STBUFF_DEPTH ;
                i = i+1;
              end
              if (!temp2) begin //SB does not have the data
                 end_p <= temp1;
                 out_wdata <= in_addr;
                 load_dc <= 1;
                 select_sb <= 0;
              end else begin //SB does have the data
                 end_p <= temp1;
                 out_wdata <= temp2;
                 load_dc <= 0;
                 select_sb <= 1;
              end
           end
        end
        3'b010: begin //STORE
           load_dc <= 0;
           select_sb <= 0;
           if((end_p+1)%`STBUFF_DEPTH  == beg_p) begin //Full
              out_addr <= stbuff[beg_p][64:33];
              out_wdata <= stbuff[beg_p][32:1];
              out_type <= stbuff[beg_p][0];
              store_dc <= 1; //Send signal to DC to store oldest entry
              //Update Store Buffer
              beg_p <= (beg_p +1) % `STBUFF_DEPTH ;
              end_p <= (end_p +1) % `STBUFF_DEPTH ;
              //Fill with new entries
              stbuff[end_p][64:33] <= in_addr;
              stbuff[end_p][32:1] <= in_wdata;
              stbuff[end_p][0]    <= in_type;
           end else begin //Let's store
              stbuff[end_p][64:33] <= in_addr;
              stbuff[end_p][32:1] <= in_wdata;
              stbuff[end_p][0] <= in_type;
              store_dc <= 0;
              out_addr <= 0;
              out_wdata <= 0;
              out_type <= 0;
              end_p <= (end_p +1) % `STBUFF_DEPTH ;
           end
        end
        3'b100: begin //isALUOp
           load_dc <= 0;
           if(beg_p == end_p) begin //Empty
              store_dc <= 0;
              out_addr <= 0;
              out_wdata <= 0;
              out_type <= 0;
           end else begin //Let's get rid of the oldest entry
              store_dc <= 1;
              out_addr <= stbuff[beg_p][64:33];
              out_wdata <= stbuff[beg_p][32:1];
              out_type <= stbuff[beg_p][0];
              end
        end
        endcase
      end
end

endmodule

`endif
