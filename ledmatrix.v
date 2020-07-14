`default_nettype none
`ifdef ICEWERX
`error_unsupported_board
`endif

module LedMatrix(input i_clock,
    input  [7:0] i_row0,
    input  [7:0] i_row1,
    input  [7:0] i_row2,
    input  [7:0] i_row3,
    output reg [3:0] o_column_enable,
    output reg [7:0] o_row_enable
);
    parameter TIMERMSB = 16;
    reg [TIMERMSB:0] timer = 0;

    always @ (posedge i_clock)
    begin
        timer <= timer + 1;
        case (timer[TIMERMSB:TIMERMSB-1])
        2'b00:
        begin
            o_row_enable <= i_row0;
            o_column_enable <= 4'b1110;
        end
        2'b01:
        begin
            o_row_enable <= i_row1;
            o_column_enable <= 4'b1101;
        end
        2'b10:
        begin
            o_row_enable <= i_row2;
            o_column_enable <= 4'b1011;
        end
        2'b11:
        begin
            o_row_enable <= i_row3;
            o_column_enable <= 4'b0111;
        end
        endcase
    end
endmodule

module ScanPWM(input i_clock,
    input  [31:0] i_levels,
    output [7:0] o_bits,
);
    reg [7:0] pwm_timer = 0;
    assign o_bits = (
          ((pwm_timer < i_levels[ 3 :  0]) ? 8'b1111_1110 : 8'b1111_1111)
        & ((pwm_timer < i_levels[ 7 :  4]) ? 8'b1111_1101 : 8'b1111_1111)
        & ((pwm_timer < i_levels[11 :  8]) ? 8'b1111_1011 : 8'b1111_1111)
        & ((pwm_timer < i_levels[15 : 12]) ? 8'b1111_0111 : 8'b1111_1111)
        & ((pwm_timer < i_levels[19 : 16]) ? 8'b1110_1111 : 8'b1111_1111)
        & ((pwm_timer < i_levels[23 : 20]) ? 8'b1101_1111 : 8'b1111_1111)
        & ((pwm_timer < i_levels[27 : 24]) ? 8'b1011_1111 : 8'b1111_1111)
        & ((pwm_timer < i_levels[31 : 28]) ? 8'b0111_1111 : 8'b1111_1111)
    );

    always @ (posedge i_clock)
    begin
        pwm_timer <= pwm_timer + 1;
    end
endmodule
