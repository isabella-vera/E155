// Isabella Vera
// ivera@g.hmc.edu
// Created 9/11/2026
// Top module for E155 Lab 2 


module top (input logic [3:0] s1,
			input logic [3:0] s2,
			input logic [3:0] cols,
			input logic reset,
			input logic enable,
			
			output logic a1,
			output logic a2,
			output logic [6:0] seg,
			output logic [3:0] leds,
			output logic [3:0] rows);
			
			// internal high-speed oscillator
			logic int_osc;
			HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
			
			
			// for time multiplexed seven segment display
			logic digitSelect; // 
			logic [3:0] digit; // current switch input (choosing from top input s1 and s2)
			
			counter #(21, 2000000, 1) timeMultiplexer (int_osc, reset, enable, digitSelect);
					  
			assign digit = digitSelect ?  s1 : s2;
			assign a1 = digitSelect ? 1 : 0;
			assign a2 = digitSelect ? 0 : 1;
			
			sevenSegment segments(digit, seg);
			
			
			// for scanning
			scanner scanner(int_osc, reset, enable, rows);
			
			assign leds[0] = cols[0];
			assign leds[1] = cols[1];
			assign leds[2] = cols[2];
			assign leds[3] = cols[3];

endmodule 