// forward.v: handles the pipeline forwarding, and detect hazards when forwarding mem_data from ex stage

`include "defines.v"

module forward_detection (
    input wire idex_rs_reg_read, idex_rt_reg_read,
    input wire[`REG_ADDR_W-1:0] idex_rs_addr, idex_rt_addr,
    // EX-EX forward
    input wire exmem_reg_write_en,
    input wire[`REG_ADDR_W-1:0] exmem_reg_write_addr,
    output reg ex_rs_forward, ex_rt_forward,
    // MEM-EX forward
    input wire memwb_reg_write_en,
    input wire[`REG_ADDR_W-1:0] memwb_reg_write_addr,
    output reg mem_rs_forward, mem_rt_forward
);
    always @(*) begin
        if (exmem_reg_write_en) begin
            ex_rs_forward <= (idex_rs_addr != `REG_ZERO && idex_rs_addr == exmem_reg_write_addr);
            ex_rt_forward <= (idex_rs_addr != `REG_ZERO && idex_rt_addr == exmem_reg_write_addr);
        end
        if (memwb_reg_write_en) begin
            mem_rs_forward <= (idex_rs_addr != `REG_ZERO && idex_rs_addr == memwb_reg_write_addr);
            mem_rt_forward <= (idex_rs_addr != `REG_ZERO && idex_rt_addr == memwb_reg_write_addr);
        end
    end
endmodule

module alu_forward_mux #(
    parameter W = `WORD_WIDTH
) (
    input wire[W-1:0] rs_val, rt_val,

    input wire[W-1:0] mem_alu_result, mem_pc, mem_imm,
    input wire[`REG_W_SRC_WIDTH-1:0] mem_reg_write_src,

    input wire[W-1:0] wb_alu_result, mem_read_data, wb_pc, wb_imm,
    input wire[`REG_W_SRC_WIDTH-1:0] wb_reg_write_src,

    input wire ex_rs_forward, ex_rt_forward,
    input wire mem_rs_forward, mem_rt_forward,

    output reg[W-1:0] rs_forward_val, rt_forward_val,
    output reg mem_ex_hazard
);
    reg[W-1:0] ex_reg_write_data, mem_reg_write_data;
    reg ex_src_mem_flag;
    always @(*) begin
        ex_src_mem_flag = (mem_reg_write_src == `REG_W_SRC_MEM);
        case (mem_reg_write_src)
            `REG_W_SRC_ALU:
                ex_reg_write_data = mem_alu_result;
            `REG_W_SRC_MEM: // This may raise a hazard
                ex_reg_write_data = `ZERO_WORD;
            `REG_W_SRC_PCA4:
                ex_reg_write_data = mem_pc + 4;
            `REG_W_SRC_IMM:
                ex_reg_write_data = mem_imm;
            default: ex_reg_write_data = `ZERO_WORD;
        endcase
        case (wb_reg_write_src)
            `REG_W_SRC_ALU:
                mem_reg_write_data = wb_alu_result;
            `REG_W_SRC_MEM:
                mem_reg_write_data = mem_read_data;
            `REG_W_SRC_PCA4:
                mem_reg_write_data = wb_pc + 4;
            `REG_W_SRC_IMM:
                mem_reg_write_data = wb_imm;
            default: mem_reg_write_data = `ZERO_WORD;
        endcase

        // Forward latest policy
        // RS
        if (ex_rs_forward) begin
            if (ex_src_mem_flag) begin // Hazard!
                mem_ex_hazard = `TRUE;
            end
            else begin
                rs_forward_val = ex_reg_write_data;
            end
        end
        else if (mem_rs_forward) begin
            rs_forward_val = mem_reg_write_data;
        end
        else begin
            rs_forward_val = rs_val;
        end
        // RT
        if (ex_rt_forward) begin
            if (ex_src_mem_flag) begin // Hazard!
                mem_ex_hazard = `TRUE;
            end
            else begin
                rt_forward_val = ex_reg_write_data;
            end
        end
        else if (mem_rt_forward) begin
            rt_forward_val = mem_reg_write_data;
        end
        else begin
            rt_forward_val = rt_val;
        end
    end
endmodule