`default_nettype none
//`define ICEWERX
`include "2leds.v"

`define VGA1600

`ifdef VGA640
// 25.125MHz
`define CLKF 66
`define CLKQ 5
`define HPIX 640
`define HFP  16
`define HSP  96
`define HBP  48
`define VPIX 480
`define VFP  10
`define VSP  2
`define VBP  33
`endif

`ifdef VGA800
// 39.75MHz
`define CLKF 52
`define CLKQ 4
`define HPIX 800
`define HFP  40
`define HSP  128
`define HBP  88
`define VPIX 600
`define VFP  1
`define VSP  4
`define VBP  23
`endif

`ifdef VGA1024
// 65.25MHz
`define CLKF 86
`define CLKQ 4
`define HPIX 1024
`define HFP  24
`define HSP  136
`define HBP  160
`define VPIX 768
`define VFP  3
`define VSP  6
`define VBP  29
`endif

`ifdef VGA1152
// 81MHz
`define CLKF 53
`define CLKQ 3
`define HPIX 1152
`define HFP  64
`define HSP  120
`define HBP  184
`define VPIX 864
`define VFP  1
`define VSP  3
`define VBP  27
`endif

`ifdef VGA1280
// 108MHz
`define CLKF 71
`define CLKQ 3
`define HPIX 1280
`define HFP  48
`define HSP  112
`define HBP  248
`define VPIX 1024
`define VFP  1
`define VSP  3
`define VBP  38
`endif

`ifdef VGA1600
// 162MHz
`define CLKF 53
`define CLKQ 2
`define HPIX 1600
`define HFP  64
`define HSP  192
`define HBP  304
`define VPIX 1200
`define VFP  1
`define VSP  3
`define VBP  46
`endif

`ifndef HPIX
`error No resolution set
`endif

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
        .DIVF(`CLKF),
        .DIVQ(`CLKQ),
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

    parameter HOR_FRONT_PORCH = `HPIX;
    parameter HOR_SYNC_PULSE = HOR_FRONT_PORCH + `HFP;
    parameter HOR_BACK_PORCH = HOR_SYNC_PULSE + `HSP;
    parameter HOR_MAX = HOR_BACK_PORCH + `HBP;
    reg [11:0] o_hsync_counter = 0;

    parameter VER_FRONT_PORCH = `VPIX;
    parameter VER_SYNC_PULSE = VER_FRONT_PORCH + `VFP;
    parameter VER_BACK_PORCH = VER_SYNC_PULSE + `VSP;
    parameter VER_MAX = VER_BACK_PORCH + `VBP;
    reg [11:0] o_vsync_counter = 0;


    parameter HBAR = `HPIX / 6;

    reg [4:0] o_flipframe;

    assign {o_2LEDA, o_2LEDB} = o_flipframe[4:2];

    assign o_hsync = ~(o_hsync_counter >= HOR_SYNC_PULSE && o_hsync_counter < HOR_BACK_PORCH);
    assign o_vsync = ~(o_vsync_counter >= VER_SYNC_PULSE && o_vsync_counter < VER_BACK_PORCH);
    wire o_enable = (o_hsync_counter <= HOR_FRONT_PORCH) && (o_vsync_counter <= VER_FRONT_PORCH);

    assign o_red   = o_enable & ((o_hsync_counter < (2 * HBAR)) || (o_hsync_counter > (5 * HBAR)));
    assign o_green = o_enable &  (o_hsync_counter < (4 * HBAR)) && (o_hsync_counter > (1 * HBAR));
    assign o_blue  = o_enable &  (o_hsync_counter > (3 * HBAR));

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
