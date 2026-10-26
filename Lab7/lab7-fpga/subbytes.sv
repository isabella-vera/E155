/////////////////////////////////////////////
// Isabella Vera
// ivera@g.hmc.edu
// 10/24/2026
//
// subbytes()
// takes state array
// applies sbox substitution on each element
// returns new state array
/////////////////////////////////////////////

module subbytes( input  logic [0:3][0:3][7:0] a,
                 output logic [0:3][0:3][7:0] y );

                 sbox y00(a[0][0], y[0][0]);
                 sbox y01(a[0][1], y[0][1]);
                 sbox y02(a[0][2], y[0][2]);
                 sbox y03(a[0][3], y[0][3]);
                 sbox y10(a[1][0], y[1][0]);
                 sbox y11(a[1][1], y[1][1]);
                 sbox y12(a[1][2], y[1][2]);
                 sbox y13(a[1][3], y[1][3]);
                 sbox y20(a[2][0], y[2][0]);
                 sbox y21(a[2][1], y[2][1]);
                 sbox y22(a[2][2], y[2][2]);
                 sbox y23(a[2][3], y[2][3]);
                 sbox y30(a[3][0], y[3][0]);
                 sbox y31(a[3][1], y[3][1]);
                 sbox y32(a[3][2], y[3][2]);
                 sbox y33(a[3][3], y[3][3]);
endmodule
