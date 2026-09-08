// Isabella Vera
// ivera@g.hmc.edu
// Created 9/7/2026
// Top module for E155 Lab 1

module top (input logic [3:0] s,
			input logic reset,
			input logic enable,
			
			output logic [2:0] led,
			output logic [6:0] seg);
			
			
			// switch-to-led logic
			assign led[0] = s[0] ^ s[1];
			assign led[1] = s[2] & s[3];
			
			// internal high-speed oscillator
			logic int_osc;
			HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
			
			// instantiate submodules
			sevenSegDecoder decoder(s, seg);
			blinkCounter counter(int_osc, reset, enable, led[2]);
			
endmodule