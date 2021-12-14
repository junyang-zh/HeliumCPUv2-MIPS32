// dbg_dmem.v: instruction memory instance for simulation

`include "defines.v"

module dbg_imem #(
    parameter W = `WORD_WIDTH,
    parameter IMEM_SIZE = 1024
) (
    input wire clk, rst,
    input wire[W-1:0] addr,
    output reg[W-1:0] data
);
    // Instruction memory can only be addressed by words
    reg[W-1:0] mem[IMEM_SIZE-1:0];
    
    initial begin
        $readmemh(`IMEM_SIM_FILE, mem);
        /* Display the read file
        for (integer i = 0; i <= 7; i = i + 1)
		    $display("%h", mem[i]);
        */
    end

    always @(posedge clk) begin
        if (!rst) begin
            data <= mem[addr[12:2]];
        end
    end
endmodule