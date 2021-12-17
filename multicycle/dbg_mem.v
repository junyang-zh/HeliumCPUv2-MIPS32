// dbg_mem.v: memory instance for simulation

`timescale 10ns/1ns

`include "defines.v"

module dbg_mem #(
    parameter W = `WORD_WIDTH,
    parameter DMEM_INDEX_W = 13,
    parameter DMEM_SIZE = 8192,
    parameter DATA_SEGMENT = `WORD_WIDTH'h10010000,// .data segment, "do the os job"
    parameter DATA_START = `WORD_WIDTH'd4096
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
    wire[W-1:0] read_addr_d = (read_addr & DATA_SEGMENT) ?
                                (read_addr - DATA_SEGMENT + { DATA_START, 2'b0 }):
                                read_addr;
    wire[W-1:0] write_addr_d = (write_addr & DATA_SEGMENT) ?
                                (write_addr - DATA_SEGMENT + { DATA_START, 2'b0 }):
                                write_addr;

    // Dump the memory for debug
    initial begin
        $readmemh(`IMEM_SIM_FILE, mem, 0);
        $readmemh(`DMEM_SIM_FILE, mem, DATA_START);
    end

    // Write words that are aligned
    always @(posedge clk) begin
        if (write_en) begin
            mem[write_addr_d[DMEM_INDEX_W+1:2]] <= write_data;
        end
    end
    
    // Return words that are aligned
    always @(*) begin
        if (read_en) begin
            read_data <= mem[read_addr_d[DMEM_INDEX_W+1:2]];
        end
    end
endmodule