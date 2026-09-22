`timescale 1ns/1ns

module scanner_tb();

    logic           clk;      // system clock
    logic           reset;    // active high reset
    logic           enable;   // active high enable
    logic   [3:0]   rows;     // one-hot row select outputs

    // max=8 gives clean quarter boundaries at count=2,4,6,8 -- easy to
    // reason about by hand and small enough to walk every single cycle
    scanner #(4, 8) dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .rows(rows)
    );

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    // expected `rows` value at each count, straight from the inequality
    // chain: count<2 -> 1000, count<4 -> 0100, count<6 -> 0010, else -> 0001
    logic [3:0] held;   // captured rows value across the pause test

    logic [3:0] expected [0:7] = '{4'b1000, 4'b1000,   // count 0,1
                                    4'b0100, 4'b0100,   // count 2,3
                                    4'b0010, 4'b0010,   // count 4,5
                                    4'b0001, 4'b0001};  // count 6,7

    initial begin
        reset = 1;
        enable = 0;
        repeat (2) @(posedge clk);
        reset = 0;
        #1;

        // test 1: count=0 right after reset, before enable even goes high
        assert (rows == expected[0])
            $display("PASSED! rows correct at count=0 (post-reset) at time: %0t.", $time);
        else
            $error("FAILED! rows incorrect at count=0 -- got %b at time: %0t.", rows, $time);

        // test 2: exhaustive walk through every remaining count value in
        // one full period (count=1 through count=7), one clock at a time.
        // this directly exercises each boundary cycle of the inequality
        // chain (count=2, count=4, count=6) where a < vs <= mistake, or
        // an off-by-one in the threshold, would show up immediately.
        enable = 1;
        for (int i = 1; i <= 7; i++) begin
            @(posedge clk); #1;
            assert (rows == expected[i])
                $display("PASSED! rows correct at count=%0d (expected %b) at time: %0t.", i, expected[i], $time);
            else
                $error("FAILED! rows incorrect at count=%0d -- expected %b got %b at time: %0t.",
                        i, expected[i], rows, $time);
        end

        // test 3: rollover boundary -- count wraps from 7 back to 0,
        // rows must return exactly to the count=0 pattern
        @(posedge clk); #1;
        assert (rows == expected[0])
            $display("PASSED! rows correct after rollover (count=0 again) at time: %0t.", $time);
        else
            $error("FAILED! rows incorrect after rollover -- got %b at time: %0t.", rows, $time);

        // test 4: pause mid-cycle -- disable, rows must hold at whatever
        // pattern was active, across multiple clocks
        enable = 0;
        held = rows;
        repeat (3) @(posedge clk); #1;
        assert (rows == held)
            $display("PASSED! rows holds pattern while disabled at time: %0t.", $time);
        else
            $error("FAILED! rows changed while disabled at time: %0t.", $time);

        // test 5: resume -- should pick up counting from where it paused
        // (count=0 -> 1), not restart. rows alone can't distinguish this
        // (count=0 and count=1 share the same pattern), so check the
        // internal count directly via hierarchical reference.
        enable = 1;
        @(posedge clk); #1;
        assert (dut.count == 1)
            $display("PASSED! internal count resumed from 0 to 1 at time: %0t.", $time);
        else
            $error("FAILED! count did not resume correctly -- got %0d at time: %0t.", dut.count, $time);

        // test 6: reset mid-scan snaps immediately back to count=0's pattern
        reset = 1;
        @(posedge clk); #1;
        assert (rows == expected[0])
            $display("PASSED! rows returns to count=0 pattern on reset at time: %0t.", $time);
        else
            $error("FAILED! rows did not reset correctly at time: %0t.", $time);
        reset = 0;

        #20 $stop;
    end

endmodule
