// Isabella Vera
// ivera@g.hmc.edu
// Created 9/7/2026
// This module takes a 4-bit input and outputs the logic to light a 7-segment display to show the hexadecimal digit corresponding to the binary input


module sevenSegment ( input logic [3:0] s,
					  output logic [6:0] seg );

					  logic [6:0] segPattern;
					  
					  always_comb begin
					  	case (s)
							4'b0000: segPattern = 7'b1111110;
							4'b0001: segPattern = 7'b0110000;
							4'b0010: segPattern = 7'b1101101;
							4'b0011: segPattern = 7'b1111001;
							4'b0100: segPattern = 7'b0110011;
							4'b0101: segPattern = 7'b1011011;
							4'b0110: segPattern = 7'b1011111;
							4'b0111: segPattern = 7'b1110000;
							4'b1000: segPattern = 7'b1111111;
							4'b1001: segPattern = 7'b1111011;
							4'b1010: segPattern = 7'b1110111;
							4'b1011: segPattern = 7'b0011111;
							4'b1100: segPattern = 7'b1001110;
							4'b1101: segPattern = 7'b0111101;
							4'b1110: segPattern = 7'b1001111;
							4'b1111: segPattern = 7'b1000111;
							default: segPattern = 7'b0000000;
						endcase
					  end
						
					  assign seg = ~segPattern; //invert for common anode seven segment display 
						
endmodule
