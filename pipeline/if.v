// if.v: pc implementation for pipeline

`include "defines.v"

module pc_assume_not_take #(
    parameter W = `WORD_WIDTH
) (
    input wire clk, rst,
    input wire stall,           // Pipeline: for jumps, can't obtain addr, stall
    input wire flush,           // Flush signal for pipelines
    input wire[W-1:0] flush_addr,

    output reg[W-1:0] pc,
    input wire[W-1:0] read_inst,
    output reg[W-1:0] inst
);
    always @(*) begin           // reset
        if (rst) begin
            inst <= `ZERO_WORD;
            pc <= `ZERO_WORD;
        end
    end
    // posedge pc
    always @(posedge clk) begin
        if (rst) begin
            pc <= `ZERO_WORD;
        end
        else if (stall) begin
            pc <= pc;
        end
        else if (flush) begin
            pc <= flush_addr;
        end
        else begin
            pc <= pc + 4;
        end
    end
    // negedge fetch
    always @(negedge clk) begin
        inst <= read_inst;
    end
endmodule