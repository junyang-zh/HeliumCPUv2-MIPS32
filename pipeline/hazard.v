// hazard.v: send bubble and stalls

`include "defines.v"

module hazard (
    input wire rst,

    input wire mem_ex_hazard, j_ctrl_hazard, branch_ctrl_hazard,
    output reg pc_stall, id_stall, if_id_flush, id_ex_bubble
);
    always @(*) begin
        if (rst) begin
            pc_stall <= `FALSE;
            id_stall <= `FALSE;
            if_id_flush <= `FALSE;
            id_ex_bubble <= `FALSE;
        end
        else begin
            id_ex_bubble <= mem_ex_hazard;
            pc_stall <= mem_ex_hazard;
            id_stall <= mem_ex_hazard;
        end
    end
endmodule