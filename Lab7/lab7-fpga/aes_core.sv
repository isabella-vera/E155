/////////////////////////////////////////////
// Isabella Vera
// ivera@g.hmc.edu
// 10/24/2026
//
// aes_core
//   top level AES encryption module
//   when load is asserted, takes the current key and plaintext
//   generates cyphertext and asserts done when complete 11 cycles later
// 
//   See FIPS-197 with Nk = 4, Nb = 4, Nr = 10
//
//   The key and message are 128-bit values packed into an array of 16 bytes as
//   shown below
//        [127:120] [95:88] [63:56] [31:24]     S0,0    S0,1    S0,2    S0,3
//        [119:112] [87:80] [55:48] [23:16]     S1,0    S1,1    S1,2    S1,3
//        [111:104] [79:72] [47:40] [15:8]      S2,0    S2,1    S2,2    S2,3
//        [103:96]  [71:64] [39:32] [7:0]       S3,0    S3,1    S3,2    S3,3
//
//   Equivalently, the values are packed into four words as given
//        [127:96]  [95:64] [63:32] [31:0]      w[0]    w[1]    w[2]    w[3]
/////////////////////////////////////////////

module aes_core(input  logic         clk, 
                input  logic         load,
                input  logic [127:0] key, 
                input  logic [127:0] plaintext, 
                output logic         done, 
                output logic [127:0] cyphertext);

    logic [127:0] curr_text, curr_key, lastStep, lastkey, newkey, roundKey;
    logic [0:3][0:3][7:0] plainTextArray, subedBytes, shiftedRows, mixedCols, toAddRoundkey, roundKeyAdded, nextStateArray;
    logic doneFlag;
    logic roundchange;
    logic [1:0] select;
    logic completeEnable;
    logic [3:0] round;
    // From AES Standard Table 5 
    logic [0:9][7:0] rcon;
    assign rcon = {8'h01, 8'h02, 8'h04, 8'h08, 8'h10, 8'h20, 8'h40, 8'h80, 8'h1b, 8'h36};

    assign done = completeEnable;

    always_ff @(posedge clk) begin
      if (load) begin
        curr_text <= plaintext;
        curr_key  <= key;
      end
    end

    always_ff @(posedge clk) begin
      completeEnable <= doneFlag;
    end

    always_ff @(posedge clk) begin
      if(roundchange) begin
        lastkey <= (round == 0) ? curr_key : newkey;
      end
    end

    always_ff @(posedge clk) begin
      if(doneFlag) begin
        cyphertext <= lastStep;
      end
    end

    always_ff @(posedge clk) begin
      if(roundchange) begin
        nextStateArray <= roundKeyAdded;
      end
    end

    
    input_to_state plaintextarray(curr_text, plainTextArray);    

    
    counter #(.width(4), .max(11)) roundcounter (clk, load, roundchange, round);


    
    controlFSM controller(clk, load, round, doneFlag, roundchange, select);


    mux_3_to_1 MUX(.a(mixedCols), .b(plainTextArray), .c(shiftedRows), .sel(select), .y(toAddRoundkey));
    
    subbytes    subBytes(nextStateArray, subedBytes);
    shiftrows   shiftRows(subedBytes, shiftedRows);
    mixcolumns  mixCols(shiftedRows, mixedCols);

    
    assign roundKey = (round == 0) ? curr_key : newkey;
    getkey      gotroundKey(lastkey, rcon[round-1], newkey);
    addroundkey addRoundKey(toAddRoundkey, roundKey, roundKeyAdded);

    state_to_output getFlatResult(nextStateArray, lastStep);
    
endmodule


module mux_3_to_1 ( input  logic [0:3][0:3][7:0] a,      // option 1
                    input  logic [0:3][0:3][7:0] b,      // option 2
                    input  logic [0:3][0:3][7:0] c,      // option 3
                    input  logic [1:0]           sel,    // select line
                    output logic [0:3][0:3][7:0] y       // single output
                  );

  always_comb begin
      case (sel)
          2'b00   : y = a;
          2'b01   : y = b;
          2'b10   : y = c;
          default : y = '0; 
      endcase
  end

endmodule