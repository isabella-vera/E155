`timescale 1ns/1ps
module subbytes_tb();
    logic [0:3][0:3][7:0]   a;
    logic [0:3][0:3][7:0]   y;

    integer tests, errors;

    // device under test
    subbytes dut(.a(a), .y(y));

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
            a = in;
            #1;
            if (y === expected) $display("PASS  %s", name);
            else begin
                $error("%s\n  in       = %h\n  got      = %h\n  expected = %h", name, in, y, expected);
                print_grids(y, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        tests = 0; errors = 0;

        // Test 1:
        check("round 2 subbyte", {8'ha4, 8'h68, 8'h6b, 8'h02,
                                  8'h9c, 8'h9f, 8'h5b, 8'h6a,
                                  8'h7f, 8'h35, 8'hea, 8'h50,
                                  8'hf2, 8'h2b, 8'h43, 8'h49},
                                  
                                 {8'h49, 8'h45, 8'h7f, 8'h77,
                                  8'hde, 8'hdb, 8'h39, 8'h02,
                                  8'hd2, 8'h96, 8'h87, 8'h53,
                                  8'h89, 8'hf1, 8'h1a, 8'h3b});

        if (errors == 0) $display("PASSED: all %0d tests", tests);
        else             $display("FAILED: %0d of %0d tests", errors, tests);
        $finish;
    end
endmodule
