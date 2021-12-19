// cpu.v: single cycle cpu, mem ctrl not included

`include "defines.v"

module cpu #(
    parameter W = `WORD_WIDTH
) (
    // Clock and reset signals
	input wire clk, rst,
    // Program counter and fetched instruction
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
    // Connect ID backward signals
    // Connect EX backward signals

    wire pc_stall, pc_flush;
    wire[W-1:0] flush_addr;

    pc_assume_not_take pc_inst(
        .clk(clk), .rst(rst),
        .flush(pc_flush), .stall(pc_stall),
        .flush_addr(flush_addr),

        .pc(pc),
        .read_inst(read_inst),
        .inst(inst)
    );

    // IF-ID interstage: pc is already reg

    // ID stage

    // Decoder/reg read to stages
    wire[W-1:0] inst, rs_val, rt_val, rd_val, imm;
    wire[`REG_ADDR_W-1:0] rs_addr, rt_addr, rd_addr;
    wire[`WORD_INDEX_W-1:0] shamt;
    // Control to reg read, also send to forward ctrl
    wire rs_read_en, rt_read_en;
    // Control to stages
    wire can_branch, jump, targ_else_offset, pc_addr_src_reg;
    wire[`ALUOP_WIDTH-1:0] alu_op;
    wire[`ALU_SRC_WIDTH-1:0] alu_op1_src, alu_op2_src;
    wire reg_write;
    wire[`REG_W_SRC_WIDTH-1:0] reg_write_src;
    wire[`REG_ADDR_W-1:0] reg_write_addr;
    wire mem_read_en, mem_write_en;
    wire[`L_S_MODE_W-1:0] l_s_mode;

    // Id stage stall (save power)
    wire id_stall;
    // Bubble: interstage regs bubble
    wire id_ex_bubble;

    decoder decoder_inst(
        .clk(clk), .rst(rst),
        .stall(id_stall), .bubble(id_ex_bubble),
        .inst(inst),

        .rs(rs_addr), .rt(rt_addr),
        .imm(imm),
        .rd(rd_addr),
        .shamt(shamt),

        .alu_op(alu_op),
        .alu_op1_src(alu_op1_src),
        .alu_op2_src(alu_op2_src),
        .can_branch(can_branch),
        .jump(jump),
        .targ_else_offset(targ_else_offset),
        .pc_addr_src_reg(pc_addr_src_reg),
        .rs_read_en(rs_read_en), .rt_read_en(rt_read_en), .reg_write(reg_write),
        .reg_write_src(reg_write_src),
        .reg_write_addr(reg_write_addr),
        .mem_read_en(mem_read_en), .mem_write_en(mem_write_en),
        .l_s_mode(l_s_mode)
    );
    
    // Connect backward WB signals 
    wire reg_write_en;
    wire[W-1:0] reg_write_data;
    wire[`REG_ADDR_W-1:0] wb_reg_write_addr;

    regfile regfile_inst(
        .clk(clk), .rst(rst),
        .rs_en(rs_read_en),
        .rs_addr(rs_addr),
        .rs_data(rs_val),
        .rt_en(rt_read_en),
        .rt_addr(rt_addr),
        .rt_data(rt_val),
        .write_en(reg_write_en),
        .write_addr(wb_reg_write_addr),
        .write_data(reg_write_data)
    );

    // ID-EX interstage

    wire[W-1:0] ex_pc;

    ctrl_regs #(1000) id_ex (
        .clk(clk), .rst(rst),
        .stall(`FALSE), .bubble(id_ex_bubble),
        .ctrl_in(pc),
        .ctrl_out(ex_pc)
    );

    // EX stage

    wire[W-1:0] rs_forward_val, rt_forward_val;
    wire[W-1:0] alu_result;

    alu_with_src_mux alu_inst(
        .clk(clk),
        // TODO stall
        .stall(`FALSE),
        .alu_op1_src(alu_op1_src), .alu_op2_src(alu_op2_src),
        .rs_val(rs_forward_val), .rt_val(rt_forward_val), .imm(imm), .pc(ex_pc),
        .alu_op(alu_op),
        .result(alu_result)
    );

    // EX-MEM interstage

    // PC controls
    wire mem_can_branch, mem_targ_else_offset, mem_pc_addr_src_reg;
    // Mem/reg controls
    wire mem_mem_read_en, mem_mem_write_en;
    wire[`L_S_MODE_W-1:0] mem_l_s_mode;
    wire mem_reg_write;
    wire[`REG_W_SRC_WIDTH-1:0] mem_reg_write_src;
    wire[`REG_ADDR_W-1:0] mem_reg_write_addr;

    wire[W-1:0] mem_pc, mem_imm, mem_rt_val; // alu_result is already reg

    ctrl_regs #(1000) ex_mem (
        .clk(clk), .rst(rst),
        .stall(`FALSE), .bubble(`FALSE), // Keep going
        .ctrl_in({
            can_branch, targ_else_offset, pc_addr_src_reg,
            mem_read_en, mem_write_en, l_s_mode,
            reg_write, reg_write_src, reg_write_addr,
            ex_pc, imm, rt_val
        }),
        .ctrl_out({
            mem_can_branch, mem_targ_else_offset, mem_pc_addr_src_reg,
            mem_mem_read_en, mem_mem_write_en, mem_l_s_mode,
            mem_reg_write, mem_reg_write_src, mem_reg_write_addr,
            mem_pc, mem_imm, mem_rt_val
        })
    );

    // MEM stage

    wire[W-1:0] mem_write_data, mem_read_data;

    mem mem_inst(
        .clk(clk), .rst(rst),

        .mem_read_en(mem_mem_read_en), .mem_write_en(mem_mem_write_en),
        .mem_addr(alu_result),
        .l_s_mode(mem_l_s_mode),
        .mem_write_data(mem_rt_val), .mem_read_data(mem_read_data),

        .load_en(load_en),
        .l_addr(l_addr),
        .l_data(l_data),
        .store_en(store_en),
        .s_addr(s_addr),
        .s_data(s_data)
    );

    // MEM-WB interstage

    wire wb_reg_write;
    wire[`REG_W_SRC_WIDTH-1:0] wb_reg_write_src;
    // Connected at id: wire[`REG_ADDR_W-1:0] wb_reg_write_addr;

    // mem_read_data is already reg
    wire[W-1:0] wb_pc, wb_imm, wb_alu_result;

    ctrl_regs #(1000) mem_wb (
        .clk(clk), .rst(rst),
        .stall(`FALSE), .bubble(`FALSE), // Keep going
        .ctrl_in({
            mem_reg_write, mem_reg_write_src, mem_reg_write_addr,
            mem_pc, mem_imm, alu_result
        }),
        .ctrl_out({
            wb_reg_write, wb_reg_write_src, wb_reg_write_addr,
            wb_pc, wb_imm, wb_alu_result
        })
    );


    // WB stage

    writeback wb_inst(
        .reg_write(wb_reg_write),
        .alu_result(wb_alu_result), .mem_data(mem_read_data), .pc(wb_pc), .imm(wb_imm),
        .reg_write_src(wb_reg_write_src),

        .write_en(reg_write_en),
        .reg_write_data(reg_write_data)
    );

    // Forward and mem-ex hazard detection

    wire ex_rs_forward, ex_rt_forward, mem_rs_forward, mem_rt_forward;

    forward_detection forward_detection_inst(
        .idex_rs_reg_read(rs_read_en), .idex_rt_reg_read(rt_read_en),
        .idex_rs_addr(rs_addr), .idex_rt_addr(rt_addr),

        .exmem_reg_write(mem_reg_write),
        .exmem_reg_write_addr(mem_reg_write_addr),
        .ex_rs_forward(ex_rs_forward), .ex_rt_forward(ex_rt_forward),

        .memwb_reg_write(wb_reg_write),
        .memwb_reg_write_addr(wb_reg_write_addr),
        .mem_rs_forward(mem_rs_forward), .mem_rt_forward(mem_rt_forward)
    );

    // Actually ex stage

    wire mem_ex_hazard;

    alu_forward_mux alu_forward_mux_inst(
        // rs_val, rt_val are already id-ex stage reg, so no ex_rt_val
        .rs_val(rs_val), .rt_val(rt_val),

        .mem_alu_result(alu_result), .mem_pc(mem_pc), .mem_imm(mem_imm),
        .mem_reg_write_src(mem_reg_write_src),

        .wb_alu_result(wb_alu_result), .mem_read_data(mem_read_data), .wb_pc(wb_pc), .wb_imm(wb_imm),
        .wb_reg_write_src(wb_reg_write_src),

        .ex_rs_forward(ex_rs_forward), .ex_rt_forward(ex_rt_forward),
        .mem_rs_forward(mem_rs_forward), .mem_rt_forward(mem_rt_forward),

        .rs_forward_val(rs_forward_val), .rt_forward_val(rt_forward_val),
        .mem_ex_hazard(mem_ex_hazard)
    );

    // Hazard dealing

    wire j_ctrl_hazard, branch_ctrl_hazard;

    hazard hazard_inst(
        .rst(rst),
        .mem_ex_hazard(mem_ex_hazard),
        .j_ctrl_hazard(j_ctrl_hazard),
        .branch_ctrl_hazard(branch_ctrl_hazard),
        .pc_stall(pc_stall),
        .pc_flush(pc_flush),
        .id_stall(id_stall),
        .id_ex_bubble(id_ex_bubble)
    );

    ctrl_hazard_detect_assume_not_take ctrl_hazard_inst(
        .exmem_can_branch(mem_can_branch),
        .exmem_branch_take(alu_result[0]),
        .idex_jump(jump),
        .j_ctrl_hazard(j_ctrl_hazard),
        .branch_ctrl_hazard(branch_ctrl_hazard)
    );
    
    flush_addr_gen flush_addr_gen_inst(
        .j_ctrl_hazard(j_ctrl_hazard),
        .branch_ctrl_hazard(branch_ctrl_hazard),

        .idex_pc(ex_pc), .exmem_pc(mem_pc),
        .idex_targ_else_offset(targ_else_offset), .exmem_targ_else_offset(mem_targ_else_offset),

        .idex_pc_addr_src_reg(pc_addr_src_reg),
        .idex_rs_val(rs_val),
        .idex_imm(imm),
        
        .exmem_pc_addr_src_reg(mem_pc_addr_src_reg),
        .exmem_rs_val(mem_rs_val),
        .exmem_imm(mem_imm),

        .flush_addr(flush_addr)
    );
endmodule