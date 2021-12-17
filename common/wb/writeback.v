// writeback.v

`include "defines.v"

module writeback #(
    parameter W = `WORD_WIDTH
) (
    input wire clk, rst,

    input wire reg_write,
    input wire[W-1:0] alu_result, mem_data, pc, imm,
    input wire[`REG_W_SRC_WIDTH-1:0] reg_write_src,

    output wire write_en,
    output reg[W-1:0] reg_write_data
);
    assign write_en = reg_write;

    always @(*) begin
        if (reg_write) begin
            case (reg_write_src)
                `REG_W_SRC_ALU:
                    reg_write_data = alu_result;
                `REG_W_SRC_MEM:
                    reg_write_data = mem_data;
                `REG_W_SRC_PCA4:
                    reg_write_data = pc + 4;
                `REG_W_SRC_IMM:
                    reg_write_data = imm;
                default: reg_write_data = `ZERO_WORD;
            endcase
        end
    end
endmodule