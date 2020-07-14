`default_nettype none
`define ICEWERX
`include "2leds.v"

module top(
    input i_clock,
    `O_2LEDS
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


    `W_2LEDS
    assign {o_2LEDA, o_2LEDB} = {ctr[CLOCKBIT], ctr2[CLOCKBIT]};

    always @ (posedge i_clock)
    begin
        ctr <= ctr + 1;
    end

    always @ (posedge i_pllclock)
    begin
        ctr2 <= ctr2 + 1;
    end
endmodule
