`timescale 1ns/1ns

module top_tb();

    logic   [3:0]   s1, s2;   // hex switch inputs for the two digits
    logic   [3:0]   cols;     // keypad column inputs
    logic           reset;    // active high reset
    logic           enable;   // active high enable

    logic           a1, a2;   // common anode selects
    logic   [6:0]   seg;      // seven segments
    logic   [3:0]   leds;     // keypress LEDs
    logic   [3:0]   rows;     // row select output

    top dut (
        .s1(s1), .s2(s2), .cols(cols),
        .reset(reset), .enable(enable),
        .a1(a1), .a2(a2), .seg(seg),
        .leds(leds), .rows(rows)
    );

    // shrink both internal counters for fast simulation
    defparam dut.timeMultiplexer.max   = 4;   // was 2,000,000
    defparam dut.scanner.rowSelect.max = 4;   // was 1,200,000

    // force the internal int_osc directly
    logic clk_drive;
    always begin
        clk_drive = 0; #5;
        clk_drive = 1; #5;
    end
    initial force dut.int_osc = clk_drive;

    // with max=4 and a 10ns clock period, one mux/scan state lasts 4*10ns = 40ns.
    // we wait 45ns between checks so the sample lands safely past the boundary.

    // expected seven-segment patterns (already inverted for common anode)
	// only using a few digits to test the multiplexing, the sevenSegment decoder has been verified
    localparam logic [6:0] SEG_3 = 7'b0000110; 
    localparam logic [6:0] SEG_A = 7'b0001000; 
    localparam logic [6:0] SEG_7 = 7'b0001111; 
    localparam logic [6:0] SEG_E = 7'b0110000; 

    initial begin
        s1 = 4'b1010;
        s2 = 4'b0011;
        cols = 4'b0000;
        reset = 1;
        enable = 0;
        #22 reset = 0;

        // test 1: right after reset, digitSelect = 0 -> a1 low, a2 high,
        // seg shows s2, and the scanner shows row state 0
        #10;
        assert (a1 == 1'b0)
            $display("PASSED! a1 low after reset at time: %0t.", $time);
        else
            $error("FAILED! a1 incorrect after reset at time: %0t.", $time);

        assert (a2 == 1'b1)
            $display("PASSED! a2 high after reset at time: %0t.", $time);
        else
            $error("FAILED! a2 incorrect after reset at time: %0t.", $time);

        assert (seg == SEG_3)
            $display("PASSED! seg shows s2 after reset at time: %0t.", $time);
        else
            $error("FAILED! seg incorrect after reset at time: %0t.", $time);

        assert (rows == 4'b1000)
            $display("PASSED! rows shows scan state 0 after reset at time: %0t.", $time);
        else
            $error("FAILED! rows incorrect after reset at time: %0t.", $time);

        // test 2: enable, wait one mux state -- digitSelect flips to 1,
        // so a1 should go high, a2 low, and seg should now show s1
        enable = 1;
        #45;
        assert (a1 == 1'b1)
            $display("PASSED! a1 high after one mux toggle at time: %0t.", $time);
        else
            $error("FAILED! a1 incorrect after one mux toggle at time: %0t.", $time);

        assert (a2 == 1'b0)
            $display("PASSED! a2 low after one mux toggle at time: %0t.", $time);
        else
            $error("FAILED! a2 incorrect after one mux toggle at time: %0t.", $time);

        assert (seg == SEG_A)
            $display("PASSED! seg shows s1 after one mux toggle at time: %0t.", $time);
        else
            $error("FAILED! seg incorrect after one mux toggle at time: %0t.", $time);

        // test 3: wait another mux state -- flips back to digit 2
        #45;
        assert (a1 == 1'b0)
            $display("PASSED! a1 low after second mux toggle at time: %0t.", $time);
        else
            $error("FAILED! a1 incorrect after second mux toggle at time: %0t.", $time);

        assert (seg == SEG_3)
            $display("PASSED! seg shows s2 after second mux toggle at time: %0t.", $time);
        else
            $error("FAILED! seg incorrect after second mux toggle at time: %0t.", $time);

        // test 4: change the switches mid-run and confirm seg tracks the new values
        s1 = 4'h7;
        s2 = 4'hE;
        #45; // flips to digit 1 (s1)
        assert (a1 == 1'b1)
            $display("PASSED! a1 high after third mux toggle at time: %0t.", $time);
        else
            $error("FAILED! a1 incorrect after third mux toggle at time: %0t.", $time);

        assert (seg == SEG_7)
            $display("PASSED! seg tracks updated s1 at time: %0t.", $time);
        else
            $error("FAILED! seg did not track updated s1 at time: %0t.", $time);

        #45; // flips to digit 2 (s2)
        assert (seg == SEG_E)
            $display("PASSED! seg tracks updated s2 at time: %0t.", $time);
        else
            $error("FAILED! seg did not track updated s2 at time: %0t.", $time);

        // test 5: leds should mirror cols directly and immediately (combinational)
        cols = 4'b1000;
        #1;
        assert (leds == 4'b1000)
            $display("PASSED! leds mirrors cols = 1010 at time: %0t.", $time);
        else
            $error("FAILED! leds did not mirror cols = 1010 at time: %0t.", $time);

        cols = 4'b0100;
        #1;
        assert (leds == 4'b0100)
            $display("PASSED! leds mirrors cols = 0101 at time: %0t.", $time);
        else
            $error("FAILED! leds did not mirror cols = 0101 at time: %0t.", $time);
			
		cols = 4'b0010;
        #1;
        assert (leds == 4'b0010)
            $display("PASSED! leds mirrors cols = 0101 at time: %0t.", $time);
        else
            $error("FAILED! leds did not mirror cols = 0101 at time: %0t.", $time);
			
		cols = 4'b0001;
        #1;
        assert (leds == 4'b0001)
            $display("PASSED! leds mirrors cols = 0101 at time: %0t.", $time);
        else
            $error("FAILED! leds did not mirror cols = 0101 at time: %0t.", $time);

        // test 6: scanning -- walk through the full row cycle
        // (state 0 was already checked right after reset above)
        #45;
        assert (rows == 4'b0100)
            $display("PASSED! rows advanced to scan state 1 at time: %0t.", $time);
        else
            $error("FAILED! rows incorrect at scan state 1 at time: %0t.", $time);

        #45;
        assert (rows == 4'b0010)
            $display("PASSED! rows advanced to scan state 2 at time: %0t.", $time);
        else
            $error("FAILED! rows incorrect at scan state 2 at time: %0t.", $time);

        #45;
        assert (rows == 4'b0001)
            $display("PASSED! rows advanced to scan state 3 at time: %0t.", $time);
        else
            $error("FAILED! rows incorrect at scan state 3 at time: %0t.", $time);

        // test 7: reset mid-operation -- everything returns to its default state
        reset = 1;
        #10;
        assert (a1 == 1'b0 && a2 == 1'b1)
            $display("PASSED! a1/a2 return to default on reset at time: %0t.", $time);
        else
            $error("FAILED! a1/a2 did not reset correctly at time: %0t.", $time);

        assert (rows == 4'b1000)
            $display("PASSED! rows returns to state 0 on reset at time: %0t.", $time);
        else
            $error("FAILED! rows did not reset correctly at time: %0t.", $time);
        reset = 0;

        #100 $stop;
    end

endmodule