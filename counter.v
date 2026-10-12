//==============================================================
// counter.v
// EEL 3705L Final Project - Mod-10 (BCD) Up/Down Counter
//
// Matches the `counter` block in the top-level schematic:
//
//        +----------------------+
//   -----| Resetn      Q[3..0]  |=====
//   -----| Clock         pulse  |-----
//   -----| presetn              |
//   -----| up_down              |
//        +----------------------+
//
// Two instances are used:
//   inst1 (ones digit) : Clock = clk_4Hz
//   inst2 (tens digit) : Clock = inst1's pulse   <-- ripple cascade
// Both share Resetn, presetn (= resetK0) and up_down.
//
// Signal conventions:
//   Resetn   : ACTIVE-LOW async reset  -> Q = 0   (Key0 pressed)
//   presetn  : ACTIVE-LOW async preset -> Q = 9
//              (In this schematic presetn is tied to the SAME
//               resetK0 net as Resetn, so both assert together.
//               Resetn is given PRIORITY, so pressing Key0 gives
//               00 as the project spec requires.)
//   up_down  : 1 = count UP, 0 = count DOWN.
//              SW0 passes through a NOT gate first, so
//              SW0 = 0 -> up_down = 1 -> counts up.  Correct.
//   pulse    : carry/borrow out to the next digit.
//
// WHY pulse IS REGISTERED (important):
//   The tens counter is clocked by this pulse on its RISING edge,
//   so pulse must rise exactly when this digit WRAPS -- not when
//   it merely reaches 9.
//   A purely combinational terminal count (pulse = (Q==9)) rises
//   one step too early: the tens digit would advance at 09 and
//   display 19. Registering pulse makes it go high on the very
//   clock edge that performs the wrap, so the tens digit advances
//   at exactly the right time.
//   It also avoids a glitch: a combinational pulse depends on
//   up_down, so flipping SW0 could create a false edge and make
//   the tens digit jump. A registered pulse only changes on a
//   clock edge, so that cannot happen.
//==============================================================
module counter (
    input            Resetn,    // active-low async reset  -> 0
    input            Clock,     // counting clock
    input            presetn,   // active-low async preset -> 9
    input            up_down,   // 1 = up, 0 = down
    output reg [3:0] Q     = 4'd0,
    output reg       pulse = 1'b0   // carry/borrow to next digit
);

    always @(posedge Clock or negedge Resetn or negedge presetn) begin
        if (!Resetn) begin
            // asynchronous reset has priority
            Q     <= 4'd0;
            pulse <= 1'b0;
        end
        else if (!presetn) begin
            // asynchronous preset to 9
            Q     <= 4'd9;
            pulse <= 1'b0;
        end
        else if (up_down) begin
            // ---------- count UP ----------
            if (Q == 4'd9) begin
                Q     <= 4'd0;      // wrap 9 -> 0
                pulse <= 1'b1;      // carry out on the wrap edge
            end
            else begin
                Q     <= Q + 4'd1;
                pulse <= 1'b0;
            end
        end
        else begin
            // ---------- count DOWN ----------
            if (Q == 4'd0) begin
                Q     <= 4'd9;      // wrap 0 -> 9
                pulse <= 1'b1;      // borrow out on the wrap edge
            end
            else begin
                Q     <= Q - 4'd1;
                pulse <= 1'b0;
            end
        end
    end

endmodule
