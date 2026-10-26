/////////////////////////////////////////////
// Isabella Vera
// ivera@g.hmc.edu
// 10/24/2026
//
// getkey()
// takes the previous key and round constant to generate the new key 
// implements the rotword() and subword() functions from the aes standard
/////////////////////////////////////////////

module getkey(
                input  logic [127:0] prev_key,
                input  logic [7:0]   rcon,
                output logic [127:0] new_key
             );


    logic [31:0] a0, a1, a2, a3, rot, sub, t, n0, n1, n2, n3;

    assign {a0, a1, a2, a3} = prev_key;
    assign rot = {a3[23:0], a3[31:24]};   // RotWord()

    sbox sb0(rot[31:24], sub[31:24]);     // SubWord()
    sbox sb1(rot[23:16], sub[23:16]);
    sbox sb2(rot[15:8],  sub[15:8]);
    sbox sb3(rot[7:0],   sub[7:0]);

    assign t  = sub ^ {rcon, 24'h0};      // i concatenate 0s bc i only store the first 2 hex digits of each rounc constant but the rest are just zeros
    assign n0 = a0 ^ t;
    assign n1 = a1 ^ n0;
    assign n2 = a2 ^ n1;
    assign n3 = a3 ^ n2;

    assign new_key = {n0, n1, n2, n3};


endmodule
