`ifndef _cpu
`define _cpu

`include "flipflop.v"
`include "cache_direct.v"
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
`include "coprocessor.v"
`include "pc.v"
`include "branchpredictor.v"

// Central Processing Unit
module cpu(
	input wire clk,
	input wire reset,
	// Memory ports
	output wire mem_enable,
	output wire mem_rw,
	input wire mem_ack,
	output wire [31:0]  mem_addr,
	input wire [BWDITH-1:0] mem_data_out,
	output wire [BWDITH-1:0] mem_data_in
);

parameter BWDITH = `MEMORY_WIDTH;

////////////////////////
//                    //
//  Instrumentation   //
//                    //
////////////////////////

// see: perf list
integer perf_cycles              = 0;
integer perf_instructions        = 0;
integer perf_branches            = 0;
integer perf_branch_misses       = 0;
integer perf_dcache_loads        = 0;
integer perf_dcache_load_misses  = 0;
integer perf_dcache_stores       = 0;
integer perf_dcache_store_misses = 0;
integer perf_icache_load_misses  = 0;
integer perf_dTLB_loads          = 0;
integer perf_dTLB_load_misses    = 0;
integer perf_dTLB_stores         = 0;
integer perf_dTLB_store_misses   = 0;
integer perf_iTLB_loads          = 0;
integer perf_iTLB_load_misses    = 0;

real IPC;
always @(posedge io_exit) begin
`ifdef INSTRUMENT
	$display("[perf] cycles:              %d", perf_cycles);
	$display("[perf] instructions:        %d", perf_instructions);
	$display("[perf] branches:            %d", perf_branches);
	$display("[perf] branch_misses:       %d", perf_branch_misses);
	$display("[perf] dcache_loads:        %d", perf_dcache_loads);
	$display("[perf] dcache_load_misses:  %d", perf_dcache_load_misses);
	$display("[perf] dcache_stores:       %d", perf_dcache_stores);
	$display("[perf] dcache_store_misses: %d", perf_dcache_store_misses);
	$display("[perf] icache_load_misses:  %d", perf_icache_load_misses);
	$display("[perf] dTLB_loads:          %d", perf_dTLB_loads);
	$display("[perf] dTLB_load_misses:    %d", perf_dTLB_load_misses);
	$display("[perf] dTLB_stores:         %d", perf_dTLB_stores);
	$display("[perf] dTLB_store_misses:   %d", perf_dTLB_store_misses);
	$display("[perf] iTLB_loads:          %d", perf_iTLB_loads);
	$display("[perf] iTLB_load_misses:    %d", perf_iTLB_load_misses);
    // Additional
    IPC = perf_instructions;
    IPC = IPC/perf_cycles;
    $display("[perf] IPC:                    %f", IPC);
`endif
	$finish;
end


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
wire [BWDITH-1:0] ic_read_data;
wire dc_read_req;
wire dc_read_ack;
wire [31:0] dc_read_addr;
wire [BWDITH-1:0] dc_read_data;
wire dc_wrdirectite_req;
wire dc_write_ack;
wire [31:0] dc_write_addr;
wire [BWDITH-1:0] dc_write_data;

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

reg pc_reset = 1'b0;
reg pc_we = 1'b1;

reg if_id_reset = 1'b0;
reg if_id_we = 1'b1;

reg id_ex_reset = 1'b0;
reg id_ex_we = 1'b1;

reg ex_mem_reset = 1'b0;
reg ex_mem_we = 1'b1;

reg mem_wb_reset = 1'b0;
reg mem_wb_we = 1'b1;

//TODO Optimize, maybe
always @* begin
	if (reset) begin
		pc_reset     <= 1'b1;
		pc_we        <= 1'b1;
		if_id_reset  <= 1'b1;
		if_id_we     <= 1'b1;
		id_ex_reset  <= 1'b1;
		id_ex_we     <= 1'b1;
		ex_mem_reset <= 1'b1;
		ex_mem_we    <= 1'b1;
		mem_wb_reset <= 1'b1;
		mem_wb_we    <= 1'b1;
    end else if (bp_misspredicted) begin
		pc_reset     <= 1'b0;
		pc_we        <= 1'b1;
		if_id_reset  <= 1'b1;
		if_id_we     <= 1'b1;
		id_ex_reset  <= 1'b1;
		id_ex_we     <= 1'b1;
		ex_mem_reset <= 1'b1;
		ex_mem_we    <= 1'b1;
		mem_wb_reset <= 1'b0;
		mem_wb_we    <= 1'b1;
	end else if (cop_reset) begin
		pc_reset     <= 1'b0;
		pc_we        <= 1'b1;
		if_id_reset  <= 1'b1;
		if_id_we     <= 1'b1;
		id_ex_reset  <= 1'b1;
		id_ex_we     <= 1'b1;
		ex_mem_reset <= 1'b1;
		ex_mem_we    <= 1'b1;
		mem_wb_reset <= 1'b1;
		mem_wb_we    <= 1'b1;
	end else if (dc_stall) begin
		pc_reset     <= 1'b0;
		pc_we        <= 1'b0;
		if_id_reset  <= 1'b0;
		if_id_we     <= 1'b0;
		id_ex_reset  <= 1'b0;
		id_ex_we     <= 1'b0;
		ex_mem_reset <= 1'b0;
		ex_mem_we    <= 1'b0;
		mem_wb_reset <= 1'b1;
		mem_wb_we    <= 1'b1;
	end else if (pc_take_branch & ~mem_bp_opinion) begin //~if_bp_opinion &
		pc_reset     <= 1'b0;
		pc_we        <= 1'b1;
		if_id_reset  <= 1'b1;
		if_id_we     <= 1'b1;
		id_ex_reset  <= 1'b1;
		id_ex_we     <= 1'b1;
		ex_mem_reset <= 1'b1;
		ex_mem_we    <= 1'b1;
		mem_wb_reset <= 1'b0;
		mem_wb_we    <= 1'b1;
	end else if (ex_isjump | ex_exc_ret) begin
		pc_reset     <= 1'b0;
		pc_we        <= 1'b1;
		if_id_reset  <= 1'b1;
		if_id_we     <= 1'b1;
		id_ex_reset  <= 1'b1;
		id_ex_we     <= 1'b1;
		ex_mem_reset <= 1'b0;
		ex_mem_we    <= 1'b1;
		mem_wb_reset <= 1'b0;
		mem_wb_we    <= 1'b1;
	end else if (hzd_stall) begin
		pc_reset     <= 1'b0;
		pc_we        <= 1'b0;
		if_id_reset  <= 1'b0;
		if_id_we     <= 1'b0;
		id_ex_reset  <= 1'b1;
		id_ex_we     <= 1'b1;
		ex_mem_reset <= 1'b0;
		ex_mem_we    <= 1'b1;
		mem_wb_reset <= 1'b0;
		mem_wb_we    <= 1'b1;
	end else if (ic_stall) begin
		pc_reset     <= 1'b0;
		pc_we        <= 1'b0;
		if_id_reset  <= 1'b1;
		if_id_we     <= 1'b1;
		id_ex_reset  <= 1'b0;
		id_ex_we     <= 1'b1;
		ex_mem_reset <= 1'b0;
		ex_mem_we    <= 1'b1;
		mem_wb_reset <= 1'b0;
		mem_wb_we    <= 1'b1;
	end else begin
		pc_reset     <= 1'b0;
		pc_we        <= 1'b1;
		if_id_reset  <= 1'b0;
		if_id_we     <= 1'b1;
		id_ex_reset  <= 1'b0;
		id_ex_we     <= 1'b1;
		ex_mem_reset <= 1'b0;
		ex_mem_we    <= 1'b1;
		mem_wb_reset <= 1'b0;
		mem_wb_we    <= 1'b1;
	end
end

////////////////////////
//                    //
// Instruction Fetch  //
//                    //
////////////////////////

wire if_bp_opinion;
wire if_bp_btaken;
wire bp_fenable;
wire bp_fbtaken;
wire bp_misspredicted;
wire [31:0] if_bp_addr;
wire [31:0] if_pc_next;
wire if_user_mode;
wire [31:0] if_instr;
wire [31:0] pc_in;
wire [31:0] pc_real;
wire [31:0] pc_interm;
wire [31:0] pc_out;
wire [31:0] pc_kernel;
wire [31:0] bp_fcurrent;
wire [31:0] bp_fbaddr;
wire [31:0] bp_misspredicted_addr;

branchpredictor branchpredictor(
    .clk(clk),
    .reset(reset),
    .current_pc(pc_out),
    .feedback_enable(mem_isbranch),
    .feedback_branch_taken(mem_aluz),
    .feedback_branch_addr(mem_pc_branch),
    .feedback_current_pc(mem_pc_next - 4),
    .branch_addr(if_bp_addr),
    .branch_taken(if_bp_btaken),
    .opinion(if_bp_opinion)
);

assign if_pc_next = pc_out + 4;
assign bp_misspredicted_addr = mem_bp_btaken ? mem_pc_next : mem_pc_branch ;
assign bp_misspredicted = mem_bp_opinion & mem_isbranch &
                          ((~mem_aluz & mem_bp_btaken) | (mem_aluz & ~mem_bp_btaken));

pc pc(
    .clk(clk),
    .reset(pc_reset),
    .we(pc_we),
    .is_jump(ex_isjump),
    .is_kernel(cop_reset),
    .is_branch(pc_take_branch & ~mem_bp_opinion),
    .is_eret(ex_exc_ret),
    .is_bpredictor(if_bp_opinion & if_bp_btaken),
    .is_misspred(bp_misspredicted),
    .dst_nextpc(if_pc_next),
    .dst_jump(dst_jump),
    .dst_branch(mem_pc_branch),
    .dst_kernel(address_kernel),
    .dst_eret(epc),
    .dst_prediction(if_bp_addr),
    .dst_misspred(bp_misspredicted_addr),
    .initial_pc(32'd0),
    .pc_out(pc_out)
);

`ifdef NO_CACHE
assign ic_write_req = 1'b0;
assign ic_read_req = 1'b0;

assign ic_hit = 1'b1;

memory_sync #(
	.ALIAS("imem")
) imem (
	.clk(clk),
	.reset(reset),
	.addr(pc_out),
	.data_out(if_instr),
	.master_enable(1'b1),
	.write_enable(1'b0),
	.byte_enable(1'b0)
);
`else
cache_direct #(
	.ALIAS("icache")
) icache (
	.clk(clk),
	.reset(reset),
	.addr(pc_out),
	.data_out(if_instr),
	.data_in(0),
	.master_enable(1'b1),
	.write_enable(1'b0),
	.byte_enable(1'b0),
	.hit(ic_hit),
	// Memory ports
	.mem_read_req(ic_read_req),
	.mem_read_addr(ic_read_addr),
	.mem_read_data(ic_read_data),
	.mem_read_ack(ic_read_ack)
);
`endif

// Insert 1'b1 as valid here, this will flow through the pipeline
flipflop #(.N(100)) if_id (
	.clk(clk),
	.reset(if_id_reset | reset),
	.we(if_id_we),
	.in({
		if_pc_next, if_instr, if_user_mode, 1'b1,
		if_bp_opinion, if_bp_btaken, if_bp_addr
	}),
	.out({
		id_pc_next, id_instr, id_user_mode, id_isvalid,
		id_bp_opinion, id_bp_btaken, id_bp_addr
	})
);

////////////////////////
//                    //
// Instruction Decode //
//                    //
////////////////////////

wire id_bp_opinion;
wire id_bp_btaken;
wire [31:0] id_bp_addr;
wire [31:0] id_instr;
wire [31:0] id_pc_next;
wire id_regwrite;
wire id_regdst;
wire id_memtoreg;
wire id_memread;
wire id_memwrite;
wire id_membyte;
wire id_isbranch;
wire id_isjump;
wire id_islink;
wire id_jumpdst;
wire id_aluop;
wire id_alu_s;
wire id_alu_t;
wire id_exc_ri;
wire id_exc_sys;
wire id_cowrite;
wire id_codst;
wire id_isvalid;
wire [31:0] id_imm;
wire [31:0] id_data_rs;
wire [31:0] id_data_rt;
wire [31:0] id_pc_jump;
wire [31:0] reg_rs;
wire [31:0] reg_rt;
wire [31:0] id_data_co;
wire [31:0] epc;
wire [1:0] fwdctrl_rs;
wire [1:0] fwdctrl_rt;
wire cop_reset;
wire id_user_mode;
wire [31:0] address_kernel;
wire id_exc_ret;

assign id_imm = {{16{id_instr[15]}}, id_instr[15:0]};
assign id_pc_jump = {id_pc_next[31:28], id_instr[25:0], 2'b00};

control control (
	// Inputs
	.opcode(id_instr[31:26]),
	.funct(id_instr[5:0]),
	.user_mode(id_user_mode),
	// Execute
	.alu_s(id_alu_s),
	.alu_t(id_alu_t),
	.aluop(id_aluop),
	.regdst(id_regdst),
	.isjump(id_isjump),
	.jumpdst(id_jumpdst),
	.islink(id_islink),
	.exc_ret(id_exc_ret),
	// Memory
	.isbranch(id_isbranch),
	.memread(id_memread),
	.memtoreg(id_memtoreg),
	.memwrite(id_memwrite),
	.membyte(id_membyte),
	// Write back
	.regwrite(id_regwrite),
	.cowrite(id_cowrite),
	// Exceptions
	.exc_sys(id_exc_sys),
	.exc_ri(id_exc_ri)
);

regfile regfile(
	.clk(clk),
	.reset(reset),
	.enable(wb_regwrite),

	.rreg1(id_instr[25:21]),
	.rreg2(id_instr[20:16]),
 	.rdata1(reg_rs),
	.rdata2(reg_rt),
	.wreg(wb_wreg),
	.wdata(wb_wdata)
);

coprocessor coprocessor(
	.clk(clk),
	.reset(reset),
	.enable(wb_cowrite),

	.rreg(id_instr[25:21]),
	.wreg(wb_wreg),
	.rdata(id_data_co),
	.wdata(wb_wdata),

	.int_ext(wb_exc_ext),
	.int_tr(wb_exc_tr),
	.int_ovf(wb_exc_ovf),
	.int_ri(wb_exc_ri),
	.int_sys(wb_exc_sys),
	.int_addrs(wb_exc_st),
	.int_addrl(wb_exc_ld),
	.int_tlbs(0),
	.int_tlbl(0),

	.epc_in(wb_pc_next),
	.badvaddr_in(wb_bad_vaddr),

	.pc_kernel(address_kernel),
	.cop_reset(cop_reset),

	.user_mode(if_user_mode),
	.epc_out(epc)
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

flipflop #(.N(299)) id_ex (
	.clk(clk),
	.reset(id_ex_reset | reset),
	.we(id_ex_we),
	.in({
		// General
		id_instr, id_pc_next, id_user_mode, id_isvalid,
		id_exc_sys, id_exc_ri,
		// Execute
		id_alu_s, id_alu_t, id_aluop, id_regdst, id_codst,
		id_isjump, id_jumpdst, id_islink, id_exc_ret,
		id_pc_jump, id_data_rs, id_data_rt, id_data_co,
		id_imm,
		id_instr[31:26], id_instr[25:21], id_instr[20:16], id_instr[15:11],
		// Memory
		id_isbranch,
		id_memread, id_memwrite, id_memtoreg, id_membyte,
		// Write back
		id_regwrite, id_cowrite,
		// Branch predicotr,
		id_bp_opinion, id_bp_btaken, id_bp_addr
	}),
	.out({
		// General
		ex_instr, ex_pc_next, ex_user_mode, ex_isvalid,
		ex_exc_sys, ex_exc_ri,
		// Execute
		ex_alu_s, ex_alu_t, ex_aluop, ex_regdst, ex_codst,
		ex_isjump, ex_jumpdst, ex_islink, ex_exc_ret,
		ex_pc_jump, ex_data_rs, ex_data_rt, ex_data_co,
		ex_imm_top, ex_funct,
		ex_opcode, dst_rs, dst_rt, dst_rd,
		// Memory
		ex_isbranch,
		ex_memread, ex_memwrite, ex_memtoreg, ex_membyte,
		// Write back
		ex_regwrite, ex_cowrite,
		// Branch predictor
		ex_bp_opinion, ex_bp_btaken, ex_bp_addr
	})
);

////////////////////////
//                    //
//      Execute       //
//                    //
////////////////////////

wire ex_bp_opinion;
wire ex_bp_btaken;
wire [31:0] ex_bp_addr;
wire [31:0] ex_instr;
wire ex_regwrite;
wire ex_memtoreg;
wire ex_memread;
wire ex_memwrite;
wire ex_membyte;
wire ex_isbranch;
wire ex_regdst;
wire ex_aluop;
wire ex_isjump;
wire ex_islink;
wire ex_jumpdst;
wire [4:0] aluop;
wire ex_alu_s;
wire ex_alu_t;
wire ex_exc_ri;
wire ex_exc_sys;
wire ex_cowrite;
wire ex_codst;
wire ex_exc_ret;
wire ex_isvalid;
wire ex_user_mode;
wire [31:0] dst_jump;
wire [31:0] ex_pc_next;
wire [31:0] ex_data_rs;
wire [31:0] ex_data_rt;
wire [31:0] ex_imm;
wire [25:0] ex_imm_top;
wire [31:0] ex_pc_jump;
wire [31:0] ex_data_co;
wire [4:0] dst_rt;
wire [4:0] dst_rd;
wire [4:0] dst_rs;
wire [4:0] dst_reg;
wire [4:0] dst_rs_rt;
wire [4:0] ex_wreg;
wire ex_aluz;
wire ex_exc_ov;
wire [31:0] alures;
wire [31:0] ex_exout;
wire [31:0] data_s;
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

assign data_s = ex_alu_s ? ex_data_co : ex_data_rs;
assign data_t = ex_alu_t ? ex_imm : ex_data_rt;

alu alu(
	.aluop(aluop),
	.s(data_s),
	.t(data_t),
	.shamt(ex_imm[10:6]),
	.zero(ex_aluz),
	.overflow(ex_exc_ov),
	.out(alures)
);

assign ex_exout = ex_islink ? ex_pc_next : alures;
assign dst_reg = ex_regdst ? dst_rd : dst_rt;
assign ex_wreg = ex_islink ? 5'd31 : dst_reg;

flipflop #(.N(217)) ex_mem (
	.clk(clk),
	.reset(ex_mem_reset | reset),
	.we(ex_mem_we),
	.in({
		// General
		ex_instr, ex_pc_next, ex_user_mode, ex_isvalid,
		ex_exc_sys, ex_exc_ri, ex_exc_ov,
		// Memory
		ex_isbranch, ex_aluz, ex_pc_branch,
		ex_memread, ex_memwrite, ex_memtoreg, ex_membyte,
		ex_exout, ex_data_rt,
		// Write back
		ex_regwrite, ex_cowrite, ex_wreg,
		// Branch predictor
		ex_bp_opinion, ex_bp_btaken, ex_bp_addr, aluop
	}),
	.out({
		// General
		mem_instr, mem_pc_next, mem_user_mode, mem_isvalid,
		mem_exc_sys, mem_exc_ri, mem_exc_ov,
		// Memory
		mem_isbranch, mem_aluz, mem_pc_branch,
		mem_memread, mem_memwrite, mem_memtoreg, mem_membyte,
		mem_exout, mem_data_rt,
		// Write back
		mem_regwrite, mem_cowrite, mem_wreg,
		// Branch predictor
		mem_bp_opinion, mem_bp_btaken, mem_bp_addr, mem_aluop
	})
);

////////////////////////
//                    //
//       Memory       //
//                    //
////////////////////////

wire [4:0] mem_aluop;
wire mem_bp_opinion;
wire mem_bp_btaken;
wire [31:0] mem_bp_addr;
wire [31:0] mem_pc_branch;
wire [31:0] mem_instr;
wire mem_regwrite;
wire mem_memtoreg;
wire mem_memread;
wire mem_memwrite;
wire mem_membyte;
wire mem_isbranch;
wire mem_aluz;
wire mem_exc_ov;
wire mem_exc_ri;
wire mem_exc_sys;
wire mem_cowrite;
wire mem_isvalid;
wire mem_user_mode;
wire [31:0] mem_pc_next;
wire [31:0] mem_exout;
wire [31:0] mem_data_rt;
wire [31:0] mem_memout;
wire [4:0] mem_wreg;
wire [31:0] mem_wdata;

wire pc_take_branch = mem_isbranch & mem_aluz;

wire io_enable = & mem_exout[31:24]; // IO when 0xFF....
wire dc_enable = (mem_memwrite | mem_memread) & ~io_enable;
wire [31:0] io_out;
wire [31:0] mem_out;
wire io_exit;

wire mem_exc_st = io_enable & mem_user_mode & mem_memwrite;
wire mem_exc_ld = io_enable & mem_user_mode & mem_memread;

stdio stdio(
	.clk(clk),
	.reset(reset),
	.addr(mem_exout[7:0]),
	.data_out(io_out),
	.data_in(mem_data_rt),
	.enable((mem_memwrite | mem_memread) & io_enable & ~mem_user_mode),
	.read_write(mem_memread),
	.exit(io_exit)
);

`ifdef NO_CACHE
assign dc_write_req = 1'b0;
assign dc_read_req = 1'b0;

assign dc_hit = 1'b1;

memory_sync #(
	.ALIAS("dmem")
) dmem (
	.clk(clk),
	.reset(reset),
	.addr(mem_exout),
	.data_out(mem_out),
	.data_in(mem_data_rt),
	.master_enable(dc_enable),
	.write_enable(mem_memwrite),
	.byte_enable(mem_membyte)
);
`else
cache_direct #(
	.ALIAS("dcache")
) dcache (
	.clk(clk),
	.reset(reset),
	.addr(mem_exout),
	.data_out(mem_out),
	.data_in(mem_data_rt),
	.master_enable(dc_enable),
	.write_enable(mem_memwrite),
	.byte_enable(mem_membyte),
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

assign mem_memout = io_enable ? io_out : mem_out;
assign mem_wdata = mem_memtoreg ? mem_memout : mem_exout;

flipflop #(.N(142)) mem_wb (
	.clk(clk),
	.reset(mem_wb_reset | reset),
	.we(mem_wb_we),
	.in({
		// General
		mem_instr, mem_pc_next, mem_user_mode, mem_isvalid,
		mem_exc_sys, mem_exc_ri, mem_exc_ov,
		mem_exc_ld, mem_exc_st, mem_exout,
		// Write back
		mem_regwrite, mem_cowrite, mem_wreg, mem_wdata
	}),
	.out({
		// General
		wb_instr, wb_pc_next, wb_user_mode, wb_isvalid,
		wb_exc_sys, wb_exc_ri, wb_exc_ov,
		wb_exc_ld, wb_exc_st, wb_bad_vaddr,
		// Write back
		wb_regwrite, wb_cowrite, wb_wreg, wb_wdata
	})
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
wire [31:0] wb_pc_next;
wire [31:0] wb_bad_vaddr;
wire wb_user_mode;
wire wb_exc_ov;
wire wb_exc_ri;
wire wb_exc_sys;
reg wb_exc_tr = 0;
wire wb_exc_st;
wire wb_exc_ld;
wire wb_cowrite;
wire wb_isvalid;

always @(posedge clk) if (reset) begin
	perf_cycles              <= 0;
	perf_instructions        <= 0;
	perf_branches            <= 0;
	perf_branch_misses       <= 0;
	perf_dcache_loads        <= 0;
	perf_dcache_load_misses  <= 0;
	perf_dcache_stores       <= 0;
	perf_dcache_store_misses <= 0;
	perf_icache_load_misses  <= 0;
	perf_dTLB_loads          <= 0;
	perf_dTLB_load_misses    <= 0;
	perf_dTLB_stores         <= 0;
	perf_dTLB_store_misses   <= 0;
	perf_iTLB_loads          <= 0;
	perf_iTLB_load_misses    <= 0;
	wb_exc_tr <= 0;
end else begin
	perf_cycles              <= perf_cycles              + 1;
	perf_instructions        <= perf_instructions        + wb_isvalid;
	perf_branches            <= perf_branches            + (mem_isbranch   | ex_isjump | ex_exc_ret);
	perf_branch_misses       <= perf_branch_misses       + (pc_take_branch | ex_isjump | ex_exc_ret); // <- Branch Predictor
	perf_dcache_loads        <= perf_dcache_loads        + (mem_memread  & dc_enable);
	perf_dcache_load_misses  <= perf_dcache_load_misses  + (mem_memread  & dc_stall);
	perf_dcache_stores       <= perf_dcache_stores       + (mem_memwrite & dc_enable);
	perf_dcache_store_misses <= perf_dcache_store_misses + (mem_memwrite & dc_stall);
	perf_icache_load_misses  <= perf_icache_load_misses  + ic_stall;
	perf_dTLB_loads          <= perf_dTLB_loads          + 0;
	perf_dTLB_load_misses    <= perf_dTLB_load_misses    + 0;
	perf_dTLB_stores         <= perf_dTLB_stores         + 0;
	perf_dTLB_store_misses   <= perf_dTLB_store_misses   + 0;
	perf_iTLB_loads          <= perf_iTLB_loads          + 0;
	perf_iTLB_load_misses    <= perf_iTLB_load_misses    + 0;
	wb_exc_tr <= perf_cycles >= `MAX_CYCLES;
end

//
//          /\_/\
//     ____/ o o \
//   /~____  =ø= /
//  (______)__m_m)
//

endmodule

`endif
