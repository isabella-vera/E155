`timescale 10ns/1ns

/////////////////////////////////////////////
// mixcolumns_tb
//   Self-checking testbench for mixcolumns
//   On a mismatch it prints the state as a 4x4 grid, laid out like the
//   figures in FIPS-197, and marks each wrong byte with a *. The shape of
//   the error (one byte? a whole row? a whole column?) tells you where to look.
/////////////////////////////////////////////

module mixcolumns_tb();
    logic [127:0]         a_flat, y_flat;
    logic [0:3][0:3][7:0] a_arr, y_arr;
    integer               tests, errors;

    input_to_state  cvt_in (a_flat, a_arr);
    state_to_output cvt_out(y_arr, y_flat);

    // dut
    mixcolumns dut(.a_in(a_arr), .y_out(y_arr));

    // byte at row r, column c of a packed state (see the packing comment on aes_core in aes_starter.sv)
    function logic [7:0] state_byte(input logic [127:0] s, input integer r, input integer c);
        state_byte = s[127 - 8*(r + 4*c) -: 8];
    endfunction

    // print got and expected side by side as 4x4 grids, starring the bytes that differ
    task print_grids(input logic [127:0] got, input logic [127:0] expected);
        integer r, c;
        $display("         got                  expected");
        for (r = 0; r < 4; r = r + 1) begin
            $write("  ");
            for (c = 0; c < 4; c = c + 1)
                $write("%h%s", state_byte(got, r, c),
                       (state_byte(got, r, c) === state_byte(expected, r, c)) ? "  " : "* ");
            $write("    ");
            for (c = 0; c < 4; c = c + 1)
                $write("%h  ", state_byte(expected, r, c));
            $display("");
        end
    endtask

    // apply one test vector and compare against the expected output
    task check(input string name, input logic [127:0] in, input logic [127:0] expected);
        tests = tests + 1;
        if ($isunknown(in) || $isunknown(expected)) begin
            $error("%s: test vector still contains x. Fill in the TODO.", name);
            errors = errors + 1;
        end else begin
            a_flat = in;
            #1;
            if (y_flat === expected) $display("PASS  %s", name);
            else begin
                $error("%s\n  in       = %h\n  got      = %h\n  expected = %h", name, in, y_flat, expected);
                print_grids(y_flat, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        tests = 0; errors = 0;

        // Tests 1 and 2: from a published table of MixColumns examples.
        check("all 01", 128'h01010101010101010101010101010101, 128'h01010101010101010101010101010101);
        check("all c6", 128'hc6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6, 128'hc6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6);

        // Test 3: FIPS-197 Appendix B, Round 1, "After ShiftRows" -> "After MixColumns".
        // DONE: fill in both values. Read each grid column by column, as in Exercise 1.

        // after shiftrows
        // d4 e0 b8 1e
        // bf b4 41 27
        // 5d 52 11 98
        // 30 ae f1 e5

        // after mixcolumns
        // 04 e0 48 28
        // 66 cb f8 06
        // 81 19 d3 26
        // e5 9a 7a 4c

        check("Appendix B round 1", 128'hd4bf5d30e0b452aeb84111f11e2798e5, 128'h046681e5e0cb199a48f8d37a2806264c);

        // Test 4: FIPS-197 Appendix B, Round 2, "After ShiftRows" -> "After MixColumns".
        // DONE: fill in both values.

        // after shiftrows
        // 49 45 7f 77
        // db 39 02 de
        // 87 53 d2 96
        // 3b 89 f1 1a

        // after mixcolumns
        // 58 1b db 1b
        // 4d 4b e7 6b
        // ca 5a ca b0
        // f1 ac a8 e5

        check("Appendix B round 2", 128'h49db873b453953897f02d2f177de961a, 128'h584dcaf11b4b5aacdbe7caa81b6bb0e5);

        if (errors == 0) $display("PASSED: all %0d tests", tests);
        else             $display("FAILED: %0d of %0d tests", errors, tests);
        $finish;
    end
endmodule
