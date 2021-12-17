// cpu.v: single cycle cpu, mem ctrl not included

`include "defines.v"

module cpu #(
    parameter W = `WORD_WIDTH
) (
    // Clock and reset signals
	input wire clk, rst,
    // Program counter and fetched instruction
    output wire pc_clk,
	output wire[W-1:0] pc,
	input wire[W-1:0] read_inst,
    // Load
    output wire load_clk, load_en,
    output wire[W-1:0] l_addr,
	input wire[W-1:0] l_data,
    // Store
	output wire store_clk, store_en,
    output wire[W-1:0] s_addr,
	output wire[W-1:0] s_data
);
    // IF stage

    // PC ctrls
    wire can_branch, targ_else_offset, pc_addr_src_reg;
    wire[W-1:0] inst, rs_val, rt_val, rd_val, imm, alu_result;

    pc_with_addr_mux pc_inst(
        .clk(clk), .rst(rst),
        // TODO: flush, stall
        .can_branch(can_branch),
        .branch_take(alu_result[0]),
        .targ_else_offset(targ_else_offset),

        .pc_addr_src_reg(pc_addr_src_reg),
        .rs_val(rs_val),
        .imm(imm),

        .pc(pc),
        .read_inst(read_inst),
        .inst(inst)
    );

    // ID stage

    // Decoder to stages
    wire[`REG_ADDR_W-1:0] rs_addr, rt_addr, rd_addr;
    wire[`WORD_INDEX_W-1:0] shamt;
    // Control to stages
    wire[`ALUOP_WIDTH-1:0] alu_op;
    wire[`ALU_SRC_WIDTH-1:0] alu_op1_src, alu_op2_src;
    wire rs_read_en, rt_read_en, reg_write;
    wire[`REG_W_SRC_WIDTH-1:0] reg_write_src;
    wire[`REG_W_DST_WIDTH-1:0] reg_write_dst;
    wire mem_read_en, mem_write_en;
    wire[`L_S_MODE_W-1:0] l_s_mode;

    decoder decoder_inst(
        .clk(clk), .rst(rst),
        .inst(inst),

        .rs(rs_addr), .rt(rt_addr),
        .imm(imm),
        .rd(rd_addr),
        .shamt(shamt),

        .alu_op(alu_op),
        .alu_op1_src(alu_op1_src),
        .alu_op2_src(alu_op2_src),
        .can_branch(can_branch),
        .targ_else_offset(targ_else_offset),
        .pc_addr_src_reg(pc_addr_src_reg),
        .rs_read_en(rs_read_en), .rt_read_en(rt_read_en), .reg_write(reg_write),
        .reg_write_src(reg_write_src),
        .reg_write_dst(reg_write_dst),
        .mem_read_en(mem_read_en), .mem_write_en(mem_write_en),
        .l_s_mode(l_s_mode)
    );

    // EX stage

    wire write_en;
    wire[`REG_ADDR_W-1:0] reg_write_addr;
    wire[W-1:0] reg_write_data;

    regfile regfile_inst(
        .clk(clk), .rst(rst),
        .rs_en(rs_read_en),
        .rs_addr(rs_addr),
        .rs_data(rs_val),
        .rt_en(rt_read_en),
        .rt_addr(rt_addr),
        .rt_data(rt_val),
        .write_en(write_en),
        .write_addr(reg_write_addr),
        .write_data(reg_write_data)
    );

    alu_with_src_mux alu_inst(
        .clk(clk),
        .alu_op1_src(alu_op1_src), .alu_op2_src(alu_op2_src),
        .rs_val(rs_val), .rt_val(rt_val), .imm(imm), .pc(pc),
        .alu_op(alu_op),
        .result(alu_result)
    );

    // MEM stage

    wire[W-1:0] mem_write_data, mem_read_data;

    mem mem_inst(
        .clk(clk), .rst(rst),

        .mem_read_en(mem_read_en), .mem_write_en(mem_write_en),
        .mem_addr(alu_result),
        .l_s_mode(l_s_mode),
        .mem_write_data(rt_val), .mem_read_data(mem_read_data),

        .load_en(load_en),
        .l_addr(l_addr),
        .l_data(l_data),
        .store_en(store_en),
        .s_addr(s_addr),
        .s_data(s_data)
    );

    // WB stage

    writeback wb_inst(
        .reg_write(reg_write),
        .alu_result(alu_result), .mem_data(mem_read_data), .pc(pc), .imm(imm),
        .rd(rd_addr), .rt(rt_addr),
        .reg_write_src(reg_write_src),
        .reg_write_dst(reg_write_dst),

        .write_en(write_en),
        .reg_write_addr(reg_write_addr),
        .reg_write_data(reg_write_data)
    );
    
endmodule