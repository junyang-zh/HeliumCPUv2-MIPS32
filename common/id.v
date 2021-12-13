`include "defines.v"

module decoder #(
    parameter W = `WORD_WIDTH
) (
    input wire clk, rst,
    input wire[W-1:0] inst,

    output reg[1:0] inst_type,
    // R, I, J
    output reg[`OP_WIDTH-1:0] op_code,
    // J
    output reg[`J_ADDR_WIDTH-1:0] j_addr,
    // R, I
    output reg[`REG_ADDR_W-1:0] rs, rt,
    // I
    output reg[`IMM_WIDTH-1:0] imm,
    // R
    output reg[`REG_ADDR_W-1:0] rd,
    output reg[`WORD_INDEX_W-1:0] shamt,
    output reg[`FUNCT_WIDTH-1:0] funct
);
    // these regs are combinational logic
    reg[1:0] comb_inst_type;
    reg[`OP_WIDTH-1:0] comb_op_code;

    always @(*) comb_op_code <= inst[W-1:W-`OP_WIDTH];

    always @(*) case (comb_op_code)
        `R_R:
            comb_inst_type = `R_TYPE;
        `LW,
        `SW,
        `BEQ,
        `BNE,
        `BLEZ,
        `BGTZ,
        `BGEZ_BLTZ:
            comb_inst_type = `I_TYPE;
        `J:
            comb_inst_type = `J_TYPE;
        default:
            comb_inst_type = `ERR_T;
    endcase

    always @(posedge clk) begin
        case (comb_inst_type)
            `R_TYPE: begin
                rs <= inst[25:21];
                rt <= inst[20:16];
                rd <= inst[15:11];
                shamt <= inst[10:6];
                funct <= inst[5:0];
            end
            `I_TYPE: begin
                rs <= inst[25:21];
                rt <= inst[20:16];
                imm <= inst[15:0];
            end
            `J_TYPE: begin
                j_addr <= inst[25:0];
            end
        endcase
        op_code <= comb_op_code;
        inst_type <= comb_inst_type;
    end
endmodule