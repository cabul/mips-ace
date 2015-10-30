`ifndef _cpu
`define _cpu

`include "flipflop.v"
`include "adder.v"
`include "memory.v"
`include "regfile.v"
`include "signextender.v"
`include "alu.v"
`include "multiplexer.v"
`include "comparator.v"
`include "control.v"

// Central Processing Unit
module cpu(
	input wire clk,
	input wire reset
);

parameter DATA = "data/mem_data.hex";

// Instruction Fetch
wire [31:0] next_pc;
wire [31:0] pc_out;
wire [31:0] mem_out;
wire [31:0] if_pc;
wire [31:0] in_pc;

multiplexer pc_mux(
	.select(0),
	.in_data({next_pc,if_pc}),
	.out_data(in_pc)
);

reg pc_we = 1;
flipflop #(.N(32)) pc (
	.clk(clk),
	.reset(reset),
	.we(pc_we),
	.in(in_pc),
	.out(pc_out)
);
memory #(.DATA(DATA)) mem (
	.clk(clk),
	.addr(pc_out),
	.data(mem_out)
);
adder pc_adder (
	.in_s(pc_out),
	.in_t(32'd4),
	.out(if_pc)
);

// Alternative?
assign if_pc = pc_out + 4;

// Instruction Decode
reg if_id_we = 1;
wire [31:0] id_pc;
wire [31:0] instr;
flipflop #(.N(64)) if_id (
	.clk(clk),
	.reset(reset),
	.we(if_id_we),
	.in({if_pc, mem_out}),
	.out({id_pc, instr})
);

// Fancy control
wire id_reg_dst;
wire id_jump;
wire id_branch;
wire id_mem_read;
wire id_mem_to_reg;
wire[3:0] id_alu_op;
wire id_mem_write;
wire id_alu_src;
wire id_reg_write;

control control (
	.op_code(instr[31:26]),
	.funct(instr[5:0]),
	.reg_dst(id_reg_dst),
	.jump(id_jump),
	.branch(id_branch),
	.mem_read(id_mem_read),
	.mem_to_reg(id_mem_to_reg),
	.alu_op(id_alu_op),
	.mem_write(id_mem_write),
	.alu_src(id_alu_src),
	.reg_write(id_reg_write)
);

wire wr_mux_out;
multiplexer w_reg_mux(
	.select(id_reg_dst),
	.in_data({instr[15:11],instr[20:16]}),
	.out_data(wr_mux_out)
);

regfile regfile(
	.clk(clk),
	.reset(reset),
	.r_reg1(instr[25:21]),
	.r_reg2(instr[20:16]),
	.reg_write(id_reg_write),
	.w_reg(wr_mux_out)
);

wire id_immediate;
signextender sign_extend(
	.extend(instr[15:0]),
	.extended(id_immediate)
);

// Execute
// id_reg_dst;
// id_jump;
// id_branch;
// id_mem_read;
// id_mem_to_reg;
// id_alu_op;
// id_mem_write;
// id_alu_src;
// id_reg_write;
flipflop #(.N()) id_ex;
multiplexer mux_s;
multiplexer mux_t;
alu alu;

// Memory
flipflop #(.N()) ex_mem;

// Write Back
flipflop #(.N()) mem_wb;
multiplexer mux_wb;

endmodule

`endif
