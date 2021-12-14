// dbg_dmem.v: data memory instance for simulation

`include "defines.v"

module dbg_dmem #(
    parameter W = `WORD_WIDTH,
    parameter DMEM_SIZE = 65536
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
    initial begin
        $readmemh(`DMEM_SIM_FILE, mem);
    end

    // Write words that are aligned
    always @(posedge clk) begin
        if (rst) begin
            mem[write_addr[18:2]] <= `ZERO_WORD;
        end
        else if (write_en) begin
            mem[write_addr[18:2]] <= write_data;
        end
    end
    
    // Return words that are aligned
    always @(posedge clk) begin
        if (rst) begin
            read_data <= `ZERO_WORD;
        end
        else if (write_en && read_en && write_addr == read_addr) begin // Forward
            read_data <= write_data;
        end
        else if (read_en) begin
            read_data <= mem[read_addr[18:2]];
        end
    end
endmodule