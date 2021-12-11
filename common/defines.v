// MIPS-C ISA
`define WORD_WIDTH  32
`define REG_ADDR_W  5
`define OP_WIDTH    6
`define ALUOP_WIDTH 6

`define ZERO_WORD   `WORD_WIDTH'b0
`define REG_ZERO    `REG_ADDR_W'b0

// OP codes
// I-type
`define LW      6'b100011
`define SW      6'b101011
`define BEQ     6'b000100
// R-type
`define R_R     6'b000000
// J-type
`define J       6'b000010

// ALU ops
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