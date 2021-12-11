`include "defines.v"

module top #(
    parameter W = `WORD_WIDTH
) (
    input wire clk, rst
);
    wire[W-1:0] pc, inst, l_addr, l_data, s_addr, s_data;
    wire load_en, store_en;
    cpu cpu_inst(
        .clk(clk), .rst(rst),
        .pc(pc),
        .inst(inst),
        .load_en(load_en),
        .l_addr(l_addr),
        .l_data(l_data),
        .store_en(store_en),
        .s_addr(s_addr),
        .s_data(s_data)
    );
endmodule