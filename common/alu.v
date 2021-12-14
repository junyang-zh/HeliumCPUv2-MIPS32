// alu.v: execution stage

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

module alu_with_src_mux #(
    parameter W = `WORD_WIDTH
) (
    input wire[`ALU_SRC_WIDTH-1:0] alu_op1_src, alu_op2_src, // MUX condition
    input wire[W-1:0] rs_val, rt_val, imm, pc,          // Possible srcs

    input wire[`ALUOP_WIDTH-1:0] alu_op,
    output wire[W-1:0] result
);
    reg[W-1:0] op1, op2;
    
    always @(*) begin // MUX
        case (alu_op1_src)
            `ALU_OP_SRC_ZERO:   op1 <= `ZERO_WORD;
            `ALU_OP_SRC_IMM:    op1 <= imm;
            `ALU_OP_SRC_RS:     op1 <= rs_val;
            `ALU_OP_SRC_RT:     op1 <= rt_val;
            `ALU_OP_SRC_PC:     op1 <= pc;
            default:            op1 <= `ZERO_WORD;
        endcase
        case (alu_op2_src)
            `ALU_OP_SRC_ZERO:   op2 <= `ZERO_WORD;
            `ALU_OP_SRC_IMM:    op2 <= imm;
            `ALU_OP_SRC_RS:     op2 <= rs_val;
            `ALU_OP_SRC_RT:     op2 <= rt_val;
            `ALU_OP_SRC_PC:     op2 <= pc;
            default:            op2 <= `ZERO_WORD;
        endcase
    end

    alu pure_alu_inst(
        .op1(op1),
        .op2(op2),
        .alu_op(alu_op),
        .result(result)
    );
endmodule