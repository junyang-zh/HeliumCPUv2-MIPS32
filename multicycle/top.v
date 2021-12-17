`include "defines.v"

module top #(
    parameter W = `WORD_WIDTH
) (
    input wire clk, rst
);
    wire[W-1:0] pc, inst, l_addr, l_data, s_addr, s_data;
    wire pc_clk, pc_en, load_clk, load_en, store_clk, store_en;

    cpu cpu_inst(
        .clk(clk), .rst(rst),
        .pc_clk(pc_clk),
        .pc(pc), .pc_en(pc_en),
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

    wire[W-1:0] mem_read_addr = (pc_en ? pc : l_addr);
    wire[W-1:0] mem_read_data;
    wire mem_clk = ~store_clk; // Negedge write

    dbg_mem mem_inst(
        .clk(mem_clk),
        .rst(rst),
        .read_en(load_en | pc_en),
        .read_addr(mem_read_addr),
        .read_data(mem_read_data),
        .write_en(store_en),
        .write_addr(s_addr),
        .write_data(s_data)
    );

    assign inst = mem_read_data, l_data = mem_read_data;
endmodule