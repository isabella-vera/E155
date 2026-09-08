`timescale 1ns/1ns

module blinkCounter_tb();

    logic clk;
    logic reset;
    logic enable;
    logic led2;

    blinkCounter dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .led2(led2)
    );

    // generate a free-running clock, 10 ns period
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    // log every led2 toggle as it happens
    always @(led2) begin
        if (!reset)
            $display("led2 toggled to %b at time %0t.", led2, $time);
    end

    initial begin
        logic [31:0] held_count;

        // reset check (enable held low during reset too)
        reset  = 1;
        enable = 0;
        @(posedge clk);
        @(posedge clk);
        assert (led2 == 1'b0 && dut.counter == 32'd0)
            $display("PASSED! led2/counter reset to 0 at time %0t.", $time);
        else
            $error("FAILED! reset state incorrect at time %0t. led2=%b counter=%0d", $time, led2, dut.counter);

        reset = 0;

        // enable still low: counter should NOT move
        repeat (5) @(posedge clk);
        assert (dut.counter == 32'd0)
            $display("PASSED! counter holds at 0 while enable=0, time %0t.", $time);
        else
            $error("FAILED! counter changed while enable=0 at time %0t. counter=%0d", $time, dut.counter);

        // enable high: counter should increment once per clock
        enable = 1;
        repeat (5) @(posedge clk);
        assert (dut.counter == 32'd5)
            $display("PASSED! counter incremented correctly with enable=1, time %0t. counter=%0d", $time, dut.counter);
        else
            $error("FAILED! counter incorrect with enable=1 at time %0t. counter=%0d expected=5", $time, dut.counter);

        // disable mid-count: counter should hold at its current value
        enable = 0;
        held_count = dut.counter;
        repeat (5) @(posedge clk);
        assert (dut.counter == held_count)
            $display("PASSED! counter held steady while disabled, time %0t.", $time);
        else
            $error("FAILED! counter changed while disabled at time %0t. counter=%0d expected=%0d", $time, dut.counter, held_count);

        // re-enable: counter should resume from held value, not reset to 0
        enable = 1;
        @(posedge clk);
        assert (dut.counter == held_count + 1)
            $display("PASSED! counter resumed correctly after re-enable, time %0t.", $time);
        else
            $error("FAILED! counter did not resume correctly at time %0t. counter=%0d expected=%0d", $time, dut.counter, held_count + 1);

        $stop;
    end

endmodule
