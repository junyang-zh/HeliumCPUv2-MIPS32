// regfile.v: execution stage

`include "defines.v"

module regfile #(
    parameter RW = `REG_ADDR_W,
    parameter W = `WORD_WIDTH
) (
    input wire clk, rst,
    // Outputs: rs, rt
    input wire rs_en,
    input wire[RW-1:0] rs_addr,
    output reg[W-1:0] rs_data,
    input wire rt_en,
    input wire[RW-1:0] rt_addr,
    output reg[W-1:0] rt_data,
    // Inputs: rd
    input wire write_en,
    input wire[RW-1:0] rd_addr,
    input wire[W-1:0] rd_data
);
    // The regfile, r0 will always be zero thus not used
    reg[W-1:0] regs[W-1:0];

    wire[W-1:0] dbg21 = regs[`REG_ADDR_W'd21];

    // Write rd
    always @(negedge clk) begin
        if (!rst && write_en && rd_addr != `REG_ZERO) begin
            regs[rd_addr] <= rd_data;
        end
    end
    // Read rs
    always @(*) begin
        if (rst || rs_addr == `REG_ZERO) begin
            rs_data = `ZERO_WORD;
        end
        else if (rs_en) begin
            rs_data <= regs[rs_addr];
        end
        else begin
            rs_data = `ZERO_WORD;
        end
    end
    // Read rt
    always @(*) begin
        if (rst || rt_addr == `REG_ZERO) begin
            rt_data = `ZERO_WORD;
        end
        else if (rt_en) begin
            rt_data <= regs[rt_addr];
        end
        else begin
            rt_data = `ZERO_WORD;
        end
    end
endmodule