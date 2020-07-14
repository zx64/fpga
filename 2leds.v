`ifdef ICEWERX
`define O_2LEDS output o_led_red, output o_led_green,
`define W_2LEDS wire o_2LEDA, o_2LEDB; assign {o_led_red, o_led_green} = {o_2LEDA, o_2LEDB};
`else
`define O_2LEDS output [3:0] o_led_x, output [7:0] o_led_y,
`define W_2LEDS wire o_2LEDA, o_2LEDB; assign o_led_x = 4'b0111; assign o_led_y = {~o_2LEDA, ~o_2LEDB, 6'b111111};
`endif
