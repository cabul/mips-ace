`ifndef _arbiter
`define _arbiter

`include "defines.v"

module arbiter (
	input wire clk,
	input wire reset,
	// I-Cache
	// Read
	input wire ic_read_req,
	output reg ic_read_ack,
	input wire [31:0] ic_read_addr,
	output reg [WIDTH-1:0] ic_read_data,
	// D-Cache
	// Read
	input wire dc_read_req,
	output reg dc_read_ack,
	input wire [31:0] dc_read_addr,
	output reg [WIDTH-1:0] dc_read_data,
	// Write
	input wire dc_write_req,
	output reg dc_write_ack,
	input wire [31:0] dc_write_addr,
	input wire [WIDTH-1:0] dc_write_data,
	// Main memory
	output reg mem_enable,
	output reg mem_rw,
	input wire mem_ack,
	output reg [31:0] mem_addr,
	output reg [WIDTH-1:0] mem_data_in,
	input wire [WIDTH-1:0] mem_data_out
);

parameter WIDTH = `MEMORY_WIDTH;

reg [1:0] arb_state = 2'b00;
// 00: Null state
// 01: I-Cache read
// 10: D-Cache write
// 11: D-Cache read

// TODO Coherency between I and D cache

// Handle requests
always @* begin
	case (arb_state)
		2'b00: begin // Null
			mem_enable = 1'b0;
			if (dc_write_req) begin
				arb_state = 2'b10;
				mem_rw = 0;
				mem_addr = dc_write_addr;
				mem_data_in = dc_write_data;
				mem_enable = 1;
			end else if (dc_read_req) begin
				arb_state = 2'b11;
				mem_rw = 1;
				mem_addr = dc_read_addr;
				mem_enable = 1;
			end else if (ic_read_req) begin
				arb_state = 2'b01;
				mem_rw = 1;
				mem_addr = ic_read_addr;
				mem_enable = 1;
			end
		end
		2'b01: begin // I Read
			if (mem_ack & mem_enable) ic_read_data = mem_data_out;
			ic_read_ack = mem_ack;
			mem_enable = ic_read_req;
		end
		2'b10: begin // D Write
			dc_write_ack = mem_ack;
			mem_enable = dc_write_req;
		end
		2'b11: begin // D Read
			if (mem_ack & mem_enable) dc_read_data = mem_data_out;
			dc_read_ack = mem_ack;
			mem_enable = dc_read_req;
		end
	endcase
	if (!mem_enable & !mem_ack) arb_state <= 2'b00;
end

always @(posedge clk) if (reset) arb_state <= 2'b00;

endmodule

`endif
