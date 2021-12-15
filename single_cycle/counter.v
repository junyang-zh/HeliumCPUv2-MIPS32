// counter.v: generate sub cycles

module counter #(
    parameter COUNTER_W = 3,
    parameter N = 3'd5
) (
    input wire clk, rst,
    output wire if_clk, id_clk, ex_clk, mem_clk, wb_clk
);
    reg[COUNTER_W-1:0] count;
    reg[N-1:0] clks;

    always @(posedge clk) begin
        clks = 0;
        if (rst) begin
            count = 0;
        end
        else begin
            count = count + 1;
            if (count == N) begin
                count = 0;
            end
        end
        clks[count] = 1;
    end

    always @(negedge clk) begin
        clks = 0;
    end

    assign { wb_clk, mem_clk, ex_clk, id_clk, if_clk } = clks;
endmodule