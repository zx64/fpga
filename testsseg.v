`default_nettype none

module top(
    input clk_25mhz,
    output [7:0] led,
    inout [27:0] gp // lower row
);
    reg [22:0] clockdiv;
    reg [6:0] segment_select = 0;
    reg       digit_select = 0;
    reg [7:0] counter = 0;

    assign led[7:0] = counter;

    assign gp[14] = digit_select;
    assign {gp[24:21], gp[17:15]} = segment_select;

    reg [6:0] left_segs, right_segs;

    get_segs left(clk_25mhz, counter[4:7], left_segs);
    get_segs right(clk_25mhz, counter[0:3], right_segs);

    always @ (posedge clk_25mhz)
    begin
        clockdiv <= clockdiv + 1;

        case (clockdiv[0:2])
            0, 1: segment_select <= left_segs;
            2: segment_select <= 0;
            3: digit_select <= 0;
            4, 5: segment_select <= right_segs;
            6: segment_select <= 0;
            7: digit_select <= 1;
        endcase
    end

    always @ (posedge clockdiv[20])
    begin
        counter <= counter + 1;
    end
endmodule


module get_segs(
    input i_clock,
    input [3:0] i_value,
    output reg [6:0] o_segs
);

    always @ (posedge i_clock)
    begin
        case (i_value) //      ABCDEFG
            4'h0: o_segs <= 7'b1111110;
            4'h1: o_segs <= 7'b0110000;
            4'h2: o_segs <= 7'b1101101;
            4'h3: o_segs <= 7'b1111001;
            4'h4: o_segs <= 7'b0110011;
            4'h5: o_segs <= 7'b1011011;
            4'h6: o_segs <= 7'b1011111;
            4'h7: o_segs <= 7'b1110000;
            4'h8: o_segs <= 7'b1111111;
            4'h9: o_segs <= 7'b1111011;
            4'hA: o_segs <= 7'b1110111;
            4'hB: o_segs <= 7'b0011111;
            4'hC: o_segs <= 7'b1001110;
            4'hD: o_segs <= 7'b0111101;
            4'hE: o_segs <= 7'b1001111;
            4'hF: o_segs <= 7'b1000111;
        endcase
    end
endmodule

