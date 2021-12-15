// counter.v: generate sub cycles

`include "defines.v"

// The stage footprints for different instruction types
`define SUFFIX_TYPE_W   3
// `R_TYPE except `JR
// `ADDI, `ADDIU, `ANDI, `ORI, `XORI, `SLTI, `SLTIU
// `JAL
`define EX_MEM_WB
// `SB, `SH, `SW
`define EX_MEM
// `JR, `BEQ, `BNE, `BLEZ, `BGTZ, `BGEZ_BLTZ
`define EX_WB
// `LB, `LBU, `LH, `LHU, `LW
`define ONLY_EX
// `J
`define NO_SUFFIX
// `LUI:
`define ONLY_WB

module counter #(
    parameter COUNTER_W = 2,
    parameter N = 5,
    parameter PREFIX_N = 2'd2,  // Must do if id stages
    parameter MAX_SUFFIX = 2'd3 // Optional ex mem wb
) (
    input wire clk, rst,
    input wire[`OP_WIDTH-1:0] op_code,
    output wire if_clk, id_clk, ex_clk, mem_clk, wb_clk
);
    // Do if id first, and decide rest stage by op_code
    // When rest stage finished, set done
    reg[COUNTER_W-1:0] prefix_count, suffix_count;
    reg suffix_done;
    reg[N-1:0] clks;

    always @(posedge clk) begin
        clks = 0;
        if (rst) begin
            prefix_count = 0;
            suffix_count = 0;
            suffix_done = `FALSE;
        end
        else begin
            if (prefix_count != PREFIX_N) begin
                clks[prefix_count] = 1;
                prefix_count = prefix_count + 1;
            end
            else if (suffix_done) begin
                prefix_count = 0;
            end
        end
        
    end

    always @(negedge clk) begin // cut waveforms
        clks = 0;
    end

    assign { wb_clk, mem_clk, ex_clk, id_clk, if_clk } = clks;
endmodule