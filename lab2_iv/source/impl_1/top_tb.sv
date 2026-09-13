`timescale 1ns/1ps

module top_tb;

  localparam int  FAST_MUX_MAX  = 4;
  localparam int  FAST_SCAN_MAX = 4;
  localparam time CLK_PERIOD    = 20ns;

  logic [3:0] s1, s2, cols;
  logic reset, enable;
  logic a1, a2;
  logic [6:0] seg;
  logic [3:0] leds, rows;

  top dut (
    .s1(s1), .s2(s2), .cols(cols),
    .reset(reset), .enable(enable),
    .a1(a1), .a2(a2), .seg(seg),
    .leds(leds), .rows(rows)
  );

  // shrink internal counters for fast simulation 
  defparam dut.timeMultiplexer.max   = FAST_MUX_MAX;
  defparam dut.scanner.rowSelect.max = FAST_SCAN_MAX;

  // stand in for HSOSC
  logic clk_drive;
  initial clk_drive = 0;
  always #(CLK_PERIOD/2) clk_drive = ~clk_drive;
  initial force dut.int_osc = clk_drive;

  int errors = 0;

  // mirror of the sevenSegment decode table, for checking `seg`
  function automatic logic [6:0] expected_seg(input logic [3:0] val);
    logic [6:0] p;
    case (val)
	  4'b0000: p = 7'b1111110;
      4'b0001: p = 7'b0110000;
	  4'b0010: p = 7'b1101101;
	  4'b0011: p = 7'b1111001;
	  4'b0100: p = 7'b0110011;
	  4'b0101: p = 7'b1011011;
	  4'b0110: p = 7'b1011111;
	  4'b0111: p = 7'b1110000;
	  4'b1000: p = 7'b1111111;
	  4'b1001: p = 7'b1111011;
	  4'b1010: p = 7'b1110111;
	  4'b1011: p = 7'b0011111;
	  4'b1100: p = 7'b1001110;
	  4'b1101: p = 7'b0111101;
	  4'b1110: p = 7'b1001111;
	  4'b1111: p = 7'b1000111;
	  default: p = 7'b0000000;
    endcase
    return ~p; // inverted for common anode
  endfunction

  task automatic check_bit(input logic actual, expected, input string label);
    if (actual !== expected) begin
      $error("[FAIL] %s : expected=%b got=%b @ %0t", label, expected, actual, $time);
      errors++;
    end else begin
      $display("[PASS] %s @ %0t", label, $time);
    end
  endtask

  task automatic check_vec(input logic [6:0] actual, expected, input string label);
    if (actual !== expected) begin
      $error("[FAIL] %s : expected=%b got=%b @ %0t", label, expected, actual, $time);
      errors++;
    end else begin
      $display("[PASS] %s @ %0t", label, $time);
    end
  endtask

  task automatic wait_one_mux_state();
    repeat (FAST_MUX_MAX) @(posedge clk_drive);
    #1;
  endtask

  task automatic wait_one_scan_state();
    repeat (FAST_SCAN_MAX) @(posedge clk_drive);
    #1;
  endtask

  initial begin
    errors = 0;
    s1 = 4'hA; s2 = 4'h3; cols = 4'b0000;

    // ---- reset: everything should be in its default state ----
    reset = 1; enable = 0;
    repeat (2) @(posedge clk_drive);
    #1;
    check_bit(a1, 1'b0, "reset: a1 low (digitSelect=0)");
    check_bit(a2, 1'b1, "reset: a2 high (digitSelect=0)");
    check_vec(seg, expected_seg(s2), "reset: seg shows s2 (digitSelect=0)");
    check_bit(rows[0], 1'b1, "reset: rows = 1000");

    reset = 0;

    // ---- multiplexing: step through several digit-select toggles ----
    enable = 1;
    for (int i = 0; i < 4; i++) begin
      wait_one_mux_state();
      if (a1) begin
        check_bit(a2, 1'b0, "multiplex: a2 low while a1 high");
        check_vec(seg, expected_seg(s1), "multiplex: seg shows s1 while a1 active");
      end else begin
        check_bit(a2, 1'b1, "multiplex: a2 high while a1 low");
        check_vec(seg, expected_seg(s2), "multiplex: seg shows s2 while a2 active");
      end
    end

    // change switch values mid-run and re-check on the next couple of toggles
    s1 = 4'h7; s2 = 4'hE;
    for (int i = 0; i < 2; i++) begin
      wait_one_mux_state();
      if (a1) check_vec(seg, expected_seg(s1), "multiplex: seg tracks updated s1");
      else    check_vec(seg, expected_seg(s2), "multiplex: seg tracks updated s2");
    end

    // ---- LED passthrough: leds should mirror cols combinationally ----
    cols = 4'b1010; #1; check_vec({3'b0, leds[3]}, {3'b0, cols[3]}, "leds[3] mirrors cols[3]");
    if (leds !== cols) begin
      $error("[FAIL] leds does not mirror cols : cols=%b leds=%b @ %0t", cols, leds, $time);
      errors++;
    end else begin
      $display("[PASS] leds mirrors cols (cols=%b) @ %0t", cols, $time);
    end

    cols = 4'b0101; #1;
    if (leds !== cols) begin
      $error("[FAIL] leds does not mirror cols : cols=%b leds=%b @ %0t", cols, leds, $time);
      errors++;
    end else begin
      $display("[PASS] leds mirrors cols (cols=%b) @ %0t", cols, $time);
    end

    // ---- scanning: walk through one full one-hot row cycle ----
    begin
      logic [3:0] seq [0:3];
      seq[0] = 4'b1000; seq[1] = 4'b0100; seq[2] = 4'b0010; seq[3] = 4'b0001;
      for (int i = 0; i < 4; i++) begin
        if (rows !== seq[i]) begin
          $error("[FAIL] scanning: expected rows=%b got=%b @ %0t", seq[i], rows, $time);
          errors++;
        end else begin
          $display("[PASS] scanning: rows=%b @ %0t", rows, $time);
        end
        wait_one_scan_state();
      end
    end

    // ---- reset mid-operation: everything returns to defaults ----
    reset = 1;
    @(posedge clk_drive);
    #1;
    check_bit(a1, 1'b0, "reset mid-op: a1 low");
    check_bit(a2, 1'b1, "reset mid-op: a2 high");
    check_bit(rows[0], 1'b1, "reset mid-op: rows = 1000");
    reset = 0;

    // ---- summary ----
    if (errors == 0)
      $display("\n*** ALL TOP-MODULE TESTS PASSED ***\n");
    else
      $display("\n*** TOP-MODULE TESTS FAILED: %0d error(s) ***\n", errors);

    $finish;
  end

endmodule
