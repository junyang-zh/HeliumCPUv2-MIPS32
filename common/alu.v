`include "defines.v"

module alu #(
    parameter W = `WORD_WIDTH
) (
    input wire[W-1:0] op1,
    input wire[W-1:0] op2,
    input wire[`ALUOP_WIDTH-1:0] alu_op,

    output wire[W-1:0] result,
    output wire zero,
    output wire carry,
    output wire negative,
    output wire overflow
);
    reg[W-1:0] res;
    always @(*) begin
        case (alu_op)
            `ADD:
                res <= $signed(op1) + $signed(op2);
            `ADDU:
                res <= op1 + op2;
            `AND:
                res <= op1 & op2;
            `NOR:
                res <= ~(op1 | op2);
            `OR:
                res <= op1 | op2;
            `SLL:
                res <= op1 << op2;
            `SLLV:
                res <= op1 << op2[4:0];
            `SLT:
                res <= $signed(op1) < $signed(op2) ? 1 : 0;
            `SLTU:
                res <= op1 < op2 ? 1 : 0;
            `SRA:
                res <= $signed(op1) >>> op2;
            `SRAV:
                res <= $signed(op1) >>> op2[4:0];
            `SRL:
                res <= op1 >> op2;
            `SRLV:
                res <= op1 >> op2[4:0];
            `SUB:
                res <= $signed(op1) - $signed(op2);
            `SUBU:
                res <= op1 - op2;
            `XOR:
                res <= op1 ^ op2;
            default: 
                res <= `ZERO_WORD;
        endcase
    end
    assign result = res;
endmodule