`default_nettype none

module top(
    input clk_25mhz,
    output [7:0] led,
);
    reg [28:0] blip = 0;

    assign led[7:0] = blip[28:21];

    always @ (posedge clk_25mhz)
    begin
        blip <= blip + 1;
    end
endmodule
