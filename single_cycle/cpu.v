`include "defines.v"

module cpu #(
    parameter W = `WORD_WIDTH
) (
    // Clock and reset signals
	input wire clk, rst,
    // Program counter and fetched instruction
	output wire[W-1:0] pc,
	input wire[W-1:0] inst,
    // Load
    output wire load_en,
    output wire[W-1:0] l_addr,
	input wire[W-1:0] l_data,
    // Store
	output wire store_en,
    output wire[W-1:0] s_addr,
	output wire[W-1:0] s_data
);
    assign s_data = l_data;
endmodule