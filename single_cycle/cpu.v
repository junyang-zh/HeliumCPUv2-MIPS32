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

    wire[1:0] inst_type;
    wire[`OP_WIDTH-1:0] op_code;
    wire[`J_ADDR_WIDTH-1:0] j_addr;
    wire[`REG_ADDR_W-1:0] rs, rt, rd;
    wire[W-1:0] imm;
    wire[`WORD_INDEX_W-1:0] shamt;

    decoder decoder_inst(
        .clk(clk), .rst(rst),
        .inst(inst),
        .inst_type(inst_type),
        .op_code(op_code),
        .j_addr(j_addr),
        .rs(rs), .rt(rt),
        .imm(imm),
        .shamt(shamt)
    );
endmodule