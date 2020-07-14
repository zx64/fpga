`default_nettype none
//`define ICEWERX
`include "2leds.v"

module top(
    input wire i_clock,
`ifdef ICEWERX
`else
    input wire i_btn_reset,
`endif
    `O_2LEDS
    output o_hsync,
    output o_vsync,
    output o_red,
    output o_green,
    output o_blue
);
    `W_2LEDS

    wire i_pixclock;
    wire i_pixlocked;
    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(0),
        .DIVF(52),
        .DIVQ(4),
        .FILTER_RANGE(1)
    ) pll (
`ifdef ICEWERX
        .RESETB(1),
`else
        .RESETB(i_btn_reset),
`endif
        .BYPASS(0),
        .REFERENCECLK(i_clock),
        .PLLOUTCORE(i_pixclock),
        .LOCK(i_pixlocked)
    );

    parameter HOR_FRONT_PORCH = 799;
    parameter HOR_SYNC_PULSE = HOR_FRONT_PORCH + 40;
    parameter HOR_BACK_PORCH = HOR_SYNC_PULSE + 128;
    parameter HOR_MAX = HOR_BACK_PORCH + 88;
    reg [11:0] o_hsync_counter = 0;

    parameter VER_FRONT_PORCH = 599;
    parameter VER_SYNC_PULSE = VER_FRONT_PORCH + 1;
    parameter VER_BACK_PORCH = VER_SYNC_PULSE + 4;
    parameter VER_MAX = 627;
    reg [11:0] o_vsync_counter = 0;

    reg [4:0] o_flipframe;

    assign {o_2LEDA, o_2LEDB} = o_flipframe[4:2];

    assign o_hsync = ~(o_hsync_counter >= HOR_SYNC_PULSE && o_hsync_counter < HOR_BACK_PORCH);
    assign o_vsync = ~(o_vsync_counter >= VER_SYNC_PULSE && o_vsync_counter < VER_BACK_PORCH);
    wire o_enable = (o_hsync_counter <= HOR_FRONT_PORCH) && (o_vsync_counter <= VER_FRONT_PORCH);

    assign o_red = o_enable & ((o_hsync_counter < 200) || (o_hsync_counter > 650));
    assign o_green = o_enable & (o_hsync_counter >= 150) && (o_hsync_counter < 400);
    assign o_blue = o_enable & (o_hsync_counter >= 350) && (o_vsync_counter[2]);

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
                o_vsync_counter <= o_vsync_counter + 1;
            end
        end
        else
        begin
            o_hsync_counter <= o_hsync_counter + 1;
        end
        if (!i_pixlocked)
        begin
            o_vsync_counter <= 0;
            o_hsync_counter <= 0;
        end
    end
endmodule
