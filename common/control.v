module control (
    input wire[`OP_WIDTH-1:0] op_code,
    input wire[`FUNCT_WIDTH-1:0] funct,
    input wire[`REG_ADDR_W-1:0] rt,
    input wire[1:0] inst_type,

    output reg[`ALUOP_WIDTH-1:0] alu_op
    // TODO
);
    always @(*) begin
        case (inst_type)
            `R_TYPE: begin
                // Decide ALU OP
                case (funct)
                    `ADD, `ADDU:
                        alu_op = `ALU_ADD;
                    `SUB, `SUBU:
                        alu_op = `ALU_SUB;
                    `MULT, `MULTU:
                        alu_op = `ALU_MULT;
                    `DIV, `DIVU:
                        alu_op = `ALU_DIV;
                    `SLL, `SLLV:
                        alu_op = `ALU_SL;
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
                    default: alu_op = `ALUOP_ERR;
                endcase
            end
            `I_TYPE: begin
                // Decide ALU OP
                case (op_code)
                    `ADDI, `ADDIU:
                        alu_op = `ALU_ADD;
                    `ANDI:
                        alu_op = `ALU_AND;
                    `LUI: begin
                        alu_op = `ALU_SL;
                        // TODO: Shift 5'b10000
                    end
                    `ORI:
                        alu_op = `ALU_OR;
                    `SLTI:
                        alu_op = `ALU_L;
                    `SLTU:
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
            end
            `J_TYPE: begin
            end
            default: alu_op = `ALUOP_ERR;
        endcase
    end
endmodule