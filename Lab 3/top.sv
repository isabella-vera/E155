// Isabella Vera
// ivera@g.hmc.edu
// Created 9/19/2026
// Top module for E155 Lab 3

module top (input logic [3:0] in_cols,
            input logic reset,

            output logic a1,
            output logic a2,
            output logic [6:0] seg,
            output logic [3:0] rows);

            // internal high-speed oscillator
            logic int_osc;
            HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

            // debounce and synchronize "in_cols"
            // use debounced "cols" going forward
            logic [3:0] cols;
            debounce debouncer (int_osc, reset, in_cols, cols);

            // key-press validation FSM
            // pulses press_valid once per registered key press, and holds scan_freeze while any key
            // in the current row is down so the row stops mid-scan
            logic press_valid, scan_freeze;
            keyPressFSM keyFSM (int_osc, reset, cols, press_valid, scan_freeze);

            // decode current row/col into a hex digit
            logic [3:0] new_s;
            digitAssign digitAssign (cols, rows, new_s);

            // shift register: s1 = most recent validated press, s2 = one before that
            logic [3:0] s1, s2;
            always_ff @(posedge int_osc) begin
                if (reset) begin
                    s1 <= '0;
                    s2 <= '0;
                end else if (press_valid) begin
                    s1 <= new_s;
                    s2 <= s1;
                end
            end

            // time-multiplexed seven segment display
            logic [20:0] count;
            logic digitSelect;
            counter #(21, 200000) timeMultiplexer (int_osc, 1'b0, 1'b1, count);
            assign digitSelect = (count < 2);

            logic [3:0] digit; // currently displayed digit (chosen between s1 and s2)
            assign digit = digitSelect ? s1 : s2;
            assign a1 = digitSelect;
            assign a2 = ~digitSelect;

            sevenSegment segments (digit, seg);
          


            // keypad row scanning; freezes on current row while any key is held
            scanner scanner (int_osc, reset, ~scan_freeze, rows);

endmodule