`ifndef _cpu
`define _cpu

`include "flipflop.v"
`include "cache_direct.v"
`include "cache_2way.v"
`include "cache_4way.v"
`include "memory_sync.v"
`include "arbiter.v"
`include "regfile.v"
`include "alu.v"
`include "multiplexer.v"
`include "control.v"
`include "fwdcontrol.v"
`include "hzdcontrol.v"
`include "alucontrol.v"
`include "stdio.v"

// Central Processing Unit
module cpu(
	input wire clk,
	input wire reset,
	// Memory ports
	output wire mem_enable,
	output wire mem_rw,
	input wire mem_ack,
	output wire [31:0]  mem_addr,
	input wire [WIDTH-1:0] mem_data_out,
	output wire [WIDTH-1:0] mem_data_in
);

parameter WIDTH = `MEMORY_WIDTH;

////////////////////////
//                    //
//       Global       //
//                    //
////////////////////////

wire hzd_stall;

fwdcontrol fwdcontrol (
	.rs(id_instr[25:21]),
	.rt(id_instr[20:16]),
	.ex_dst(ex_wreg),
	.mem_dst(mem_wreg),
	.wb_dst(wb_wreg),
	.ex_rw(ex_regwrite & !ex_memtoreg),
	.mem_rw(mem_regwrite),
	.wb_rw(wb_regwrite),
	.ctrl_rs(fwdctrl_rs),
	.ctrl_rt(fwdctrl_rt)
);

hzdcontrol hzdcontrol (
	.rt(dst_rt),
	.memtoreg(ex_memtoreg),
	.instr_top(id_instr[31:16]),
	.stall(hzd_stall)
);

wire ic_hit;
wire dc_hit;

wire ic_read_req;
wire ic_read_ack;
wire [31:0] ic_read_addr;
wire [WIDTH-1:0] ic_read_data;
wire dc_read_req;
wire dc_read_ack;
wire [31:0] dc_read_addr;
wire [WIDTH-1:0] dc_read_data;
wire dc_wrdirectite_req;
wire dc_write_ack;
wire [31:0] dc_write_addr;
wire [WIDTH-1:0] dc_write_data;

arbiter arbiter (
	.clk(clk),
	.reset(reset),
	.ic_read_req(ic_read_req),
	.ic_read_ack(ic_read_ack),
	.ic_read_addr(ic_read_addr),
	.ic_read_data(ic_read_data),
	.dc_read_req(dc_read_req),
	.dc_read_ack(dc_read_ack),
	.dc_read_addr(dc_read_addr),
	.dc_read_data(dc_read_data),
	.dc_write_req(dc_write_req),
	.dc_write_ack(dc_write_ack),
	.dc_write_addr(dc_write_addr),
	.dc_write_data(dc_write_data),
	.mem_enable(mem_enable),
	.mem_rw(mem_rw),
	.mem_ack(mem_ack),
	.mem_addr(mem_addr),
	.mem_data_in(mem_data_in),
	.mem_data_out(mem_data_out)
);

// Signals for reset and enable
wire ic_stall = ~ic_hit;
wire dc_stall = dc_enable & ~dc_hit;

wire pc_stall = ic_stall | dc_stall | hzd_stall;
wire pc_we = ~pc_stall | ex_isjump | pc_take_branch;
wire pc_reset = reset;

wire if_id_stall = dc_stall | hzd_stall;
wire if_id_flush = ic_stall | ex_isjump | pc_take_branch;
wire if_id_we = ~if_id_stall;
wire if_id_reset = reset | (if_id_flush & ~if_id_stall);

wire id_ex_stall = dc_stall;
wire id_ex_flush = ex_isjump | pc_take_branch | hzd_stall;
wire id_ex_we = ~id_ex_stall;
wire id_ex_reset = reset | (id_ex_flush & ~id_ex_stall);

wire ex_mem_stall = dc_stall;
wire ex_mem_flush = pc_take_branch;
wire ex_mem_we = ~ex_mem_stall;
wire ex_mem_reset = reset | (ex_mem_flush & ~ex_mem_stall);

wire mem_wb_flush = dc_stall;
wire mem_wb_we = 1'b1;
wire mem_wb_reset = reset | mem_wb_flush;

////////////////////////
//                    //
// Instruction Fetch  //
//                    //
////////////////////////

wire [31:0] if_pc_next;
wire [31:0] if_instr;
wire [31:0] pc_in;
wire [31:0] pc_interm;
wire [31:0] pc_out;

assign if_pc_next = pc_out + 4;

assign pc_interm = ex_isjump ? dst_jump : if_pc_next;
assign pc_in = pc_take_branch ? mem_pc_branch : pc_interm;

flipflop #(
	.N(32),
	.INIT(32'h0)
) pc (
	.clk(clk),
	.reset(pc_reset),
	.we(pc_we),
	.in(pc_in),
	.out(pc_out)
);

`ifdef NO_CACHE
assign ic_write_req = 1'b0;
assign ic_read_req = 1'b0;

assign ic_hit = 1'b1;

memory_sync #(
	.ALIAS("I-Memory")
) imem (
	.clk(~clk),
	.reset(reset),
	.addr(pc_out),
	.data_out(if_instr),
	.master_enable(1'b1),
	.read_write(1'b1)
);
`else
cache_direct #(
	.ALIAS("I-Cache")
) icache (
	.clk(~clk),
	.reset(reset),
	.addr(pc_out),
	.data_out(if_instr),
	.master_enable(1'b1),
	.read_write(1'b1),
	.hit(ic_hit),
	// Memory ports
	.mem_read_req(ic_read_req),
	.mem_read_addr(ic_read_addr),
	.mem_read_data(ic_read_data),
	.mem_read_ack(ic_read_ack)
);
`endif

flipflop #(.N(64)) if_id (
	.clk(clk),
	.reset(if_id_reset),
	.we(if_id_we),
	.in({if_pc_next, if_instr}),
	.out({id_pc_next, id_instr})
);

////////////////////////
//                    //
// Instruction Decode //
//                    //
////////////////////////

wire [31:0] id_instr;
wire [31:0] id_pc_next;
wire id_regwrite;
wire id_regdst;
wire id_memtoreg;
wire id_memread;
wire id_memwrite;
wire id_memtype;
wire id_isbranch;
wire id_aluop;
wire id_alusrc;
wire id_isjump;
wire id_islink;
wire id_jumpdst;
wire [31:0] id_imm;
wire [31:0] id_data_rs;
wire [31:0] id_data_rt;
wire [31:0] id_pc_jump;
wire [31:0] reg_rs;
wire [31:0] reg_rt;
wire [1:0] fwdctrl_rs;
wire [1:0] fwdctrl_rt;
assign id_imm = {{16{id_instr[15]}}, id_instr[15:0]};
assign id_pc_jump = {id_pc_next[31:28], id_instr[25:0], 2'b00};
 
control control (
	.opcode(id_instr[31:26]),
	.funct(id_instr[5:0]),
	.regdst(id_regdst),
	.isbranch(id_isbranch),
	.memread(id_memread),
	.memtoreg(id_memtoreg),
	.aluop(id_aluop),
	.memwrite(id_memwrite),
	.memtype(id_memtype),
	.alusrc(id_alusrc),
	.regwrite(id_regwrite),
	.isjump(id_isjump),
	.jumpdst(id_jumpdst),
	.islink(id_islink)
);

regfile regfile(
	.clk(clk),
	.reset(reset),
	.rreg1(id_instr[25:21]),
	.rreg2(id_instr[20:16]),
 	.rdata1(reg_rs),
	.rdata2(reg_rt),
	.regwrite(wb_regwrite),
	.wreg(wb_wreg),
	.wdata(wb_wdata)
);

multiplexer #(.X(4)) data_rs_mux (
	.select(fwdctrl_rs),
	.data_in({wb_wdata, mem_wdata, ex_exout, reg_rs}),
	.data_out(id_data_rs)
);

multiplexer #(.X(4)) data_rt_mux (
	.select(fwdctrl_rt),
	.data_in({wb_wdata, mem_wdata, ex_exout, reg_rt}),
	.data_out(id_data_rt)
);

flipflop #(.N(225)) id_ex (
	.clk(clk),
	.reset(id_ex_reset),
	.we(id_ex_we),
	.in({id_regwrite, id_memtoreg, id_memread, id_memwrite, id_memtype, id_isbranch,
        	id_regdst, id_aluop, id_alusrc, id_isjump, id_islink, id_jumpdst,
        	id_pc_next, id_data_rs, id_data_rt, id_imm, id_instr[31:26],
			id_pc_jump, id_instr[20:16], id_instr[15:11], id_instr[25:21], id_instr}),
	.out({ex_regwrite, ex_memtoreg, ex_memread, ex_memwrite, ex_memtype, ex_isbranch,
        	ex_regdst, ex_aluop, ex_alusrc, ex_isjump, ex_islink, ex_jumpdst,
        	ex_pc_next, ex_data_rs, ex_data_rt, ex_imm_top, ex_funct, ex_opcode,
			ex_pc_jump, dst_rt, dst_rd, dst_rs, ex_instr})
);

////////////////////////
//                    //
//      Execute       //
//                    //
////////////////////////

wire [31:0] ex_instr;
wire ex_regwrite;
wire ex_memtoreg;
wire ex_memread;
wire ex_memwrite;
wire ex_memtype;
wire ex_isbranch;
wire ex_regdst;
wire ex_aluop;
wire [3:0] aluop;
wire ex_alusrc;
wire ex_isjump;
wire ex_islink;
wire ex_jumpdst;
wire [31:0] dst_jump;
wire [31:0] ex_pc_next;
wire [31:0] ex_data_rs;
wire [31:0] ex_data_rt;
wire [31:0] ex_imm;
wire [25:0] ex_imm_top;
wire [31:0] ex_pc_jump;
wire [4:0] dst_rt;
wire [4:0] dst_rd;
wire [4:0] dst_rs;
wire [4:0] dst_reg;
wire [4:0] ex_wreg;
wire ex_aluz;
wire ex_aluovf;
wire [31:0] alures;
wire [31:0] ex_exout;
wire [31:0] data_t;
wire [31:0] ex_pc_branch;
wire [5:0] ex_opcode;
wire [5:0] ex_funct;

assign ex_imm = {ex_imm_top, ex_funct};

assign ex_pc_branch = ex_pc_next + (ex_imm << 2);

assign dst_jump = ex_jumpdst ? ex_data_rs : ex_pc_jump;

alucontrol alucontrol(
	.funct(ex_funct),
	.opcode(ex_opcode),
	.aluop_in(ex_aluop),
	.aluop_out(aluop)
);

assign data_t = ex_alusrc ? ex_imm : ex_data_rt;

alu alu(
	.aluop(aluop),
	.s(ex_data_rs),
	.t(data_t),
	.shamt(ex_imm[10:6]),
	.zero(ex_aluz),
	.overflow(ex_aluovf),
	.out(alures)
);

assign ex_exout = ex_islink ? ex_pc_next : alures;
assign dst_reg = ex_regdst ? dst_rd : dst_rt;
assign ex_wreg = ex_islink ? 5'h1f : dst_reg;

flipflop #(.N(141)) ex_mem (
	.clk(clk),
	.reset(ex_mem_reset),
	.we(ex_mem_we),
	.in({ex_regwrite, ex_memtoreg, ex_memread, ex_memwrite, ex_memtype,
        	ex_isbranch, ex_pc_branch,  ex_aluovf, ex_aluz,
        	ex_exout, ex_data_rt, ex_wreg, ex_instr}),
	.out({mem_regwrite, mem_memtoreg, mem_memread, mem_memwrite, mem_memtype,
        	mem_isbranch,  mem_pc_branch, mem_aluovf, mem_aluz,
        	mem_exout, mem_data_rt, mem_wreg, mem_instr})
);

////////////////////////
//                    //
//       Memory       //
//                    //
////////////////////////

wire [31:0] mem_pc_branch;
wire [31:0] mem_instr;
wire mem_regwrite;
wire mem_memtoreg;
wire mem_memread;
wire mem_memwrite;
wire mem_memtype;
wire mem_isbranch;
wire mem_aluz;
wire mem_aluovf;
wire [31:0] mem_exout;
wire [31:0] mem_data_rt;
wire [31:0] mem_memout;
wire [4:0] mem_wreg;
wire [31:0] mem_wdata;
wire pc_take_branch;

assign pc_take_branch = mem_isbranch & mem_aluz;

wire io_mem;
assign io_mem = & mem_exout[31:26]; // IO when 0xFF....
wire dc_enable = (mem_memwrite | mem_memread) & ~io_mem;
wire [31:0] io_out;
wire [31:0] mem_out_int;
wire [31:0] mem_out;

stdio stdio(
	.clk(~clk),
	.reset(reset),
	.addr(mem_exout[7:0]),
	.data_out(io_out),
	.data_in(mem_data_rt),
	.enable((mem_memwrite | mem_memread) & io_mem),
	.read_write(mem_memread)
);

wire [1:0] mem_offset = mem_exout[1:0];
reg [3:0] mem_byte_enable_int;

always @* case (mem_offset)
	2'b00: mem_byte_enable_int <= 4'b0001;
	2'b00: mem_byte_enable_int <= 4'b0001;
	2'b00: mem_byte_enable_int <= 4'b0001;
	2'b00: mem_byte_enable_int <= 4'b0001;
endcase

wire [3:0] mem_byte_enable = mem_memtype ? 4'b1111 : mem_byte_enable_int;

`ifdef NO_CACHE
assign dc_write_req = 1'b0;
assign dc_read_req = 1'b0;

assign dc_hit = 1'b1;

memory_sync #(
	.ALIAS("D-Memory")
) dmem (
	.clk(~clk),
	.reset(reset),
	.addr(mem_exout),
	.data_out(mem_out_int),
	.data_in(mem_data_rt),
	.master_enable(dc_enable),
	.read_write(mem_memread),
	.byte_enable(mem_byte_enable)
);
`else
cache_direct #(
	.ALIAS("D-Cache")
) dcache (
	.clk(~clk),
	.reset(reset),
	.addr(mem_exout),
	.data_out(mem_out_int),
	.data_in(mem_data_rt),
	.master_enable(dc_enable),
	.read_write(mem_memread),
	.byte_enable(mem_byte_enable),
	.hit(dc_hit),
	// Memory ports
	.mem_write_req(dc_write_req),
	.mem_write_addr(dc_write_addr),
	.mem_write_data(dc_write_data),
	.mem_write_ack(dc_write_ack),
	.mem_read_req(dc_read_req),
	.mem_read_addr(dc_read_addr),
	.mem_read_data(dc_read_data),
	.mem_read_ack(dc_read_ack)
);
`endif

assign mem_out = mem_memtype ? mem_out_int : {24'h000000, mem_out_int[(mem_exout[1:0]+1)*8-1-:8]};
assign mem_memout = io_mem ? io_out : mem_out;
assign mem_wdata = mem_memtoreg ? mem_memout : mem_exout;

flipflop #(.N(70)) mem_wb (
	.clk(clk),
	.reset(mem_wb_reset),
	.we(mem_wb_we),
	.in({mem_regwrite, mem_wdata, mem_wreg, mem_instr}),
	.out({wb_regwrite, wb_wdata, wb_wreg, wb_instr})
);


////////////////////////
//                    //
//     Write back     //
//                    //
////////////////////////

wire [31:0] wb_instr;
wire wb_regwrite;
wire [31:0] wb_wdata;
wire [4:0] wb_wreg;

//
//          /\_/\
//     ____/ o o \
//   /~____  =ø= /
//  (______)__m_m)
// 

endmodule

`endif
