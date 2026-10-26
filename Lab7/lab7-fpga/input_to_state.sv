`timescale 10ns/1ns

/////////////////////////////////////////////
// Starter code from Lab 7 Workshop, Josh Brake
// Completed by Isabella Vera
// ivera@g.hmc.edu
// 10/23/2026
//
// input_to_state
//   Copy a 128-bit value into the 4x4 state array
//   Section 3.4
//   Purely combinational
//
//   The input uses the same packing as aes_core in aes_starter.sv:
//        [127:120] [95:88] [63:56] [31:24]     S0,0    S0,1    S0,2    S0,3
//        [119:112] [87:80] [55:48] [23:16]     S1,0    S1,1    S1,2    S1,3
//        [111:104] [79:72] [47:40] [15:8]      S2,0    S2,1    S2,2    S2,3
//        [103:96]  [71:64] [39:32] [7:0]       S3,0    S3,1    S3,2    S3,3
//
//   The output is the state array, indexed y[r][c] for row r, column c,
//   just like the grids in FIPS-197.
//
//   The ranges are [0:3], not [3:0], on purpose: y[0][0] is the leftmost
//   byte, so a value written row by row,
//        {8'h32, 8'h88, 8'h31, 8'he0,    // row 0
//         8'h43, 8'h5a, 8'h31, 8'h37,    // row 1
//         ...}
//   fills row 0 first and reads like the grids in the standard.
//
//   Because y is packed, it is also 128 bits wide, so `assign y = a;`
//   compiles. It is not the answer. Work out why in Part A.
/////////////////////////////////////////////

module input_to_state(input  logic [127:0]         a,
                      output logic [0:3][0:3][7:0] y);

    assign y[0][0] = a[127:120];
    assign y[1][0] = a[119:112];
    assign y[2][0] = a[111:104];
    assign y[3][0] = a[103:96];

    assign y[0][1] = a[95:88];
    assign y[1][1] = a[87:80];
    assign y[2][1] = a[79:72];
    assign y[3][1] = a[71:64];

    assign y[0][2] = a[63:56];
    assign y[1][2] = a[55:48];
    assign y[2][2] = a[47:40];
    assign y[3][2] = a[39:32];

    assign y[0][3] = a[31:24];
    assign y[1][3] = a[23:16];
    assign y[2][3] = a[15:8];
    assign y[3][3] = a[7:0];
    
endmodule
