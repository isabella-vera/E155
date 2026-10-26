// NO LONGER USED
// IGNORE

// `timescale 1ns/1ps

// module keyexpansion_tb();
//     logic [127:0]       start_key;
//     logic [0:10][127:0] all_keys;
//     integer             tests, errors;

//     // device under test
//     keyexpansion dut(.start_key(start_key), .all_keys(all_keys));

//     // byte at row r, column c of a packed state (see the packing comment on aes_core in aes_starter.sv)
//     function logic [7:0] state_byte(input logic [127:0] s, input integer r, input integer c);
//         state_byte = s[127 - 8*(r + 4*c) -: 8];
//     endfunction

//     // print got and expected side by side as 4x4 grids, starring the bytes that differ
//     task print_grids(input logic [127:0] got, input logic [127:0] expected);
//         integer r, c;
//         $display("         got                  expected");
//         for (r = 0; r < 4; r = r + 1) begin
//             $write("  ");
//             for (c = 0; c < 4; c = c + 1)
//                 $write("%h%s", state_byte(got, r, c),
//                        (state_byte(got, r, c) === state_byte(expected, r, c)) ? "  " : "* ");
//             $write("    ");
//             for (c = 0; c < 4; c = c + 1)
//                 $write("%h  ", state_byte(expected, r, c));
//             $display("");
//         end
//     endtask

//     // apply one test vector and compare against the expected output
//     task check(input string name, input logic [127:0] in, input logic [0:10][127:0] expected);
//         tests = tests + 1;
//         if ($isunknown(in) || $isunknown(expected)) begin
//             $error("%s: test vector still contains x. Fill in the TODO.", name);
//             errors = errors + 1;
//         end else begin
//             start_key = in;
//             #1;
//             if (all_keys === expected) $display("PASS  %s", name);
//             else begin
//                 $error("%s\n  in       = %h\n  got      = %h\n  expected = %h", name, in, all_keys, expected);
//                 print_grids(all_keys, expected);
//                 errors = errors + 1;
//             end
//         end
//     endtask

//     initial begin
//         tests = 0; errors = 0;
        
//         check("appendix B roundkeys", 128'h2b7e151628aed2a6abf7158809cf4f3c, 
//                                     { 128'h2b7e151628aed2a6abf7158809cf4f3c,
//                                       128'ha0fafe1788542cb123a339392a6c7605,
//                                       128'hf2c295f27a96b9435935807a7359f67f,
//                                       128'h3d80477d4716fe3e1e237e446d7a883b,
//                                       128'hef44a541a8525b7fb671253bdb0bad00,
//                                       128'hd4d1c6f87c839d87caf2b8bc11f915bc,
//                                       128'h6d88a37a110b3efddbf98641ca0093fd,
//                                       128'h4e54f70e5f5fc9f384a64fb24ea6dc4f,
//                                       128'head27321b58dbad2312bf5607f8d292f,
//                                       128'hac7766f319fadc2128d12941575c006e,
//                                       128'hd014f9a8c9ee2589e13f0cc8b6630ca6 });

//         if (errors == 0) $display("PASSED: all %0d tests", tests);
//         else             $display("FAILED: %0d of %0d tests", errors, tests);
//         $finish;
//     end
// endmodule
