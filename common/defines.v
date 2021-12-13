// Debug and simulations
`define IMEM_SIM_FILE   "../../sim/imem.text"
`define DMEM_SIM_FILE   "../../sim/dmem.data"

// MIPS-C ISA
`define BYTE_WIDTH      8

`define WORD_WIDTH      32
`define WORD_INDEX_W    5
`define REG_ADDR_W      5
`define OP_WIDTH        6
`define FUNCT_WIDTH     6
`define J_ADDR_WIDTH    26
`define IMM_WIDTH       16

`define ZERO_WORD   `WORD_WIDTH'b0
`define REG_ZERO    `REG_ADDR_W'b0

// type encoding
`define ERR_T   2'b00
`define R_TYPE  2'b01
`define I_TYPE  2'b10
`define J_TYPE  2'b11

// ALU ops
`define ALUOP_WIDTH    4
`define ALU_ADD         `ALU_OP_WIDTH'd1
`define ALU_SUB         `ALU_OP_WIDTH'd2
`define ALU_MULT        `ALU_OP_WIDTH'd3
`define ALU_DIV         `ALU_OP_WIDTH'd4
`define ALU_SL          `ALU_OP_WIDTH'd5
`define ALU_ARITH_SR    `ALU_OP_WIDTH'd6
`define ALU_LOGIC_SR    `ALU_OP_WIDTH'd7
`define ALU_AND         `ALU_OP_WIDTH'd8
`define ALU_OR          `ALU_OP_WIDTH'd9
`define ALU_XOR         `ALU_OP_WIDTH'd10
`define ALU_NOR         `ALU_OP_WIDTH'd11

// OP codes
// I-type
`define LW      6'b100011
`define SW      6'b101011

`define BEQ     6'b000100
`define BNE     6'b000101

`define BLEZ    6'b000110
`define BGTZ    6'b000111
// OP code conflict, must decide with rt field
`define BGEZ_BLTZ   6'b000001
`define BGEZRT  5'b00001
`define BLTZRT  5'b00000

// R-type
`define R_R     6'b000000
// R-R type funct
`define ADD     6'b100000
`define ADDU    6'b100001
`define AND     6'b100100
`define DIV     6'b011010
`define DIVU    6'b011011
`define MULT    6'b011000
`define MULTU   6'b011001
`define NOR     6'b100111
`define OR      6'b100101
`define SLL     6'b000000
`define SLLV    6'b000100
`define SLT     6'b101010
`define SLTU    6'b101011
`define SRA     6'b000011
`define SRAV    6'b000111
`define SRL     6'b000010
`define SRLV    6'b000110
`define SUB     6'b100010
`define SUBU    6'b100011
`define XOR     6'b100110

// J-type
`define J       6'b000010