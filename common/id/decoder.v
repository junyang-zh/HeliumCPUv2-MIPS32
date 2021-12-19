// decoder.v: instruction fetch stage

`include "defines.v"

module decoder #(
    parameter W = `WORD_WIDTH
) (
    input wire clk, rst,
    input wire stall, bubble,   // for pipeline
    input wire[W-1:0] inst,

    output reg[1:0] inst_type,
    // R, I, J
    output reg[`OP_WIDTH-1:0] op_code,
    output reg[`FUNCT_WIDTH-1:0] funct,
    // R, I
    output reg[`REG_ADDR_W-1:0] rs, rt,
    // I, J (imm is j_addr)
    output reg[W-1:0] imm,
    // R
    output reg[`REG_ADDR_W-1:0] rd,
    output reg[`WORD_INDEX_W-1:0] shamt,

    // Control signals, see control.v
    output wire[`ALUOP_WIDTH-1:0] alu_op,
    output wire[`ALU_SRC_WIDTH-1:0] alu_op1_src,
    output wire[`ALU_SRC_WIDTH-1:0] alu_op2_src,
    output wire can_branch,
    output wire jump,
    output wire targ_else_offset,
    output wire pc_addr_src_reg,
    output wire rs_read_en, rt_read_en, reg_write,
    output wire[`REG_W_SRC_WIDTH-1:0] reg_write_src,
    output reg[`REG_ADDR_W-1:0] reg_write_addr,
    output wire mem_read_en, mem_write_en,
    output wire[`L_S_MODE_W-1:0] l_s_mode
);

    always @(posedge clk) begin
        if (!stall) begin
            // Get OP code
            op_code = inst[W-1:W-`OP_WIDTH];
            // Decide instruction type
            case (op_code)
                `R_R:
                    inst_type = `R_TYPE;
                `J,
                `JAL:
                    inst_type = `J_TYPE;
                default:
                    inst_type = `I_TYPE;
            endcase
            // Decoding
            case (inst_type)
                `R_TYPE: begin
                    rs <= inst[25:21];
                    rt <= inst[20:16];
                    rd <= inst[15:11];
                    shamt <= inst[10:6];
                    funct <= inst[5:0];
                    // Decide imm for shift inst
                    case (op_code)
                        `SLL, `SRA:
                            // Zero extend s
                            imm <= { {27{1'b0}}, inst[10:6] };
                        default: imm <= `ZERO_WORD;
                    endcase
                end
                `I_TYPE: begin
                    rs <= inst[25:21];
                    rt <= inst[20:16];
                    // Decide the extend method of imm
                    case (op_code)
                        `LB, `LBU, `LH, `LHU, `LW, `SB, `SH, `SW,   // s_ext(data_offset)
                        `ADDI, `ANDI, `ORI, `SLTI, `XORI:           // s_ext(immediate)
                            imm <= { {16{inst[15]}}, inst[15:0] };
                        `BEQ, `BNE, `BLEZ, `BGTZ, `BGEZ_BLTZ:       // s_ext(inst_offset<<2)
                            imm <= { {14{inst[15]}}, inst[15:0], 2'b0 };
                        `LUI: // Do the shift and fill here
                            imm <= { inst[15:0], {16{1'b0}} };
                        `ADDIU, `SLTIU:
                            imm <= { {16{1'b0}}, inst[15:0] };
                        default: imm <= `ZERO_WORD;
                    endcase
                end
                `J_TYPE: begin // jump to imm
                    imm <= { 4'b0 , inst[25:0], 2'b0 };
                end
                default: begin
                    rs <= `REG_ZERO;
                    rt <= `REG_ZERO;
                    rd <= `REG_ZERO;
                    shamt <= `WORD_INDEX_W'd0;
                    funct <= `FUNCT_WIDTH'd0;
                    imm <= `ZERO_WORD;
                end
            endcase
        end
    end


    // Control module
    
    wire[`REG_W_DST_WIDTH-1:0] reg_write_dst;

    control control_inst(
        .rst(rst), .bubble(bubble),

        .op_code(op_code),
        .funct(funct),
        .rt(rt),
        .inst_type(inst_type),
        
        .alu_op(alu_op),
        .alu_op1_src(alu_op1_src),
        .alu_op2_src(alu_op2_src),
        
        .can_branch(can_branch),
        .jump(jump),
        .targ_else_offset(targ_else_offset),
        .pc_addr_src_reg(pc_addr_src_reg),

        .rs_read_en(rs_read_en), .rt_read_en(rt_read_en), .reg_write(reg_write),
        .reg_write_src(reg_write_src),
        .reg_write_dst(reg_write_dst),

        .mem_read_en(mem_read_en), .mem_write_en(mem_write_en),
        .l_s_mode(l_s_mode)
    );

    // generate register write destination

    always @(*) case (reg_write_dst)
        `REG_W_DST_RD:
            reg_write_addr = rd;
        `REG_W_DST_RT:
            reg_write_addr = rt;
        `REG_W_DST_R31:
            reg_write_addr = `REG_ADDR_W'd31;
        default: reg_write_addr = `REG_ADDR_W'b0;
    endcase

endmodule