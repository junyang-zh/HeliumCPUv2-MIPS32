// decoder.v: instruction fetch stage

`include "defines.v"

module decoder #(
    parameter W = `WORD_WIDTH
) (
    // input wire clk, rst, now not used
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
                // Decide imm for shift inst
                case (op_code)
                    `SLL, `SRA:
                        // Zero extend s
                        imm = { {27{1'b0}}, inst[10:6] };
                    default: imm = `ZERO_WORD;
                endcase
            end
            `I_TYPE: begin
                rs <= inst[25:21];
                rt <= inst[20:16];
                // Decide the extend method of imm
                case (op_code)
                    `LB, `LBU, `LH, `LHU, `LW, `SB, `SH, `SW,   // s_ext(data_offset)
                    `ADDI, `ANDI, `ORI, `SLTI, `XORI:           // s_ext(immediate)
                        imm = { {16{inst[15]}}, inst[15:0] };
                    `BEQ, `BNE, `BLEZ, `BGTZ, `BGEZ_BLTZ:       // s_ext(inst_offset<<2)
                        imm = { {14{inst[15]}}, inst[15:0], 2'b0 };
                    `LUI: // Do the shift and fill here
                        imm = { inst[15:0], {16{1'b0}} };
                    `ADDIU, `SLTIU:
                        imm = { {16{1'b0}}, inst[15:0] };
                    default: imm = `ZERO_WORD;
                endcase
            end
            `J_TYPE: begin // jump to imm
                imm <= { 4'b0 , inst[25:0], 2'b0 };
            end
            default: op_code = `OP_ERR;
        endcase
    end

endmodule