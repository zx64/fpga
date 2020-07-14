`default_nettype none
`define ICEWERX

module top(
    input i_clock,
`ifdef ICEWERX
    output o_led_red,
    output o_led_green,
`else
    output [3:0] o_led_x,
    output [7:0] o_led_y,
`endif
);
    parameter CLOCKBIT = 24;
    reg [31:0] ctr;
    reg [31:0] ctr2;
    wire i_pllclock;

    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),
        .DIVF(7'b0111111),
        .DIVQ(3'b100),
        .FILTER_RANGE(3'b1)
    ) uut (
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .REFERENCECLK(i_clock),
        .PLLOUTCORE(i_pllclock)
    );


`ifdef ICEWERX
    assign o_led_red = ctr[CLOCKBIT];
    assign o_led_green = ctr2[CLOCKBIT];
`else
    assign o_led_x = 4'b0111;
    assign o_led_y = {~ctr[CLOCKBIT], ~ctr2[CLOCKBIT], 6'b111111};
`endif

    always @ (posedge i_clock)
    begin
        ctr <= ctr + 1;
    end

    always @ (posedge i_pllclock)
    begin
        ctr2 <= ctr2 + 1;
    end
endmodule
