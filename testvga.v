`default_nettype none
`define ICEWERX
`include "2leds.v"

module top(
    input i_clock,
    `O_2LEDS
    output wire o_hsync,
    output wire o_vsync,
    output wire o_red,
    output wire o_green,
    output wire o_blue
);
    `W_2LEDS

    // 39.75MHz from 12MHz external clock
    wire i_pixclock;
    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(0),
        .DIVF(52),
        .DIVQ(4),
        .FILTER_RANGE(1)
    ) pll (
        .RESETB(1),
        .BYPASS(0),
        .REFERENCECLK(i_clock),
        .PLLOUTCORE(i_pixclock)
    );

    // http://www.tinyvga.com/vga-timing/800x600@60Hz
    parameter HOR_FRONT_PORCH = 16'd800;
    parameter HOR_SYNC_PULSE = HOR_FRONT_PORCH + 16'd40;
    parameter HOR_BACK_PORCH = HOR_SYNC_PULSE + 16'd128;
    parameter HOR_MAX = HOR_BACK_PORCH + 16'd88;
    reg [16:0] o_hsync_counter = 0;

    parameter VER_FRONT_PORCH = 16'd600;
    parameter VER_SYNC_PULSE = VER_FRONT_PORCH + 16'd1;
    parameter VER_BACK_PORCH = VER_SYNC_PULSE + 16'd4;
    parameter VER_MAX = VER_BACK_PORCH + 16'd23;
    reg [16:0] o_vsync_counter = 0;

    reg [4:0] o_flipframe;

    assign {o_2LEDA, o_2LEDB} = o_flipframe[4:2];

    wire o_enable = (o_hsync_counter < HOR_FRONT_PORCH) && (o_vsync_counter < VER_FRONT_PORCH);
    assign o_hsync = (o_hsync_counter < HOR_SYNC_PULSE) || (o_hsync_counter > HOR_SYNC_PULSE);
    assign o_vsync = (o_vsync_counter < VER_SYNC_PULSE) || (o_vsync_counter > VER_SYNC_PULSE);

    assign o_red = o_enable;
    assign o_green = o_enable & (o_hsync_counter < 16'd400);
    assign o_blue = o_enable & (o_vsync_counter < 16'd300);

    always @ (posedge i_pixclock)
    begin
        if (o_hsync_counter == HOR_MAX)
        begin
            o_hsync_counter <= 0;
            if (o_vsync_counter == VER_MAX)
            begin
                o_vsync_counter <= 0;
                o_flipframe <= o_flipframe + 2'd1;
            end
            else
            begin
                o_vsync_counter <= o_vsync_counter + 16'd1;
            end
        end
        else
        begin
            o_hsync_counter <= o_hsync_counter + 16'd1;
        end
    end
endmodule
