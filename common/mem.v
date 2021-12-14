// mem.v: mem stage, simply forward

`include "defines.v"

module mem #(
    parameter W = `WORD_WIDTH
) (
    input wire mem_read_en, mem_write_en,
    input wire[W-1:0] mem_addr, // mem addr can only be alu_result (l, s)
    output wire[W-1:0] mem_write_data, mem_read_data,

    // CPU mem interface
    // Load
    output wire load_en,
    output wire[W-1:0] l_addr,
	input wire[W-1:0] l_data,
    // Store
	output wire store_en,
    output wire[W-1:0] s_addr,
	output wire[W-1:0] s_data
);
    assign load_en = mem_read_en, store_en = mem_write_en;
    assign l_addr = mem_addr, s_addr = mem_addr;
    assign mem_write_data = s_data, mem_read_data = l_data;
endmodule