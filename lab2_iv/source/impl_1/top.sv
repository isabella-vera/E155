module top (input logic [3:0] s1,
			input logic [3:0] s2,
			input logic reset,
			input logic enable,
			
			output logic a1,
			output logic a2,
			output logic [6:0] seg);
			
			// internal high-speed oscillator
			logic int_osc;
			HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
			
			
			logic digitSelect; 
			logic [3:0] digit;
			
			counter #(21, 2000000) timeMultiplexer (int_osc, reset, enable, digitSelect);
					  
			assign digit = digitSelect ?  s1 : s2;
			assign a1 = digitSelect ? 1 : 0;
			assign a2 = digitSelect ? 0 : 1;
			
			sevenSegment segments(digit, seg);

endmodule 