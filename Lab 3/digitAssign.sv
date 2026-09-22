// Isabella Vera
// ivera@g.hmc.edu
// Created 9/19/2026
// This module was made for E155 Lab 3
// Generates hexadecimal digit from the row and column of a keypad 

module digitAssign( input logic [3:0] cols,
                    input logic [3:0] rows,

                    output logic [3:0] s );

                    logic [7:0] row_col;
                    assign row_col = {rows, cols};

                    always_comb begin
                        case (row_col)
                          8'b00010001: s = 4'b0001;    // row 0 col 0 (1)
                          8'b00010010: s = 4'b0010;    // row 0 col 1 (2)
                          8'b00010100: s = 4'b0011;    // row 0 col 2 (3)
                          8'b00011000: s = 4'b1010;    // row 0 col 3 (A)
                          8'b00100001: s = 4'b0100;    // row 1 col 0 (4)
                          8'b00100010: s = 4'b0101;    // row 1 col 1 (5)
                          8'b00100100: s = 4'b0110;    // row 1 col 2 (6)
                          8'b00101000: s = 4'b1011;    // row 1 col 3 (B)
                          8'b01000001: s = 4'b0111;    // row 2 col 0 (7)
                          8'b01000010: s = 4'b1000;    // row 2 col 1 (8)
                          8'b01000100: s = 4'b1001;    // row 2 col 2 (9)
                          8'b01001000: s = 4'b1100;    // row 2 col 3 (C)
                          8'b10000001: s = 4'b1110;    // row 3 col 0 (E)
                          8'b10000010: s = 4'b0000;    // row 3 col 1 (0)
                          8'b10000100: s = 4'b1111;    // row 3 col 2 (F)
                          8'b10001000: s = 4'b1101;    // row 3 col 3 (D)
                          default:     s = 4'b0000;    // default to zero
                        endcase
                      end
endmodule
