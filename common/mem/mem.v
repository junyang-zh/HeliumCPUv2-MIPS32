// mem.v: mem stage, simply forward

`include "defines.v"

module mem #(
    parameter W = `WORD_WIDTH,
    parameter HW = `HALF_WORD_WIDTH,
    parameter BW = `BYTE_WIDTH
) (
    input wire clk, rst,

    input wire mem_read_en, mem_write_en,
    input wire[W-1:0] mem_addr, // mem addr can only be alu_result (l, s)
    input wire[`L_S_MODE_W-1:0] l_s_mode,
    input wire[W-1:0] mem_write_data,
    output reg[W-1:0] mem_read_data,

    // CPU mem interface
    // Load
    output reg load_en,
    output reg[W-1:0] l_addr,
	input wire[W-1:0] l_data,
    // Store
	output reg store_en,
    output reg[W-1:0] s_addr,
	output reg[W-1:0] s_data
);
    always @(*) begin           // Async rst
        if (rst) begin
            load_en <= `FALSE;
            store_en <= `FALSE;
        end
    end

    always @(posedge clk) begin // Posedge query / write
        case (l_s_mode)
            `L_S_WORD: begin
                s_data <= mem_write_data;
            end
            `L_S_HALF: begin // sign extend half word
                s_data <= { {HW{mem_write_data[HW-1]}}, mem_write_data[HW-1:0] };
            end
            `L_S_HALF_U: begin // zero extend half word
                s_data <= { {HW{1'b0}}, mem_write_data[HW-1:0] };
            end
            `L_S_BYTE: begin // sign extend byte
                s_data <= { {W-BW{mem_write_data[BW-1]}}, mem_write_data[BW-1:0] };
            end
            `L_S_BYTE_U: begin // zero extend byte
                s_data <= { {W-BW{1'b0}}, mem_write_data[BW-1:0] };
            end
            default: begin
                s_data <= `ZERO_WORD;
            end
        endcase
        load_en <= mem_read_en;
        store_en <= mem_write_en;
        l_addr <= mem_addr;
        s_addr <= mem_addr;
    end

    always @(negedge clk) begin // Negedge read / forward
        if (load_en && store_en && l_addr == s_addr) begin
            mem_read_data <= s_data;
        end
        else case (l_s_mode)
            `L_S_WORD: begin
                mem_read_data <= l_data;
            end
            `L_S_HALF: begin // sign extend half word
                mem_read_data <= { {HW{l_data[HW-1]}}, l_data[HW-1:0] };
            end
            `L_S_HALF_U: begin // zero extend half word
                mem_read_data <= { {HW{1'b0}}, l_data[HW-1:0] };
            end
            `L_S_BYTE: begin // sign extend byte
                mem_read_data <= { {W-BW{l_data[BW-1]}}, l_data[BW-1:0] };
            end
            `L_S_BYTE_U: begin // zero extend byte
                mem_read_data <= { {W-BW{1'b0}}, l_data[BW-1:0] };
            end
            default: begin
                mem_read_data <= `ZERO_WORD;
            end
        endcase
    end
endmodule