`include "defines.v"

module decoder #(
    parameter W = `WORD_WIDTH
) (
    input wire clk, rst,
    input wire[W-1:0] inst,

    output reg[1:0] inst_type,
    // R, I, J
    output reg[`OP_WIDTH-1:0] op_code,
    output reg[`FUNCT_WIDTH-1:0] funct,
    // J
    output reg[`J_ADDR_WIDTH-1:0] j_addr,
    // R, I
    output reg[`REG_ADDR_W-1:0] rs, rt,
    // I
    output reg[W-1:0] imm,
    // R
    output reg[`REG_ADDR_W-1:0] rd,
    output reg[`WORD_INDEX_W-1:0] shamt
);
    // All combinational logic
    always @(*) begin
        // Get OP code
        op_code = inst[W-1:W-`OP_WIDTH];
        // Decide instruction type
        casez (op_code)
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
            end
            `I_TYPE: begin
                rs <= inst[25:21];
                rt = inst[20:16];
                // Decide the extend method of imm
                case (op_code)
                    `LW, `SW, `ADDI, `ANDI, `LUI, `ORI, `SLTI, `XORI,
                    `BEQ, `BNE, `BLEZ, `BGTZ, `BGEZ_BLTZ:
                        imm = { {16{inst[15]}}, inst[15:0] };
                    `ADDIU, `SLTU:
                        imm = { {16{1'b0}}, inst[15:0] };
                    default: imm = `ZERO_WORD;
                endcase
            end
            `J_TYPE: begin
                j_addr <= inst[25:0];
            end
            default: op_code = `OP_ERR;
        endcase
    end

endmodule