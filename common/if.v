`include "defines.v"

module pc #(
    parameter W = `WORD_WIDTH
) (
    input wire clk, rst,
    input wire stall,           // stall signal for pipelines

    input wire[W-1:0] targ_pc,
    input wire branch_take,     // 1 for j

    output reg[W-1:0] pc
);
    always @(posedge clk) begin
        if (rst) begin
            pc <= `ZERO_WORD;
        end
        else begin
            pc <= branch_take ? targ_pc : pc + 4;
        end
    end
endmodule
