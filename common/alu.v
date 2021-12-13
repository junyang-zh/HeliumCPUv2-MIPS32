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
                result <= op1 << op2[`WORD_INDEX_W-1:0];
            `ALU_ARITH_SR:
                result <= op1 >>> op2[`WORD_INDEX_W-1:0];
            `ALU_LOGIC_SR:
                result <= op1 >> op2[`WORD_INDEX_W-1:0];
            `ALU_AND:
                result <= op1 & op2;
            `ALU_OR:
                result <= op1 | op2;
            `ALU_XOR:
                result <= op1 ^ op2;
            `ALU_NOR:
                result <= ~(op1 | op2);
            `ALU_EQ:
                result <= { {`WORD_WIDTH-1{1'b0}}, op1 == op2 };
            `ALU_NEQ:
                result <= { {`WORD_WIDTH-1{1'b0}}, op1 != op2 };
            `ALU_G:
                result <= { {`WORD_WIDTH-1{1'b0}}, $signed(op1) > $signed(op2) };
            `ALU_L:
                result <= { {`WORD_WIDTH-1{1'b0}}, $signed(op1) < $signed(op2) };
            `ALU_GE:
                result <= { {`WORD_WIDTH-1{1'b0}}, $signed(op1) >= $signed(op2) };
            `ALU_LE:
                result <= { {`WORD_WIDTH-1{1'b0}}, $signed(op1) <= $signed(op2) };
            `ALU_G_U:
                result <= { {`WORD_WIDTH-1{1'b0}}, op1 > op2 };
            `ALU_L_U:
                result <= { {`WORD_WIDTH-1{1'b0}}, op1 < op2 };
            `ALU_GE_U:
                result <= { {`WORD_WIDTH-1{1'b0}}, op1 >= op2 };
            `ALU_LE_U:
                result <= { {`WORD_WIDTH-1{1'b0}}, op1 <= op2 };
            default: 
                result <= `ZERO_WORD;
        endcase
    end
endmodule