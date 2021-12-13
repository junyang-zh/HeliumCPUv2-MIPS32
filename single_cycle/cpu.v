`include "defines.v"

module cpu #(
    parameter W = `WORD_WIDTH
) (
    // Clock and reset signals
	input wire clk, rst,
    // Program counter and fetched instruction
	output wire[W-1:0] pc,
	input wire[W-1:0] inst,
    // Load
    output wire load_en,
    output wire[W-1:0] l_addr,
	input wire[W-1:0] l_data,
    // Store
	output wire store_en,
    output wire[W-1:0] s_addr,
	output wire[W-1:0] s_data
);
    wire[W-1:0] targ_pc;
    wire branch_take;

    pc pc_inst(
        .clk(clk), .rst(rst),
        .stall(1'b0),
        .targ_pc(targ_pc),
        .branch_take(branch_take),
        .pc(pc)
    );
endmodule