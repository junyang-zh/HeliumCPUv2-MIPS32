`include "defines.v"

module alu #(
    parameter W = `WORD_WIDTH
) (
    input wire[W-1:0] op1,
    input wire[W-1:0] op2,
    input wire[`ALUOP_WIDTH-1:0] alu_op,

    output reg[W-1:0] result
);
    // ALU is a combinational component; in MIPS, DIV/MUL are done by MDU
    always @(*) begin
        case (alu_op)
            `ALU_ADD:
                result <= op1 + op2;
            `ALU_SUB:
                result <= op1 - op2;
            `ALU_SL:
                result <= op1 << op2;
            `ALU_ARITH_SR:
                result <= op1 >>> op2;
            `ALU_LOGIC_SR:
                result <= op1 >> op2;
            `ALU_AND:
                result <= op1 & op2;
            `ALU_OR:
                result <= op1 | op2;
            `ALU_XOR:
                result <= op1 ^ op2;
            `ALU_NOR:
                result <= ~(op1 | op2);
            default: 
                result <= `ZERO_WORD;
        endcase
    end
endmodule