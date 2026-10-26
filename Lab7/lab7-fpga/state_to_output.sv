`timescale 10ns/1ns

/////////////////////////////////////////////
// state_to_output
//   Copy the 4x4 state array back into a 128-bit value
//   Section 3.4
//   Purely combinational
//
//   The reverse of input_to_state, with the same packing. With both, a
//   module with 128-bit ports like the ones in aes_core can do its work
//   on rows and columns inside.
/////////////////////////////////////////////

module state_to_output(input  logic [0:3][0:3][7:0] a,
                       output logic [127:0]         y);

    assign y[127:120] = a[0][0];
    assign y[119:112] = a[1][0];
    assign y[111:104] = a[2][0];
    assign y[103:96]  = a[3][0];

    assign y[95:88] = a[0][1];
    assign y[87:80] = a[1][1];
    assign y[79:72] = a[2][1];
    assign y[71:64] = a[3][1];

    assign y[63:56] = a[0][2];
    assign y[55:48] = a[1][2];
    assign y[47:40] = a[2][2];
    assign y[39:32] = a[3][2];

    assign y[31:24] = a[0][3];
    assign y[23:16] = a[1][3];
    assign y[15:8]  = a[2][3];
    assign y[7:0]   = a[3][3];

endmodule
