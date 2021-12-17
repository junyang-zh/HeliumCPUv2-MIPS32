`include "defines.v"

module top #(
    parameter W = `WORD_WIDTH
) (
    input wire clk, rst
);
    wire[W-1:0] pc, inst, l_addr, l_data, s_addr, s_data;
    wire pc_clk, load_clk, load_en, store_clk, store_en;

    cpu cpu_inst(
        .clk(clk), .rst(rst),
        .pc_clk(pc_clk),
        .pc(pc),
        .read_inst(inst),
        .load_clk(load_clk),
        .load_en(load_en),
        .l_addr(l_addr),
        .l_data(l_data),
        .store_clk(store_clk),
        .store_en(store_en),
        .s_addr(s_addr),
        .s_data(s_data)
    );

    dbg_imem imem(
        .clk(~pc_clk), .rst(rst), // negedge
        .addr(pc),
        .data(inst)
    );

    dbg_dmem dmem(
        .clk(~(load_clk | store_clk)), // negedge
        .rst(rst),
        .read_en(load_en),
        .read_addr(l_addr),
        .read_data(l_data),
        .write_en(store_en),
        .write_addr(s_addr),
        .write_data(s_data)
    );
endmodule