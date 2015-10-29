/// How to screw up Calvin's doc-system:
/// Step 1: Create a new kind of verilog file
/// Step 2: ?????
/// Step 3: Profit!

parameter
    FN_SLL = 6'b000000,
    FN_SRL = 6'b000010,
    FN_SRA = 6'b000011,
    FN_ADD = 6'b100000,
    FN_SUB = 6'b100010,
    FN_AND = 6'b100100,
    FN_OR  = 6'b100101,
    FN_XOR = 6'b100110,
    FN_NOR = 6'b100111,
    FN_SLT = 6'b101010;

parameter 
    OP_AND = 4'b0000,
    OP_OR  = 4'b0001,
    OP_ADD = 4'b0010,
    OP_SLL = 4'b0100,
    OP_SUB = 4'b0110,
    OP_SLT = 4'b0111,
    OP_SRL = 4'b1000,
    OP_SRA = 4'b1001,
    OP_XOR = 4'b1010,
    OP_NOR = 4'b1100;
