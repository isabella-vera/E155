`timescale 1ns/1ns

module top_tb();

    logic [3:0] in_cols;   // keypad column inputs
    logic       reset;     // active high reset

    logic       a1, a2;    // common anode selects
    logic [6:0] seg;       // seven segments (already inverted for common anode)
    logic [3:0] rows;      // row select output

    top dut (
        .in_cols(in_cols),
        .reset(reset),
        .a1(a1),
        .a2(a2),
        .seg(seg),
        .rows(rows)
    );

    // shrink the internal counters/debounce window for fast simulation.
    // scanner's row dwell is kept relatively long (20 cycles/state) so it
    // stays stable long enough for sync+debounce (a handful of cycles) to
    // fully resolve while the scanner is still sitting on that row.
    defparam dut.timeMultiplexer.max       = 4;    // was 200,000
    defparam dut.scanner.max               = 20;   // was 6,000,000 (now a real parameter)
    defparam dut.debouncer.DEBOUNCE_CYCLES = 2;     // was 200,000

    // top has no clock port -- it generates int_osc internally via HSOSC,
    // which doesn't have a usable simulation model, so force it directly
    logic clk_drive;
    always begin
        clk_drive = 0; #5;
        clk_drive = 1; #5;
    end
    initial force dut.int_osc = clk_drive;

    // expected seven-segment patterns (already inverted for common anode)
    localparam logic [6:0] SEG_0 = 7'b0000001;
    localparam logic [6:0] SEG_7 = 7'b0001111;
    localparam logic [6:0] SEG_E = 7'b0110000;

    initial begin
        reset = 1;
        in_cols = 4'b0000;
        repeat (3) @(posedge clk_drive);
        reset = 0;
        #1;

        // test 1: right after reset, scanner sits on its first state and
        // nothing has been registered yet (s1 = s2 = 0 -> shows '0')
        assert (rows == 4'b1000)
            $display("PASSED! scanner on state 0 after reset at time: %0t.", $time);
        else
            $error("FAILED! rows incorrect after reset at time: %0t.", $time);

        assert (dut.s1 == 4'h0 && dut.s2 == 4'h0)
            $display("PASSED! s1/s2 cleared after reset at time: %0t.", $time);
        else
            $error("FAILED! s1/s2 not cleared after reset at time: %0t.", $time);

        // test 2: mux plumbing -- a1/a2 complementary, seg shows '0' on
        // both phases since s1 == s2 right now
        assert ((a1 == 1'b1 && a2 == 1'b0) || (a1 == 1'b0 && a2 == 1'b1))
            $display("PASSED! a1/a2 are complementary at time: %0t.", $time);
        else
            $error("FAILED! a1/a2 not complementary at time: %0t.", $time);

        assert (seg == SEG_0)
            $display("PASSED! seg shows '0' before any key press at time: %0t.", $time);
        else
            $error("FAILED! seg incorrect before any key press at time: %0t.", $time);

        // test 3: single clean key press. rows=1000 + cols=0001 decodes to hex digit 'E'.
        in_cols = 4'b0001;
        wait (dut.press_valid);        // FSM has seen the debounced single-key condition
        @(posedge clk_drive); #1;      // this is the edge that captures new_s into s1

        assert (dut.s1 == 4'hE)
            $display("PASSED! s1 registered the pressed key (E) at time: %0t.", $time);
        else
            $error("FAILED! s1 did not register the pressed key -- got %h at time: %0t.", dut.s1, $time);

        assert (rows == 4'b1000)
            $display("PASSED! scanner still frozen on the held row at time: %0t.", $time);
        else
            $error("FAILED! scanner did not stay frozen while key is held at time: %0t.", $time);

        // test 4: ignore a second key added WHILE the first is still held
        // s1 must not change and no new press_valid should fire.
        in_cols = 4'b0011;
        wait (dut.cols == 4'b0011);
        repeat (3) @(posedge clk_drive); #1;

        assert (dut.s1 == 4'hE)
            $display("PASSED! s1 unchanged while a second key is added mid-hold at time: %0t.", $time);
        else
            $error("FAILED! s1 changed while a second key was added mid-hold at time: %0t.", $time);

        assert (rows == 4'b1000)
            $display("PASSED! scanner still frozen with two keys down at time: %0t.", $time);
        else
            $error("FAILED! scanner unfroze unexpectedly at time: %0t.", $time);

        // test 5: release the FIRST key, leaving the SECOND one held alone. 
        in_cols = 4'b0010;
        wait (dut.cols == 4'b0010);
        repeat (5) @(posedge clk_drive); #1;

        assert (dut.s1 == 4'h0)
            $display("PASSED! s1 updated to the surviving key (0) on partial release at time: %0t.", $time);
        else
            $error("FAILED! s1 did NOT update to the surviving key -- got %h at time: %0t. (known FSM gap)", dut.s1, $time);

        // test 6: full release -- scanner should unfreeze and resume stepping
        in_cols = 4'b0000;
        wait (dut.cols == 4'b0000);
        wait (dut.scan_freeze == 1'b0);
        assert (1)
            $display("PASSED! scan_freeze cleared after full release at time: %0t.", $time);

        // test 7: a clean second press, on a different row, from a fully
        // idle state -- confirms the normal (non-staggered) digit-history
        // shift still works: s1 takes the new digit, s2 holds the previous
        // successfully-registered one.
        wait (rows == 4'b0100);
        in_cols = 4'b0001;
        wait (dut.press_valid);
        @(posedge clk_drive); #1;

        assert (dut.s1 == 4'h7)
            $display("PASSED! s1 updated to the new clean press (7) at time: %0t.", $time);
        else
            $error("FAILED! s1 incorrect after clean press -- got %h at time: %0t.", dut.s1, $time);

        // check if FSM handles the staggered case, s2 should be '0' (the survivor from test 5). 
        assert (dut.s2 == 4'h0)
            $display("PASSED! s2 holds a previously-registered digit (%h) at time: %0t.", dut.s2, $time);
        else
            $error("FAILED! s2 has an unexpected value %h at time: %0t.", dut.s2, $time);

        // test 8: reset mid-operation -- everything returns to its default state
        in_cols = 4'b0000;
        reset = 1;
        @(posedge clk_drive); #1;
        assert (rows == 4'b1000 && dut.s1 == 4'h0 && dut.s2 == 4'h0)
            $display("PASSED! design returns to default state on reset at time: %0t.", $time);
        else
            $error("FAILED! design did not reset correctly at time: %0t.", $time);
        reset = 0;

        #50 $stop;
    end

endmodule