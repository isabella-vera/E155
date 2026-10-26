`timescale 10ns/1ns
/////////////////////////////////////////////
// Isabella Vera
// ivera@g.hmc.edu
// 10/24/2026
//
// addroundkey()
// takes the current state array and key 
// outputs state array XOR roundkey
/////////////////////////////////////////////
module addroundkey(input  logic [0:3][0:3][7:0]   a,
                   input  logic [127:0]           key,
                   output logic [0:3][0:3][7:0]   y);

    
    logic [0:3][0:3][7:0] keyArray;
    input_to_state keyarray(key, keyArray);

    assign y = a ^ keyArray;

endmodule
