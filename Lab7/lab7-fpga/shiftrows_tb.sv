`timescale 10ns/1ns

/////////////////////////////////////////////
// shiftrows_tb
//   Self-checking testbench for shiftrows
//   On a mismatch it prints the state as a 4x4 grid, laid out like the
//   figures in FIPS-197, and marks each wrong byte with a *. The shape of
//   the error (one byte? a whole row? a whole column?) tells you where to look.
/////////////////////////////////////////////

module shiftrows_tb();
    logic [127:0]         a_flat, y_flat;
    logic [0:3][0:3][7:0] a_arr, y_arr;
    integer               tests, errors;

    input_to_state  cvt_in (a_flat, a_arr);
    state_to_output cvt_out(y_arr, y_flat);

    // dut
    shiftrows dut(.b(a_arr), .y_array(y_arr));

    // byte at row r, column c of a packed state (see the packing in shiftrows.sv)
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

        // Test 1: every byte holds its own position, S[r][c] = 4c + r, so a wrong
        // answer shows you exactly which byte ended up where.
        // DONE: work out the expected output by hand before you run anything.

        // Original
        // 00 04 08 0c
        // 01 05 09 0d
        // 02 06 0a 0e
        // 03 07 0b 0f

        // After ShiftRows
        // 00 04 08 0c
        // 05 09 0d 01 
        // 0a 0e 02 06 
        // 0f 03 07 0b 
        check("numbered bytes", 128'h000102030405060708090a0b0c0d0e0f, 128'h00050a0f04090e03080d02070c01060b);


        // Test 2: FIPS-197 Appendix B, Round 1, "After SubBytes" -> "After ShiftRows".
        // Appendix B prints the state as 4x4 grids. Read each grid column by column.
        // DONE: fill in both values.
        
        // After SubBytes
        // d4 e0 b8 1e
        // 27 bf b4 41
        // 11 98 5d 52
        // ae f1 e5 30

        // After ShiftRows
        // d4 e0 b8 1e
        // bf b4 41 27
        // 5d 52 11 98
        // 30 ae f1 e5
        check("Appendix B round 1", 128'hd42711aee0bf98f1b8b45de51e415230, 128'hd4bf5d30e0b452aeb84111f11e2798e5);

        // Test 3: FIPS-197 Appendix B, Round 2, "After SubBytes" -> "After ShiftRows".
        // DONE: fill in both values.

        // After SubBytes
        // 49 45 7f 77
        // de db 39 02
        // d2 96 87 53
        // 89 f1 1a 3b

        // After ShiftRows
        // 49 45 7f 77
        // db 39 02 de
        // 87 53 d2 96
        // 3b 89 f1 1a
        check("Appendix B round 2", 128'h49ded28945db96f17f39871a7702533b, 128'h49db873b453953897f02d2f177de961a);

        if (errors == 0) $display("PASSED: all %0d tests", tests);
        else             $display("FAILED: %0d of %0d tests", errors, tests);
        $finish;
    end
endmodule
