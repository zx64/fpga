`default_nettype none

`include "ledmatrix.v"

module top(
    input i_clock,
    output [3:0] o_led_x,
    output [7:0] o_led_y
);
    reg [20:0] counter0 = 0;
    reg [19:0] counter1 = 0;
    reg [18:0] counter2 = 0;
    reg [17:0] counter3 = 0;

    reg [31:0] img0 = 32'h01234567;
    reg [31:0] img1 = 32'h89ABCDEF;
    reg [31:0] img2 = 32'h76543210;
    reg [31:0] img3 = 32'hFEDCBA98;
    wire [7:0] row0;
    wire [7:0] row1;
    wire [7:0] row2;
    wire [7:0] row3;

    ScanPWM pwm0(.i_clock(i_clock), .i_levels(img0), .o_bits(row0));
    ScanPWM pwm1(.i_clock(i_clock), .i_levels(img1), .o_bits(row1));
    ScanPWM pwm2(.i_clock(i_clock), .i_levels(img2), .o_bits(row2));
    ScanPWM pwm3(.i_clock(i_clock), .i_levels(img3), .o_bits(row3));

    LedMatrix matrix(
        .i_clock(i_clock),
        .i_row0(row0), .i_row1(row1), .i_row2(row2), .i_row3(row3),
        .o_row_enable(o_led_y), .o_column_enable(o_led_x)
    );

    always @ (posedge i_clock)
    begin
        counter0 <= counter0 + 1;
        counter1 <= counter1 + 1;
        counter2 <= counter2 + 1;
        counter3 <= counter3 + 1;
        if (counter0 == 0)
        begin
            img0[ 3 :  0] <= img0[ 3 :  0] + 1;
            img0[ 7 :  4] <= img0[ 7 :  4] + 1;
            img0[11 :  8] <= img0[11 :  8] + 1;
            img0[15 : 12] <= img0[15 : 12] + 1;
            img0[19 : 16] <= img0[19 : 16] + 1;
            img0[23 : 20] <= img0[23 : 20] + 1;
            img0[27 : 24] <= img0[27 : 24] + 1;
            img0[31 : 28] <= img0[31 : 28] + 1;
        end

        if (counter1 == 0)
        begin
            img1[ 3 :  0] <= img1[ 3 :  0] + 1;
            img1[ 7 :  4] <= img1[ 7 :  4] + 1;
            img1[11 :  8] <= img1[11 :  8] + 1;
            img1[15 : 12] <= img1[15 : 12] + 1;
            img1[19 : 16] <= img1[19 : 16] + 1;
            img1[23 : 20] <= img1[23 : 20] + 1;
            img1[27 : 24] <= img1[27 : 24] + 1;
            img1[31 : 28] <= img1[31 : 28] + 1;
        end

        if (counter2 == 0)
        begin
            img2[ 3 :  0] <= img2[ 3 :  0] + 1;
            img2[ 3 :  0] <= img2[ 3 :  0] + 1;
            img2[ 7 :  4] <= img2[ 7 :  4] + 1;
            img2[11 :  8] <= img2[11 :  8] + 1;
            img2[15 : 12] <= img2[15 : 12] + 1;
            img2[19 : 16] <= img2[19 : 16] + 1;
            img2[23 : 20] <= img2[23 : 20] + 1;
            img2[27 : 24] <= img2[27 : 24] + 1;
            img2[31 : 28] <= img2[31 : 28] + 1;
        end

        if (counter3 == 0)
        begin
            img3[ 7 :  4] <= img3[ 7 :  4] + 1;
            img3[11 :  8] <= img3[11 :  8] + 1;
            img3[15 : 12] <= img3[15 : 12] + 1;
            img3[19 : 16] <= img3[19 : 16] + 1;
            img3[23 : 20] <= img3[23 : 20] + 1;
            img3[27 : 24] <= img3[27 : 24] + 1;
            img3[31 : 28] <= img3[31 : 28] + 1;
        end
    end
endmodule
