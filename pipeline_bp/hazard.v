// hazard.v: send bubble and stalls, also detect control hazards
// implements assume not take

`include "defines.v"

module hazard (
    input wire rst,

    input wire mem_ex_hazard, j_ctrl_hazard, branch_ctrl_hazard,
    // Stall + bubble = bubble
    // Mere bubble = flush
    output reg pc_flush, pc_stall, id_stall, id_ex_bubble
);
    always @(*) begin
        if (rst) begin
            pc_flush <= `FALSE;
            pc_stall <= `FALSE;
            id_stall <= `FALSE;
            id_ex_bubble <= `FALSE;
        end
        else begin
            id_ex_bubble <= (mem_ex_hazard || branch_ctrl_hazard);
            pc_stall <= mem_ex_hazard;
            id_stall <= mem_ex_hazard;

            pc_flush <= (j_ctrl_hazard || branch_ctrl_hazard);
        end
    end
endmodule

module actual_addr_gen #(
    parameter W = `WORD_WIDTH
) (
    input wire idex_jump, exmem_can_branch,

    input wire[W-1:0] idex_pc, exmem_pc,
    input wire idex_targ_else_offset, exmem_targ_else_offset,

    input wire idex_pc_addr_src_reg,    // MUX condition: addr from reg or imm
    input wire[W-1:0] idex_rs_val,      // MUX v1
    input wire[W-1:0] idex_imm,         // MUX v2
    
    input wire exmem_pc_addr_src_reg,
    input wire[W-1:0] exmem_rs_val,
    input wire[W-1:0] exmem_imm,

    output reg[W-1:0] flush_addr
);
    reg[W-1:0] pc_targ_addr;
    // Take the older(deeper) one's jump policy
    always @(*) begin
        if (exmem_can_branch) begin
            pc_targ_addr = exmem_pc_addr_src_reg ? exmem_rs_val : exmem_imm;
            flush_addr = exmem_targ_else_offset ? pc_targ_addr : (exmem_pc + pc_targ_addr + 4);
        end
        else if (idex_jump) begin
            pc_targ_addr = idex_pc_addr_src_reg ? idex_rs_val : idex_imm;
            flush_addr = idex_targ_else_offset ? pc_targ_addr : (idex_pc + pc_targ_addr + 4);
        end
    end
endmodule

module ctrl_hazard_detect #(
    parameter W = `WORD_WIDTH
) (
    // Branches
    input wire exmem_can_branch,
    input wire exmem_branch_take,
    // Jumps
    input wire idex_jump,

    // Validate prediction
    input wire predict_j_taken,
    input wire[W-1:0] predict_addr,

    // Actual addr gen
    input wire[W-1:0] idex_pc, exmem_pc,
    input wire idex_targ_else_offset, exmem_targ_else_offset,
    input wire idex_pc_addr_src_reg,
    input wire[W-1:0] idex_rs_val,
    input wire[W-1:0] idex_imm,
    input wire exmem_pc_addr_src_reg,
    input wire[W-1:0] exmem_rs_val,
    input wire[W-1:0] exmem_imm,

    // Found jump mispredict after id stage
    output reg j_ctrl_hazard,
    // Found branch mispredict after ex stage
    output reg branch_ctrl_hazard,

    output wire[W-1:0] flush_addr,
    output reg upd,
    output reg add_else_minus,          // Outcome matches or not
    output reg[W-1:0] upd_src_pc        // The pc that accounts for the update
);

    actual_addr_gen addr_gen_inst(
        .idex_jump(idex_jump), .exmem_can_branch(exmem_can_branch),

        .idex_pc(idex_pc), .exmem_pc(exmem_pc),
        .idex_targ_else_offset(idex_targ_else_offset), .exmem_targ_else_offset(exmem_targ_else_offset),
        .idex_pc_addr_src_reg(idex_pc_addr_src_reg),
        .idex_rs_val(idex_rs_val), .idex_imm(idex_imm),
        .exmem_pc_addr_src_reg(exmem_pc_addr_src_reg),
        .exmem_rs_val(exmem_rs_val), .exmem_imm(exmem_imm),

        .flush_addr(flush_addr)
    );

    always @(*) begin
        j_ctrl_hazard = (idex_jump != predict_j_taken);
        branch_ctrl_hazard = (exmem_can_branch && 
            (exmem_branch_take != predict_j_taken || flush_addr != predict_addr)
        );
        upd = (exmem_can_branch || idex_jump);
        add_else_minus = (exmem_can_branch ? exmem_branch_take : 1);
        upd_src_pc = (exmem_can_branch ? exmem_pc : idex_pc);
    end
endmodule