// control.v: instruction fetch stage

`include "defines.v"

module control (
    input wire[`OP_WIDTH-1:0] op_code,
    input wire[`FUNCT_WIDTH-1:0] funct,
    input wire[`REG_ADDR_W-1:0] rt,
    input wire[1:0] inst_type,
    // ALU control
    output reg[`ALUOP_WIDTH-1:0] alu_op,
    output reg[`ALU_SRC_WIDTH-1:0] alu_op1_src, // op1 src: imm, rs, rt
    output reg[`ALU_SRC_WIDTH-1:0] alu_op2_src, // op1 src: imm, rs, rt
    // PC control
    output reg can_branch,      // if the inst can branch
    output reg targ_else_offset,// if the addr is target, else offset
    output reg pc_addr_src_reg, // if the addr is from regfile, else imm
    // REG control
    output reg rs_read_en, rt_read_en, reg_write,
    output reg[`REG_W_SRC_WIDTH-1:0] reg_write_src,
    output reg[`REG_W_DST_WIDTH-1:0] reg_write_dst,
    // MEM control
    output reg mem_read_en, mem_write_en, // mem addr can only be alu_result (l, s)
    output reg[`L_S_MODE_W-1:0] l_s_mode        // word, halfword or byte
);
    always @(*) begin

        // ALU CTRL --------------------------------------------------//
        case (inst_type)
            `R_TYPE: begin
                // Decide ALU Ctrl OP
                case (funct)
                    `ADD, `ADDU:
                        alu_op = `ALU_ADD;
                    `SUB, `SUBU:
                        alu_op = `ALU_SUB;
                    `MULT, `MULTU: // TODO: NO MDU
                        alu_op = `ALU_MULT;
                    `DIV, `DIVU: // TODO: NO MDU
                        alu_op = `ALU_DIV;
                    `SLL, `SLLV:
                        alu_op = `ALU_SL;
                    `SLT, `SLTU:
                        alu_op = `ALU_L;
                    `SRA, `SRAV:
                        alu_op = `ALU_ARITH_SR;
                    `SRL, `SRLV:
                        alu_op = `ALU_LOGIC_SR;
                    `AND:
                        alu_op = `ALU_AND;
                    `OR:
                        alu_op = `ALU_OR;
                    `XOR:
                        alu_op = `ALU_XOR;
                    `NOR:
                        alu_op = `ALU_NOR;
                    `JALR:
                        alu_op = `ALU_ADD;
                    // `JR: // Need no ALU
                    default: alu_op = `ALUOP_ERR;
                endcase
                // Decide ALU Ctrl src
                case (funct)
                    `ADD, `ADDU, `SUB, `SUBU,
                    `MULT, `MULTU, `DIV, `DIVU,
                    `AND, `OR, `XOR, `NOR,
                    `SLT, `SLTU: begin
                        alu_op1_src = `ALU_OP_SRC_RS;
                        alu_op2_src = `ALU_OP_SRC_RT;
                    end
                    `SLL, `SRA, `SRL: begin
                        alu_op1_src = `ALU_OP_SRC_RT;
                        alu_op2_src = `ALU_OP_SRC_IMM;
                    end
                    `SLLV, `SRAV, `SRLV: begin
                        alu_op1_src = `ALU_OP_SRC_RT;
                        alu_op2_src = `ALU_OP_SRC_RS;
                    end
                    // `JALR, `JR: // Need no ALU
                    default: begin
                        alu_op1_src = `ALU_OP_SRC_ZERO;
                        alu_op2_src = `ALU_OP_SRC_ZERO;
                    end
                endcase
            end
            `I_TYPE: begin
                // Decide ALU Ctrl OP
                case (op_code)
                    `LB, `LBU, `LH, `LHU, `LW,
                    `SB, `SH, `SW:
                        alu_op = `ALU_ADD; // [rs] + offset
                    `ADDI, `ADDIU:
                        alu_op = `ALU_ADD;
                    `ANDI:
                        alu_op = `ALU_AND;
                    `LUI: // shiftleft "extended" imm and or 0
                        alu_op = `ALU_OR;
                    `ORI:
                        alu_op = `ALU_OR;
                    `SLTI:
                        alu_op = `ALU_L;
                    `SLTIU:
                        alu_op = `ALU_L_U;
                    `XORI:
                        alu_op = `ALU_XOR;
                    `BEQ:
                        alu_op = `ALU_EQ;
                    `BNE:
                        alu_op = `ALU_NEQ;
                    `BLEZ:
                        alu_op = `ALU_LE;
                    `BGTZ:
                        alu_op = `ALU_G;
                    `BGEZ_BLTZ:
                        case (rt)
                            `BGEZRT: alu_op = `ALU_GE;
                            `BLTZRT: alu_op = `ALU_L;
                            default: alu_op = `ALUOP_ERR;
                        endcase
                    default: alu_op = `ALUOP_ERR;
                endcase
                // Decide ALU Ctrl src
                case (op_code)
                    `LB, `LBU, `LH, `LHU, `LW,
                    `SB, `SH, `SW,
                    `ADDI, `ADDIU, `ANDI, `ORI,
                    `SLTI, `SLTIU, `XORI: begin
                        alu_op1_src = `ALU_OP_SRC_RS;
                        alu_op2_src = `ALU_OP_SRC_IMM;
                    end
                    `LUI: begin // IMM | 0
                        alu_op1_src = `ALU_OP_SRC_IMM;
                        alu_op2_src = `ALU_OP_SRC_ZERO;
                    end
                    `BEQ, `BNE: begin
                        alu_op1_src = `ALU_OP_SRC_RS;
                        alu_op2_src = `ALU_OP_SRC_RT;
                    end
                    `BLEZ, `BGTZ, `BGEZ_BLTZ: begin
                        alu_op1_src = `ALU_OP_SRC_RS;
                        alu_op2_src = `ALU_OP_SRC_ZERO;
                    end
                    default: begin
                        alu_op1_src = `ALU_OP_SRC_ZERO;
                        alu_op2_src = `ALU_OP_SRC_ZERO;
                    end
                endcase
            end
            // j jal need no ALU
            `J_TYPE: begin
                alu_op = `ALUOP_ERR;
            end
            default: alu_op = `ALUOP_ERR;
        endcase

        // PC CTRL ---------------------------------------------------//
        case (inst_type)
            `R_TYPE: begin
                case (funct)
                    `JALR, `JR: begin
                        can_branch = `TRUE;
                        targ_else_offset = `TRUE; // TARGET
                        pc_addr_src_reg = `TRUE; // REG
                    end
                    default: begin // Others don't mess up control flow
                        can_branch = `FALSE;
                        // Other signals (shall be) masked
                    end
                endcase
            end
            `I_TYPE: begin
                case (op_code)
                    `BEQ, `BNE, `BLEZ, `BGTZ, `BGEZ_BLTZ: begin
                        can_branch = `TRUE;
                        targ_else_offset = `FALSE; // OFFSET
                        pc_addr_src_reg = `FALSE; // IMM
                    end
                    default: can_branch = `FALSE;
                endcase
            end
            `J_TYPE: begin // `J, `JAL
                can_branch = `TRUE;
                targ_else_offset = `TRUE; // TARGET
                pc_addr_src_reg = `FALSE; // IMM
            end
            default: can_branch = `FALSE;
        endcase

        // REG CTRL --------------------------------------------------//
        case (inst_type)
            `R_TYPE: begin
                case (funct)
                    `ADD, `ADDU, `SUB, `SUBU,
                    `MULT, `MULTU, `DIV, `DIVU,
                    `AND, `OR, `XOR, `NOR,
                    `SLT, `SLTU,
                    `SLLV, `SRAV, `SRLV: begin
                        rs_read_en = `TRUE;
                        rt_read_en = `TRUE;
                        reg_write = `TRUE;
                        reg_write_src = `REG_W_SRC_ALU;
                        reg_write_dst = `REG_W_DST_RD;
                    end
                    `SLL, `SRA, `SRL: begin
                        rs_read_en = `FALSE;
                        rt_read_en = `TRUE;
                        reg_write = `TRUE;
                        reg_write_src = `REG_W_SRC_ALU;
                        reg_write_dst = `REG_W_DST_RD;
                    end
                    `JALR: begin // ALU: pc+4 -> [rd], pc <- [rs]
                        rs_read_en = `TRUE;
                        rt_read_en = `FALSE;
                        reg_write = `TRUE;
                        reg_write_src = `REG_W_SRC_PCA4;
                        reg_write_dst = `REG_W_DST_RD;
                    end
                    `JR: begin // pc <- [rs]
                        rs_read_en = `TRUE;
                        rt_read_en = `FALSE;
                        reg_write = `FALSE;
                    end
                    default: begin
                        rs_read_en = `FALSE;
                        rt_read_en = `FALSE;
                        reg_write = `FALSE;
                    end
                endcase
            end
            `I_TYPE: begin
                case (op_code)
                    `LB, `LBU, `LH, `LHU, `LW: begin // [rt] <- M[[rs]+imm]
                        rs_read_en = `TRUE;
                        rt_read_en = `TRUE;
                        reg_write = `TRUE;
                        reg_write_src = `REG_W_SRC_MEM;
                        reg_write_dst = `REG_W_DST_RT;
                    end
                    `SB, `SH, `SW: begin // M[[rs]+imm] <- [rt]
                        rs_read_en = `TRUE;
                        rt_read_en = `TRUE;
                        reg_write = `FALSE;
                    end
                    `ADDI, `ADDIU, `ANDI, `ORI,
                    `SLTI, `SLTIU, `XORI: begin // [rt] < func([rs], imm)
                        rs_read_en = `TRUE;
                        rt_read_en = `FALSE;
                        reg_write = `TRUE;
                        reg_write_src = `REG_W_SRC_ALU;
                        reg_write_dst = `REG_W_DST_RT;
                    end
                    `LUI: begin // [rt] <- imm | 0
                        rs_read_en = `FALSE;
                        rt_read_en = `FALSE;
                        reg_write = `TRUE;
                        reg_write_src = `REG_W_SRC_ALU;
                        reg_write_dst = `REG_W_DST_RT;
                    end
                    `BEQ, `BNE: begin // cmp [rs] [rt]
                        rs_read_en = `TRUE;
                        rt_read_en = `TRUE;
                        reg_write = `FALSE;
                    end
                    `BLEZ, `BGTZ, `BGEZ_BLTZ: begin // cmp [rs] 0
                        rs_read_en = `TRUE;
                        rt_read_en = `FALSE;
                        reg_write = `FALSE;
                    end
                    default: begin
                        rs_read_en = `FALSE;
                        rt_read_en = `FALSE;
                        reg_write = `FALSE;
                    end
                endcase
            end
            `J_TYPE: begin
                if (op_code == `JAL) begin
                    rs_read_en = `TRUE;
                    rt_read_en = `FALSE;
                    reg_write = `TRUE;
                    reg_write_src = `REG_W_SRC_PCA4;
                    reg_write_dst = `REG_W_DST_R31;
                end
            end
            default: begin
                rs_read_en = `FALSE;
                rt_read_en = `FALSE;
                reg_write = `FALSE;
            end
        endcase

        // MEM CTRL --------------------------------------------------//
        // Enables
        case (op_code)
            `LB, `LBU, `LH, `LHU, `LW: begin
                mem_read_en = `TRUE;
                mem_write_en = `FALSE;
            end
            `SB, `SH, `SW: begin
                mem_read_en = `FALSE;
                mem_write_en = `TRUE;
            end
            default: begin // Others don't attempt data memory
                mem_read_en = `FALSE;
                mem_write_en = `FALSE;
            end
        endcase
        // Modes
        case (op_code)
            `LB, `SB:   l_s_mode = `L_S_BYTE;
            `LBU:       l_s_mode = `L_S_BYTE_U;
            `LH, `SH:   l_s_mode = `L_S_HALF;
            `LHU:       l_s_mode = `L_S_HALF_U;
            `LW, `SW:   l_s_mode = `L_S_WORD;
            default:    l_s_mode = `L_S_WORD;
        endcase
    end
endmodule