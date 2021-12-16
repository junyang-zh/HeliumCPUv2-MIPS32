// counter.v: generate sub cycles

`include "defines.v"

// The stage footprints for different instruction types
`define SUFFIX_TYPE_W   4

// `LB, `LBU, `LH, `LHU, `LW
`define EX_MEM_WB       `SUFFIX_TYPE_W'd0
// `SB, `SH, `SW
`define EX_MEM          `SUFFIX_TYPE_W'd1
// `R_TYPE except `JR
// `ADDI, `ADDIU, `ANDI, `ORI, `XORI, `SLTI, `SLTIU
// `JAL
`define EX_WB           `SUFFIX_TYPE_W'd2
// (Rtype)`JR, `BEQ, `BNE, `BLEZ, `BGTZ, `BGEZ_BLTZ
`define ONLY_EX         `SUFFIX_TYPE_W'd3
// `J
`define NO_SUFFIX       `SUFFIX_TYPE_W'd4
// `LUI:
`define ONLY_WB         `SUFFIX_TYPE_W'd5
// BEFORE DECODE!
`define NOT_AVAILABLE   `SUFFIX_TYPE_W'd6

module counter #(
    parameter COUNTER_W = 3,
    parameter N = 5,
    parameter PREFIX_N = 3'd2,      // Must do if id stages
    parameter TOTAL_TYPES = 6
) (
    input wire clk, rst,
    input wire[`OP_WIDTH-1:0] op_code,
    input wire[`FUNCT_WIDTH-1:0] funct,
    output wire if_clk, id_clk, ex_clk, mem_clk, wb_clk,
    output wire inst_read_en
);
    // Look-up tables
    function[COUNTER_W:0] seq_lookup_table; // Execute sequence of a type, followed by a invalid bool
        input[COUNTER_W-1:0] stage_count;   // Current stages sequence number
        input[`SUFFIX_TYPE_W-1:0] exe_type;
        begin
            case (exe_type)
                `EX_MEM_WB: begin
                    seq_lookup_table = { stage_count, (stage_count >= 3'd5) };
                end
                `EX_MEM: begin
                    seq_lookup_table = { stage_count, (stage_count >= 3'd4) };
                end
                `ONLY_EX: begin
                    seq_lookup_table = { stage_count, (stage_count >= 3'd3) };
                end
                `NO_SUFFIX: begin
                    seq_lookup_table = { stage_count, (stage_count >= 3'd2) };
                end
                `EX_WB: case (stage_count)
                    3'd2: seq_lookup_table = { 3'd2, `FALSE };
                    3'd3: seq_lookup_table = { 3'd4, `FALSE };
                    default: seq_lookup_table = { 3'd0, `TRUE };
                endcase
                `ONLY_WB: case (stage_count)
                    3'd2: seq_lookup_table = { 3'd4, `FALSE };
                    default: seq_lookup_table = { 3'd0, `TRUE };
                endcase
                default: seq_lookup_table = { 3'd0, `TRUE };
            endcase
        end
    endfunction

    // Do if id first, and decide rest stage by op_code/funct
    reg[COUNTER_W-1:0] count;
    reg[`SUFFIX_TYPE_W-1:0] suffix_type;
    reg[N-1:0] clks;
    // For suffix execution
    reg[COUNTER_W-1:0] cur_cnt; // Mapped stage
    reg invalid;                // Finished the last stage

    always @(posedge clk) begin
        clks = 0;
        if (rst) begin
            count = 0;
            clks[count] = 1;
            suffix_type = `NOT_AVAILABLE;
        end
        else begin
            if (count < PREFIX_N - 1) begin
                count = count + 1;
                clks[count] = 1;
                suffix_type = `NOT_AVAILABLE;
            end
            else begin
                if (suffix_type == `NOT_AVAILABLE) case (op_code)
                    `R_R: case (funct)
                        `JR: suffix_type = `ONLY_EX;
                        default: suffix_type = `EX_WB;
                    endcase
                    `LB, `LBU, `LH, `LHU, `LW:
                        suffix_type = `EX_MEM_WB;
                    `SB, `SH, `SW:
                        suffix_type = `EX_MEM;
                    `ADDI, `ADDIU, `ANDI, `ORI, `XORI, `SLTI, `SLTIU, `JAL:
                        suffix_type = `EX_WB;
                    `BEQ, `BNE, `BLEZ, `BGTZ, `BGEZ_BLTZ:
                        suffix_type = `ONLY_EX;
                    `J:
                        suffix_type = `NO_SUFFIX;
                    `LUI:
                        suffix_type = `ONLY_WB;
                    default: suffix_type = `EX_MEM_WB;
                endcase

                count = count + 1;
                { cur_cnt, invalid } = seq_lookup_table(count, suffix_type);

                if (invalid) begin
                    count = 0;
                    clks[count] = 1;
                    suffix_type = `NOT_AVAILABLE;
                end
                else begin
                    clks[cur_cnt] = 1;
                end
            end
        end
        
    end

    always @(negedge clk) begin // cut waveforms
        clks = 0;
    end

    assign inst_read_en = (count == 0);
    assign { wb_clk, mem_clk, ex_clk, id_clk, if_clk } = clks;
endmodule