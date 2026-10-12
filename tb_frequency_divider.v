//==============================================================
// tb_frequency_divider.v
// Self-checking testbench for frequency_divider.v
//
// Uses a small DIVISOR so the output toggles fast enough to see.
// If the logic is right at a small DIVISOR it is right at
// 6,250,000 -- the ratio is what matters, so you never simulate
// the full 6.25M count.
//
// Also checks that the active-low reset clears the output.
//
// Run in Questa:
//   vlog frequency_divider.v tb_frequency_divider.v
//   vsim work.tb_frequency_divider
//   add wave clk_50MHz reset clk_4Hz uut/count
//   run -all
//==============================================================
`timescale 1ns/1ps

module tb_frequency_divider;

    reg  clk_50MHz = 1'b0;
    reg  reset     = 1'b1;      // released (not in reset)
    wire clk_4Hz;

    // shrink the divisor so the output toggles quickly in sim
    localparam integer TEST_DIV = 4;   // toggles every 4 clk periods

    frequency_divider #(.DIVISOR(TEST_DIV)) uut (
        .clk_50MHz(clk_50MHz),
        .reset    (reset),
        .clk_4Hz  (clk_4Hz)
    );

    // 50 MHz clock: 20 ns period
    always #10 clk_50MHz = ~clk_50MHz;

    // expected half-period (ns) = DIVISOR counts * 20 ns/count
    localparam integer EXPECTED_HALF = TEST_DIV * 20;

    time    last_edge = 0;
    time    half_period;
    integer edge_count = 0;
    integer errors     = 0;

    // measure the time between output toggles
    always @(clk_4Hz) begin
        if ($time > 0 && reset === 1'b1) begin
            half_period = $time - last_edge;
            last_edge   = $time;
            edge_count  = edge_count + 1;

            if (edge_count > 1) begin
                if (half_period == EXPECTED_HALF)
                    $display("[PASS] t=%0t  half-period = %0t ns (expected %0d)",
                             $time, half_period, EXPECTED_HALF);
                else begin
                    $display("[FAIL] t=%0t  half-period = %0t ns (expected %0d)",
                             $time, half_period, EXPECTED_HALF);
                    errors = errors + 1;
                end
            end
        end
    end

    initial begin
        // hold reset low briefly, confirm output is cleared
        reset = 1'b0;  #45;
        if (clk_4Hz !== 1'b0) begin
            $display("[FAIL] clk_4Hz not cleared while reset asserted");
            errors = errors + 1;
        end
        else
            $display("[PASS] clk_4Hz held at 0 during reset");

        reset     = 1'b1;
        last_edge = $time;      // start timing from release

        // let it toggle for a while
        #2000;

        if (errors == 0)
            $display("\n==== ALL CHECKS PASSED ====  (%0d toggles seen)", edge_count);
        else
            $display("\n==== %0d CHECK(S) FAILED ====", errors);

        $stop;
    end

endmodule
