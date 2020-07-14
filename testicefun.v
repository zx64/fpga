`default_nettype none

`include "ledmatrix.v"

module top(
    input i_clock,
    input  [3:0] i_button,
    output [3:0] o_led_x,
    output [7:0] o_led_y
);
    parameter FASTMSB = 20;
    reg [FASTMSB:0] fast_counter = 0;
    reg [31:0] slow_counter = 32'b0;

    reg [7:0] i_rows0, i_rows1, i_rows2, i_rows3;

    LedMatrix matrix(
        .i_clock(i_clock),
        .i_row0(i_rows0),
        .i_row1(i_rows1),
        .i_row2(i_rows2),
        .i_row3(i_rows3),
        .o_row_enable(o_led_y),
        .o_column_enable(o_led_x)
    );

    always @ (posedge i_clock)
    begin
        if (fast_counter == 0)
        begin
            slow_counter <= slow_counter + 1;
`define GRID
`ifdef GRID
            if ((slow_counter & 1) == 0)
            begin
                i_rows0[7:0] <= 8'b10101010;
                i_rows1[7:0] <= 8'b01010101;
                i_rows2[7:0] <= 8'b10101010;
                i_rows3[7:0] <= 8'b01010101;
            end
            else
            begin
                i_rows0[7:0] <= 8'b01010101;
                i_rows1[7:0] <= 8'b10101010;
                i_rows2[7:0] <= 8'b01010101;
                i_rows3[7:0] <= 8'b10101010;
            end
`else
            i_rows3[7:0] <= ~slow_counter[7:0];
            i_rows2[7:0] <= ~slow_counter[15:8];
            i_rows1[7:0] <= ~slow_counter[23:16];
            i_rows0[7:0] <= ~slow_counter[31:24];
`endif
        end
        fast_counter <= fast_counter + 1;
    end
endmodule
