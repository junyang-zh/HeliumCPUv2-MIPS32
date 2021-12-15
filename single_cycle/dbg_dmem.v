// dbg_dmem.v: data memory instance for simulation

`include "defines.v"

module dbg_dmem #(
    parameter W = `WORD_WIDTH,
    parameter DMEM_SIZE = 4096,
    parameter DATA_SEGMENT = `WORD_WIDTH'h10010000 // .data segment, "do the os job"
) (
    input wire clk, rst,

    input wire read_en,
    input wire[W-1:0] read_addr,
    output reg[W-1:0] read_data,

    input wire write_en,
    input wire[W-1:0] write_addr,
    input wire[W-1:0] write_data
);
    // Instruction memory addressed by bytes ends with 00
    reg[W-1:0] mem[DMEM_SIZE-1:0];

    // "virtual memory"
    wire[W-1:0] read_addr_d = read_addr - DATA_SEGMENT;
    wire[W-1:0] write_addr_d = write_addr - DATA_SEGMENT;
    initial begin
        $readmemh(`DMEM_SIM_FILE, mem);
    end

    // Write words that are aligned
    always @(posedge clk) begin
        if (write_en) begin
            mem[write_addr_d[18:2]] <= write_data;
        end
    end
    
    // Return words that are aligned
    always @(*) begin
        if (read_en) begin
            read_data <= mem[read_addr_d[18:2]];
        end
    end
endmodule