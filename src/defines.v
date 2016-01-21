`ifndef _defines
`define _defines

// Functions

`define FN_ADD 6'h20
`define FN_SUB 6'h22
`define FN_AND 6'h24
`define FN_NOR 6'h27
`define FN_OR  6'h25
`define FN_XOR 6'h26
`define FN_SLL 6'h0
`define FN_SRL 6'h2
`define FN_SRA 6'h3
`define FN_SLT 6'h2a
`define FN_MUL 6'h18
`define FN_DIV 6'h1a
`define FN_JR  6'h8
`define FN_SYS 6'hc

// ALU operations

`define ALUOP_AND 5'h0
`define ALUOP_OR  5'h1
`define ALUOP_ADD 5'h2
`define ALUOP_NOR 5'h3
`define ALUOP_SLL 5'h4
`define ALUOP_SUB 5'h6
`define ALUOP_SLT 5'h7
`define ALUOP_SRL 5'h8
`define ALUOP_SRA 5'h9
`define ALUOP_XOR 5'ha
`define ALUOP_BEQ 5'hb
`define ALUOP_BNE 5'hc
`define ALUOP_LUI 5'hd
`define ALUOP_MUL 5'he
`define ALUOP_DIV 5'hf
`define ALUOP_MOV 5'h10

// Opcodes

`define OP_RTYPE 6'h0
`define OP_ADDI  6'h8
`define OP_ANDI  6'hc
`define OP_ORI   6'hd
`define OP_XORI  6'he
`define OP_SLTI  6'ha
`define OP_BEQ   6'h4
`define OP_BNE   6'h5
`define OP_J     6'h2
`define OP_LB    6'h20
`define OP_LUI   6'hf
`define OP_LW    6'h23
`define OP_SB    6'h28
`define OP_SW    6'h2b
`define OP_JAL   6'h3
`define OP_MFC0  6'h10
`define OP_MTC0  6'h11
`define OP_ERET  6'h12
`define OP_TLBWR 6'h13

// Coprocessor0

`define COP_INDEX     5'd0  // Index into the TLB array
`define COP_RANDOM    5'd1  // Randomly generated index into the TLB array
`define COP_ENTRYLO0  5'd2  //
`define COP_ENTRYLO1  5'd3  //
`define COP_CONTEXT   5'd4  // Pointer to page table entry in memory
`define COP_PAGEMASK  5'd5  // Control for variable page size in TLB entries
`define COP_WIRED     5'd6  //
//      Reserved      5'd7  // Reserved for future extensions
`define COP_BADVADDR  5'd8  //
`define COP_COUNT     5'd9  // Processor cycle count
`define COP_ENTRYHI   5'd10 // High-order portion of the TLB entry
`define COP_COMPARE   5'd11 // Timer interrupt control
`define COP_STATUS    5'd12 // Processor status and control
`define COP_CAUSE     5'd13 // Cause of last general exception
`define COP_EPC       5'd14 // Program counter at last exception
`define COP_PRID      5'd15 // Processor identification and revision
`define COP_CONFIG    5'd16 // Configuration register
`define COP_LLADDR    5'd17 // Load linked address
`define COP_WATCHLO   5'd18 // Watchpoint address
`define COP_WATCHHI   5'd19 // Watchpoint control
//      Reserved      5'd20 // XContext in 64-bit implementations
//      Reserved      5'd21 // Reserved for future extensions
`define COP_AVAILABLE 5'd22 // for implementation dependent use
`define COP_DEBUG     5'd23 // EJTAG Debug register
`define COP_DEPC      5'd24 //
`define COP_PERFCNT   5'd25 // Performance counter interface
`define COP_ERRCTL    5'd26 // Parity/ECC error control and status
`define COP_CACHEERR  5'd27 // Cache parity error control and status
`define COP_TAGLO     5'd28 // Low-order portion of cache tag interface
`define COP_DATALO    5'd28 // Low-order portion of cache data interface
`define COP_TAGHI     5'd29 // High-order portion of cache tag interface
`define COP_DATAHI    5'd29 // High-order portion of cache data interface
`define COP_ERROREPC  5'd30 // Program counter at last error
`define COP_DESAVE    5'd31 // EJTAG debug exception save register

// Coprocessor0 registers offsets

`define COP_STATUS_EXL 1 // Exception Level
`define COP_STATUS_UM  4 // User Mode

// Interrupts (*supported)

`define INT_EXT   0  // External interrupt
`define INT_MOD   1  // TLB Modification (write to ro section)
`define INT_TLBL  2  // TLB miss on load
`define INT_TLBS  3  // TLB miss on store
`define INT_ADDRL 4  // *Address error exception (load or instruction fetch)
`define INT_ADDRS 5  // *Address error exception (store)
`define INT_IBUS  6  // Bus error on instruction fetch
`define INT_DBUS  7  // Bus error on data load or store
`define INT_SYS   8  // *Syscall exception
`define INT_BKPT  9  // Breakpoint exception
`define INT_RI    10 // *Reserved instruction exception
`define INT_OVF   12 // *Arithmetic overflow exception
`define INT_TR    13 // *Trap exception

`define EXC_MSG_ADDRL "Address Load "
`define EXC_MSG_ADDRS "Address Store"
`define EXC_MSG_OVF   "Overflow     "
`define EXC_MSG_RI    "Reserved Inst"
`define EXC_MSG_SYS   "Syscall      "
`define EXC_MSG_TR    "Trap         "
`define EXC_MSG_EXT   "Ext Interrupt"
`define EXC_MSG_TLBL  "TLB Load     "
`define EXC_MSG_TLBS  "TLB Store    "
`define EXC_MSG_PANIC "Panic        "

// SYS IO

`define SYS_PRINT_CHAR  11
`define SYS_PRINT_INT    1
`define SYS_PRINT_FLOAT  2
`define SYS_READ_CHAR   12
`define SYS_READ_INT     5
`define SYS_READ_FLOAT   6
`define SYS_EXIT        10

`define IO_EXIT  8'hff
`define IO_CHAR  8'hfe
`define IO_INT   8'hfd
`define IO_FLOAT 8'hfc
`define IO_HEX   8'hfb

//Store buffer

`define STBUFF_DEPTH    5
`define TLB_ENTRIES    10
`define PAGE_SIZE    4096

// Debug macros
`ifdef DEBUG
	`define INFO(M) begin $write("%5t ", $time); $display M ; end
`else
	`define INFO(M) begin end
`endif

`define WARN(M) begin $write("%5t [warning] ", $time); $display M ; end

`define MEMORY_DATA "build/memory.raw"
`ifndef MEMORY_LATENCY
	`define MEMORY_LATENCY 27
`endif

`endif
