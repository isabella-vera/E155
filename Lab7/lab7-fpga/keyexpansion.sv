// NO LONGER USED
// IGNORE

// module keyexpansion( input  logic [127:0] start_key,
//                      output logic [127:0] new_key ); 

//       // From AES Standard Table 5 
//       logic [0:9][7:0] rcon;
//       assign rcon = {8'h01, 8'h02, 8'h04, 8'h08, 8'h10, 8'h20, 8'h40, 8'h80, 8'h1b, 8'h36};



//       // Start creating the keys
//       assign all_keys[0] = start_key;
//       getkey key1 (all_keys[0], rcon[0], all_keys[1]);
//       getkey key2 (all_keys[1], rcon[1], all_keys[2]);
//       getkey key3 (all_keys[2], rcon[2], all_keys[3]);
//       getkey key4 (all_keys[3], rcon[3], all_keys[4]);
//       getkey key5 (all_keys[4], rcon[4], all_keys[5]);
//       getkey key6 (all_keys[5], rcon[5], all_keys[6]);
//       getkey key7 (all_keys[6], rcon[6], all_keys[7]);
//       getkey key8 (all_keys[7], rcon[7], all_keys[8]);
//       getkey key9 (all_keys[8], rcon[8], all_keys[9]);
//       getkey key10(all_keys[9], rcon[9], all_keys[10]);

// endmodule