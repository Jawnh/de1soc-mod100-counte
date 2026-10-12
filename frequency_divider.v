//==============================================================
// frequency_divider.v
// EEL 3705L Final Project - Frequency Divider
//
// Port names and parameter match the top-level schematic block:
//
//        +---------------------+
//        |  frequency_divider  |
//   -----| clk_50MHz   clk_4Hz |-----
//   -----| reset               |
//        +---------------------+
//        Parameter: DIVISOR = 6250000 (Signed Integer)
//
// Math:
//   4 Hz output -> period 0.25 s -> toggle every half-period 0.125 s
//   50,000,000 cycles/s * 0.125 s = 6,250,000 counts  = DIVISOR
//   -> count 0 .. DIVISOR-1, then toggle clk_4Hz and restart
//   6.25M needs 23 bits (2^23 ~= 8.39M)
//
// NOTE ON RESET POLARITY:
//   In the schematic this port is driven by the same resetK0 net
//   as the counters' Resetn inputs, which comes from Key0
//   (PIN_AA14) and is ACTIVE-LOW (pressed = 0). So reset is
//   treated as active-low here.
//   If your schematic block is active-high instead, change
//   "negedge reset" -> "posedge reset" and "if (!reset)" ->
//   "if (reset)".
//==============================================================
module frequency_divider #(
    parameter integer DIVISOR = 6250000
)(
    input      clk_50MHz,       // 50 MHz onboard clock (PIN_AF14)
    input      reset,           // active-low async reset (Key0)
    output reg clk_4Hz = 1'b0   // 4 Hz output clock
);

    reg [22:0] count = 23'd0;   // 23-bit counter (holds up to ~8.39M)

    always @(posedge clk_50MHz or negedge reset) begin
        if (!reset) begin
            // asynchronous reset: clear the counter and the output
            count   <= 23'd0;
            clk_4Hz <= 1'b0;
        end
        else if (count == DIVISOR - 1) begin
            count   <= 23'd0;
            clk_4Hz <= ~clk_4Hz;    // toggle every half-period
        end
        else begin
            count <= count + 23'd1;
        end
    end

endmodule
