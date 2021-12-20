// branch_predict.v: perform branch predict pc

`include "defines.v"

module pc_with_bp_btb #(
    parameter W = `WORD_WIDTH,
    parameter BP_BITS = 2,      // 2 bit saturating counter
    parameter BP_MAX = 2'b11,
    parameter BP_MIN = 2'b00,
    parameter BTB_W = 8
) (
    input wire clk, rst,
    input wire stall,           // Pipeline: for jumps, can't obtain addr, stall
    input wire flush,           // Flush signal for pipelines
    input wire[W-1:0] flush_addr,

    input wire upd,                     // Update the prediction outcome
    input wire add_else_minus,          // Outcome matches or not
    input wire[W-1:0] upd_src_pc,       // The pc that accounts for the update

    output reg[W-1:0] pc,

    output reg predict_j_taken,         // Predicted jumped or taken branch
    output reg[W-1:0] predict_addr,     // Predicted address of jump or branch

    input wire[W-1:0] read_inst,
    output reg[W-1:0] inst
);
    always @(*) begin           // reset
        if (rst) begin
            inst <= `ZERO_WORD;
            pc <= `ZERO_WORD;
            predict_j_taken <= `FALSE;
        end
    end

    // Saturating counter
    reg[BP_BITS-1:0] bp[(1<<BTB_W)-1:0];
    // Branch target buffer
    reg[W-1:0] btb[(1<<BTB_W)-1:0];

    generate
        integer i;
        always @(*) begin
            if (rst) for (i = 0; i < (1<<BTB_W); i = i + 1) begin: bp_btb_rst
                btb[i] <= `ZERO_WORD;
                bp[i] <= (BP_BITS >> 1); // Weakest not take
            end
        end
    endgenerate

    // Update prediction
    always @(posedge clk) begin
        if (upd) begin
            if (add_else_minus) begin
                if (bp[upd_src_pc[BTB_W+1:2]] != BP_MAX) begin
                    bp[upd_src_pc[BTB_W+1:2]] <= bp[upd_src_pc[BTB_W+1:2]] + 1;
                end
            end
            else begin
                if (bp[upd_src_pc[BTB_W+1:2]] != BP_MIN) begin
                    bp[upd_src_pc[BTB_W+1:2]] <= bp[upd_src_pc[BTB_W+1:2]] - 1;
                end
            end
        end
    end

    // Make prediction
    always @(posedge clk) begin
        predict_j_taken <= ( | (bp[pc[BTB_W+1:2]] >> (BTB_W>>1)) ); // Any bits set in the higher half
        predict_addr <= btb[pc[BTB_W+1:2]];
    end

    // posedge pc
    always @(posedge clk) begin
        if (rst) begin
            pc <= `ZERO_WORD;
        end
        else if (stall) begin
            pc <= pc;
        end
        else if (flush) begin   // flushed, thus need to change btb
            pc <= flush_addr;
            btb[upd_src_pc[BTB_W+1:2]] <= flush_addr;
        end
        else if (predict_j_taken) begin
            pc <= predict_addr;
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