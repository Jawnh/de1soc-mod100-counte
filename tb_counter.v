
//==============================================================
// tb_counter.v  (corrected)
// Testbench for counter.v - two instances cascaded as in the
// top-level schematic.
//
//   clk_4Hz      -> [ones].Clock
//   [ones].pulse -> [tens].Clock      (ripple cascade)
//   resetK0      -> Resetn AND presetn of both
//   up_down      -> both
//
// FIX vs. the earlier version:
//   All stimulus changes and all sampling now happen on the
//   FALLING edge of the clock. The previous version used #5
//   delays that landed on the same simulation time as a rising
//   clock edge, so the DUT counted on an edge the testbench had
//   not yet started waiting for -- every check came out one
//   count off. Driving and sampling on the opposite edge from
//   the active edge removes that race entirely.
//
// Run in Questa:
//   vlib work
//   vlog counter.v tb_counter.v
//   vsim -voptargs=+acc work.tb_counter
//   add wave -radix decimal /tb_counter/*
//   add wave -radix decimal /tb_counter/u_ones/*
//   run -all
//==============================================================
`timescale 1ns/1ps
 
module tb_counter;
 
    reg clk_4Hz = 1'b0;
    reg resetK0 = 1'b1;    // active-low, released
    reg up_down = 1'b1;    // 1 = up, 0 = down
 
    wire [3:0] ones, tens;
    wire       carry, tens_pulse;
 
    // ---- ones digit: clocked by the 4 Hz clock ----
    counter u_ones (
        .Resetn (resetK0),
        .Clock  (clk_4Hz),
        .presetn(resetK0),
        .up_down(up_down),
        .Q      (ones),
        .pulse  (carry)
    );
 
    // ---- tens digit: clocked by the ones digit's carry ----
    counter u_tens (
        .Resetn (resetK0),
        .Clock  (carry),        // ripple cascade
        .presetn(resetK0),
        .up_down(up_down),
        .Q      (tens),
        .pulse  (tens_pulse)    // unconnected in the schematic
    );
 
    // fast clock for simulation: 20 ns period
    always #10 clk_4Hz = ~clk_4Hz;
 
    wire [7:0] count_dec = tens * 8'd10 + ones;
 
    integer errors = 0;
 
    // advance n counting edges, then settle on the falling edge
    task step;
        input integer n;
        integer k;
        begin
            for (k = 0; k < n; k = k + 1) @(posedge clk_4Hz);
            @(negedge clk_4Hz);       // sample away from the active edge
        end
    endtask
 
    task check;
        input [7:0] expected;
        input [8*24:1] label;
        begin
            if (count_dec !== expected) begin
                $display("  [FAIL] %0s : expected %0d, got %0d",
                         label, expected, count_dec);
                errors = errors + 1;
            end
            else
                $display("  [PASS] %0s : count = %0d", label, count_dec);
        end
    endtask
 
    // running trace, sampled on the falling edge so values are settled
    always @(negedge clk_4Hz)
        $display("t=%0t  dir=%s  display = %0d%0d",
                 $time, (up_down ? "UP" : "DN"), tens, ones);
 
    initial begin
        // ---------- reset ----------
        resetK0 = 1'b0;
        up_down = 1'b1;
        @(negedge clk_4Hz);
        @(negedge clk_4Hz);
        check(0, "reset held");
        resetK0 = 1'b1;             // released on a falling edge: no race
 
        // ---------- count up ----------
        step(10);  check(10, "09->10 carry");
        step(89);  check(99, "reached 99");
        step(1);   check(0,  "99->00 wrap");
        step(5);   check(5,  "up to 05");
 
        // ---------- change direction at a safe point ----------
        // (already on a falling edge, and carry is low here)
        up_down = 1'b0;
 
        // ---------- count down ----------
        step(5);   check(0,  "down to 00");
        step(1);   check(99, "00->99 borrow wrap");
        step(9);   check(90, "down to 90");
        step(1);   check(89, "90->89 borrow");
 
        // ---------- asynchronous reset mid-run ----------
        resetK0 = 1'b0;
        #3;                          // no clock edge in this window
        check(0, "async reset mid-run");
        resetK0 = 1'b1;
 
        if (errors == 0)
            $display("\n==== ALL CHECKS PASSED ====");
        else
            $display("\n==== %0d CHECK(S) FAILED ====", errors);
 
        $stop;
    end
 
endmodule
 



