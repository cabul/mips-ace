`ifndef _stbuffer
`define _stbuffer

`include "defines.v"

/////////////////////////////
//                         //
//  Circular Store Buffer  //
//                         //
/////////////////////////////

module stbuffer(
	input wire        clk,
	input wire        reset,
	input wire [31:0] addr_in,
	input wire [31:0] data_in,
	input wire        type_in,
	input wire        is_store,
	input wire        is_load,
	input wire        is_alu,
	input wire        dc_hit,
	output reg [31:0] addr_out = 0,
	output reg [31:0] data_out = 0,
	output reg        type_out = 0,
	output reg        dc_enable = 0,
	output reg        dc_store = 0,
	output reg        dc_clk = 0,
	output reg        stb_hit = 0,
	output reg        stb_full = 0
);

//Keep in mind that Store Buffer's depth is "STBUFF_DEPTH"-1 due to pointers!!
parameter ENTRIES = `STBUFF_DEPTH;
localparam ENTRYBITS = $clog2(ENTRIES);

// Pointers to the newest and oldest entry beg_p -> oldest entry
reg [ENTRYBITS-1:0] beg_p = 0, end_p = 0;
// Temporal pointer
reg [ENTRYBITS-1:0] temp = 0;

// Store buffer entry model :: { address || data || type }
reg [31:0] stb_addr [ENTRIES-1:0];
reg [31:0] stb_data [ENTRIES-1:0];
reg        stb_type [ENTRIES-1:0];
integer i = 0;
integer len = 0;
reg stb_empty = 1;

// Synchronize with cache
always @(dc_hit) begin
	// We are storing and dc has a hit
	if (dc_hit && dc_store) begin
		dc_store = 0;
		`INFO(("[stb] finished store"))
		stb_full = 0; // STB shouldn't be full here
		stb_addr[beg_p] = {32{1'b0}};
		stb_data[beg_p] = {32{1'b0}};
		stb_type[beg_p] = 1'b0;
		beg_p = (beg_p+1) % ENTRIES; // Clear entry in STB
		stb_empty = beg_p == end_p;
		len = len-1;
	end else if (dc_store && !stb_full) begin
		dc_store = 0;
	end
end

always @(negedge clk) dc_clk = 0;

//Store Buffer
always @(posedge clk) begin
	if (reset) begin
		beg_p <= 0;
		end_p <= 0;
		len <= 0;
		stb_empty <= 1;
		for (i=0; i<ENTRIES; i=i+1) begin
			stb_addr[i] <= {32{1'b0}};
			stb_data[i] <= {32{1'b0}};
			stb_type[i] <= 1'b0;
		end
	end else begin
		if (dc_hit && dc_store) begin
			dc_store = 0;
			`INFO(("[stb] finished store"))
			stb_full = 0; // STB shouldn't be full here
			stb_addr[beg_p] = {32{1'b0}};
			stb_data[beg_p] = {32{1'b0}};
			stb_type[beg_p] = 1'b0;
			beg_p = (beg_p+1) % ENTRIES; // Clear entry in STB
			stb_empty = beg_p == end_p;
			len = len-1;
		end
		case ({is_load, is_store, is_alu})
			// LOAD Operation
			// Try to find the value in the buffer
			//if (is_load) begin
			3'b100: begin
				dc_enable = 1;
				dc_store  = 0;
				if (stb_empty) begin
					stb_hit = 0;
					data_out = {32{1'b0}};
					addr_out = {32{1'b0}};
					type_out = 1'b0;
				end else begin
					stb_hit = 0;
					i = 0;
					temp = (end_p+ENTRIES-1)%ENTRIES;
					while ((beg_p+ENTRIES-1)%ENTRIES != temp && !stb_hit) begin
						if (stb_addr[temp] == addr_in) begin
							data_out = stb_data[temp];
							addr_out = addr_in;
							type_out = type_in;
							`INFO(("[stb] i have the data %x %x %d", addr_out, data_out, temp))
							dc_enable = 0;
							stb_hit = 1;
						end
						i=i+1;
						// Go backwards
						temp=(temp+ENTRIES-1)%ENTRIES;
					end
					if (!stb_hit) begin
						// Clean up
						data_out = {32{1'b0}};
						addr_out = {32{1'b0}};
						type_out = 1'b0;
					end
				end
			end
			// STORE Operation
			// Try to fit the value in the buffer
			// We do NOT update values
			3'b010: begin
				`INFO(("[stb] store %x %x", addr_in, data_in))
				if (end_p == beg_p && !stb_empty) begin // STB is full
					`INFO(("[stb] full"))
					stb_full = 1; // We will stall the CPU here
					// Set data to send to cache
					data_out = stb_data[beg_p];
					addr_out = stb_addr[beg_p];
					type_out = stb_type[beg_p];
					dc_store = 1;
				end else begin // STB not full
					len = len+1;
					stb_empty = 0;
					// Save the data
					stb_data[end_p] = data_in;
					stb_addr[end_p] = addr_in;
					stb_type[end_p] = type_in;
					// Advance pointer
					end_p = (end_p+1) % ENTRIES;
				end
			end
			// ALU Operation
			// DCache is idle here, so we can try to store the head
			3'b001: begin
				if (stb_empty) begin // We are empty
					data_out <= {32{1'b0}};
					addr_out <= {32{1'b0}};
					type_out <= 1'b0;
					dc_store = 0;
				end else begin
					// Set data to send to cache
					data_out = stb_data[beg_p];
					addr_out = stb_addr[beg_p];
					type_out = stb_type[beg_p];
					`INFO(("[stb] send data %x %x", addr_out, data_out))
					dc_store = 1;
				end
			end
		endcase
	end
	dc_clk = 1;
end

endmodule

`endif
