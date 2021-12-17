// control_regs.v: id-ex, ex-mem, mem-wb interstages registers

`include "defines.v"

module ctrl_regs #(
    parameter TOT_BITS = 128 // Find a nice way to overload!
) (
    input wire clk, rst,
    input wire[TOT_BITS-1:0] ctrl_in,
    output reg[TOT_BITS-1:0] ctrl_out
);
    always @(*) begin   // Async reset
        if (rst) begin
            ctrl_out = 0;
        end
    end

    always @(posedge clk) begin
        if (!rst) begin
            ctrl_out <= ctrl_in;
        end
    end
endmodule