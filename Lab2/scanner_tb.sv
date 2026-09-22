`timescale 1ns/1ns

module scanner_tb();

    logic           clk;      // system clock
    logic           reset;    // active high reset
    logic           enable;   // active high enable
    logic   [3:0]   rows;     // one-hot row select outputs

    scanner dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .rows(rows)
    );

    // shrink the internal counter's rollover (default max=1,200,000) down to 4
    // so we can see all four scan states pass by quickly in simulation.
    defparam dut.rowSelect.max = 4;

    // generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    // with max=4 and a 10ns clock period, one scan state lasts 4*10ns = 40ns.
    // we wait 45ns (a little past the boundary) between checks so the sample
    // always lands safely after the state has changed.

    initial begin
        reset = 1;
        enable = 0;
        #22 reset = 0;

        // test 1: right after reset, state 0 should be showing (rows = 1000),
        // even though enable is still low
        #10;
        assert (rows == 4'b1000)
            $display("PASSED! rows shows state 0 after reset at time: %0t.", $time);
        else
            $error("FAILED! rows incorrect after reset at time: %0t.", $time);

        // test 2: still disabled -- state must NOT advance
        #45;
        assert (rows == 4'b1000)
            $display("PASSED! rows holds state 0 while disabled at time: %0t.", $time);
        else
            $error("FAILED! rows advanced while disabled at time: %0t.", $time);

        // test 3: enable, wait one state duration -- expect state 1
        enable = 1;
        #45;
        assert (rows == 4'b0100)
            $display("PASSED! rows advanced to state 1 at time: %0t.", $time);
        else
            $error("FAILED! rows did not advance to state 1 at time: %0t.", $time);

        // test 4: wait another state duration -- expect state 2
        #45;
        assert (rows == 4'b0010)
            $display("PASSED! rows advanced to state 2 at time: %0t.", $time);
        else
            $error("FAILED! rows did not advance to state 2 at time: %0t.", $time);

        // test 5: wait another state duration -- expect state 3
        #45;
        assert (rows == 4'b0001)
            $display("PASSED! rows advanced to state 3 at time: %0t.", $time);
        else
            $error("FAILED! rows did not advance to state 3 at time: %0t.", $time);

        // test 6: wait another state duration -- expect wraparound back to state 0
        #45;
        assert (rows == 4'b1000)
            $display("PASSED! rows wrapped back to state 0 at time: %0t.", $time);
        else
            $error("FAILED! rows did not wrap back to state 0 at time: %0t.", $time);

        // test 7: pause mid-cycle -- disable, state should hold
        enable = 0;
        #45;
        assert (rows == 4'b1000)
            $display("PASSED! rows holds state when re-disabled at time: %0t.", $time);
        else
            $error("FAILED! rows advanced while disabled at time: %0t.", $time);

        // test 8: resume -- should pick up where it left off (state 1)
        enable = 1;
        #45;
        assert (rows == 4'b0100)
            $display("PASSED! rows resumes and advances to state 1 at time: %0t.", $time);
        else
            $error("FAILED! rows did not resume correctly at time: %0t.", $time);

        // test 9: reset mid-cycle -- should snap back to state 0 immediately
        reset = 1;
        #10;
        assert (rows == 4'b1000)
            $display("PASSED! rows returns to state 0 on reset at time: %0t.", $time);
        else
            $error("FAILED! rows did not reset correctly at time: %0t.", $time);
        reset = 0;

        #100 $stop;
    end

endmodule