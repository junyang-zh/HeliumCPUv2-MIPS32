`include "defines.v"

module pc #(
    parameter W = `WORD_WIDTH
) (
    input wire clk, rst,
    input wire stall,           // stall signal for pipelines

    input wire branch_take,
    input wire targ_or_offset,
    input wire[W-1:0] targ_pc,
    input wire[W-1:0] offset,

    output reg[W-1:0] pc
);
    always @(posedge clk) begin
        if (rst) begin
            pc <= `ZERO_WORD;
        end
        else begin
            pc <= branch_take ? (targ_or_offset ? targ_pc : pc + offset) : pc + 4;
        end
    end
endmodule
